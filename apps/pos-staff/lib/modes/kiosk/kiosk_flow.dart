import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_api/pos_api.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors.dart';
import 'kiosk_api.dart';
import 'kiosk_cart.dart';

/// Where the guest is on the kiosk.
enum KioskStep { loading, paused, welcome, menu, cart, paying, done }

/// How often the kiosk reads its order while a bank QR is open, and its
/// state otherwise (a manager may open or close its shift).
const kioskPaymentPoll = Duration(seconds: 2);
const kioskStatePoll = Duration(seconds: 20);

/// How long "Are you still there?" waits before the order is dropped, and
/// how long the call number stays on screen.
const kioskStillThereWait = Duration(seconds: 10);
const kioskDoneShown = Duration(seconds: 20);

/// One guest's visit at a self-ordering kiosk, from the welcome screen to
/// the call number. The server owns prices, payment and the order; this
/// keeps the basket, the step, the idle timer and the QR countdown. Placing
/// an order retries a lost answer under the same Idempotency-Key; finishing,
/// handing to the counter and canceling are safe to repeat on the server.
class KioskFlow extends ChangeNotifier {
  KioskFlow({
    required this.api,
    Uuid uuid = const Uuid(),
    DateTime Function()? now,
  }) : _uuid = uuid,
       _now = now ?? DateTime.now;

  final KioskApi api;
  final Uuid _uuid;
  final DateTime Function() _now;
  final cart = KioskCart();

  KioskStep step = KioskStep.loading;
  KioskState? state;
  KioskMenu? menu;
  KioskOrder? order;

  /// The last refusal or failure to explain, cleared by the next step.
  AppFailure? failure;

  /// The server is not answering; the kiosk keeps trying.
  bool reconnecting = false;
  bool busy = false;

  /// "Are you still there?" is showing; [stillThereLeft] counts down.
  bool askingStillThere = false;
  int stillThereLeft = 0;

  String? selectedCategoryId;

  /// The key of the order being placed: kept until it is answered, so a
  /// retry after a lost answer does not place a second order.
  String? _placeKey;
  Timer? _idle;
  Timer? _stillThere;
  Timer? _poll;
  Timer? _statePoll;
  Timer? _doneTimer;
  bool _disposed = false;

  Duration get _idleAfter => Duration(seconds: state?.idleSeconds ?? 60);

  bool get vietqrOffered => state?.payments.vietqr == true;

  /// Seconds left on the open QR, by the server's deadline.
  int get qrSecondsLeft {
    final expires = order?.payment?.expiresAt;
    if (expires == null) return 0;
    final left = expires.difference(_now()).inSeconds;
    return left < 0 ? 0 : left;
  }

  Future<void> start() async {
    await _refreshState(initial: true);
    _statePoll = Timer.periodic(
      kioskStatePoll,
      (_) => unawaited(_refreshState()),
    );
  }

  Future<void> _refreshState({bool initial = false}) async {
    try {
      final next = await api.state();
      state = next;
      reconnecting = false;
      if (!next.open) {
        if (step == KioskStep.welcome ||
            step == KioskStep.loading ||
            step == KioskStep.menu ||
            step == KioskStep.cart) {
          _reset(to: KioskStep.paused);
        }
      } else if (step == KioskStep.paused || step == KioskStep.loading) {
        await _loadMenu();
        step = KioskStep.welcome;
      }
    } on AppFailure catch (error) {
      if (isTransient(error)) {
        reconnecting = true;
      } else {
        failure = error;
      }
      if (initial) step = KioskStep.paused;
    }
    _changed();
  }

  Future<void> _loadMenu() async {
    final next = await api.menu();
    if (menu?.etag != next.etag) menu = next;
    selectedCategoryId ??= menu!.categories.isEmpty
        ? null
        : menu!.categories.first.id;
  }

  /// Any touch: the guest is there. While "Are you still there?" shows,
  /// only its own buttons answer it.
  void touch() {
    if (askingStillThere) return;
    _armIdle();
  }

  void stillHere() {
    askingStillThere = false;
    _stillThere?.cancel();
    _armIdle();
    _changed();
  }

  void _armIdle() {
    _idle?.cancel();
    if (step == KioskStep.welcome ||
        step == KioskStep.paused ||
        step == KioskStep.loading ||
        step == KioskStep.done) {
      return;
    }
    _idle = Timer(_idleAfter, _askStillThere);
  }

  void _askStillThere() {
    askingStillThere = true;
    stillThereLeft = kioskStillThereWait.inSeconds;
    _stillThere?.cancel();
    _stillThere = Timer.periodic(const Duration(seconds: 1), (timer) {
      stillThereLeft -= 1;
      if (stillThereLeft <= 0) {
        timer.cancel();
        unawaited(abandon());
      }
      _changed();
    });
    _changed();
  }

  void begin() {
    if (state?.open != true) return;
    failure = null;
    step = KioskStep.menu;
    _armIdle();
    _changed();
  }

  void pickCategory(String id) {
    selectedCategoryId = id;
    touch();
    _changed();
  }

  bool add(KioskCartLine line) {
    final added = cart.add(line);
    touch();
    _changed();
    return added;
  }

  void showCart() {
    step = cart.isEmpty ? KioskStep.menu : KioskStep.cart;
    touch();
    _changed();
  }

  void backToMenu() {
    step = KioskStep.menu;
    touch();
    _changed();
  }

  void setQuantity(int index, int quantity) {
    cart.setQuantity(index, quantity);
    if (cart.isEmpty) step = KioskStep.menu;
    touch();
    _changed();
  }

  /// Places the basket: by bank QR, or left for the counter.
  Future<void> checkout(KioskOrderInputPaymentEnum payment) async {
    if (busy || cart.isEmpty) return;
    busy = true;
    failure = null;
    touch();
    _changed();
    _placeKey ??= _uuid.v4();
    try {
      order = await api.place(
        key: _placeKey!,
        items: cart.inputs,
        payment: payment,
      );
      _placeKey = null;
      reconnecting = false;
      _afterOrder();
    } on AppFailure catch (error) {
      if (isTransient(error)) {
        reconnecting = true;
      } else {
        _placeKey = null;
        failure = error;
        if (error case ConflictFailure(reason: 'kiosk_paused')) {
          await _refreshState();
        }
      }
    } finally {
      busy = false;
      _changed();
    }
  }

  void _afterOrder() {
    final current = order;
    if (current == null) return;
    switch (current.status) {
      case KioskOrderStatusEnum.awaitingPayment:
        step = KioskStep.paying;
        _poll?.cancel();
        _poll = Timer.periodic(kioskPaymentPoll, (_) => unawaited(_follow()));
        _armIdle();
      case KioskOrderStatusEnum.atCounter:
      case KioskOrderStatusEnum.paid:
        _finished();
      case KioskOrderStatusEnum.canceled:
        _reset();
      default:
        break;
    }
  }

  bool _following = false;

  /// One read of the open QR: finish once the bank paid, hand the order to
  /// the counter once the QR ran out.
  Future<void> _follow() async {
    final current = order;
    if (current == null || _following || step != KioskStep.paying) return;
    _following = true;
    try {
      final next = await api.order(current.id);
      order = next;
      reconnecting = false;
      final payment = next.payment;
      if (next.status != KioskOrderStatusEnum.awaitingPayment) {
        _poll?.cancel();
        _afterOrder();
      } else if (payment?.state == KioskPaymentStateEnum.received) {
        _poll?.cancel();
        order = await api.finish(current.id, _uuid.v4());
        _afterOrder();
      } else if (payment?.state == KioskPaymentStateEnum.expired ||
          qrSecondsLeft <= 0) {
        _poll?.cancel();
        order = await api.payAtCounter(current.id, _uuid.v4());
        _afterOrder();
      }
    } on AppFailure catch (error) {
      if (isTransient(error)) {
        reconnecting = true;
      } else if (error case ConflictFailure(reason: 'kiosk_paid')) {
        // The bank paid while the QR was being given back: complete it.
        order = await _tryFinish(current.id);
        _afterOrder();
      } else {
        failure = error;
      }
    } finally {
      _following = false;
      _changed();
    }
  }

  Future<KioskOrder?> _tryFinish(String id) async {
    try {
      return await api.finish(id, _uuid.v4());
    } on AppFailure catch (error) {
      failure = error;
      return order;
    }
  }

  /// The guest pays at the counter instead of by QR.
  Future<void> payAtCounterInstead() async {
    final current = order;
    if (current == null || busy) return;
    busy = true;
    _poll?.cancel();
    _changed();
    try {
      order = await api.payAtCounter(current.id, _uuid.v4());
      _afterOrder();
    } on AppFailure catch (error) {
      if (error case ConflictFailure(reason: 'kiosk_paid')) {
        order = await _tryFinish(current.id);
        _afterOrder();
      } else {
        failure = error;
        _poll = Timer.periodic(kioskPaymentPoll, (_) => unawaited(_follow()));
      }
    } finally {
      busy = false;
      _changed();
    }
  }

  /// The guest walked away or chose to start over: an unpaid order is
  /// canceled on the server, and the kiosk returns to its welcome screen.
  Future<void> abandon() async {
    final current = order;
    askingStillThere = false;
    _stillThere?.cancel();
    if (current != null &&
        current.status == KioskOrderStatusEnum.awaitingPayment) {
      try {
        final canceled = await api.cancel(current.id, _uuid.v4());
        if (canceled.status == KioskOrderStatusEnum.paid) {
          order = canceled;
          _finished();
          _changed();
          return;
        }
      } on AppFailure catch (error) {
        if (error case ConflictFailure(reason: 'kiosk_paid')) {
          order = await _tryFinish(current.id);
          _afterOrder();
          _changed();
          return;
        }
        // Unreachable: the order stays for the counter, which settles it.
      }
    }
    _reset();
    _changed();
  }

  void _finished() {
    step = KioskStep.done;
    _poll?.cancel();
    _idle?.cancel();
    cart.clear();
    _doneTimer?.cancel();
    _doneTimer = Timer(kioskDoneShown, () {
      _reset();
      _changed();
    });
  }

  /// Back to the start, for the next guest.
  void next() {
    _reset();
    _changed();
  }

  void _reset({KioskStep to = KioskStep.welcome}) {
    _poll?.cancel();
    _idle?.cancel();
    _stillThere?.cancel();
    _doneTimer?.cancel();
    askingStillThere = false;
    cart.clear();
    order = null;
    failure = null;
    _placeKey = null;
    step = state?.open == false ? KioskStep.paused : to;
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final timer in [_idle, _stillThere, _poll, _statePoll, _doneTimer]) {
      timer?.cancel();
    }
    cart.dispose();
    super.dispose();
  }
}
