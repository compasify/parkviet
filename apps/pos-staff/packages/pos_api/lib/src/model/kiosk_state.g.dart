// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KioskStateReasonEnum _$kioskStateReasonEnum_kioskUnprovisioned =
    const KioskStateReasonEnum._('kioskUnprovisioned');
const KioskStateReasonEnum _$kioskStateReasonEnum_moduleDisabled =
    const KioskStateReasonEnum._('moduleDisabled');
const KioskStateReasonEnum _$kioskStateReasonEnum_registerDisabled =
    const KioskStateReasonEnum._('registerDisabled');
const KioskStateReasonEnum _$kioskStateReasonEnum_shiftClosed =
    const KioskStateReasonEnum._('shiftClosed');

KioskStateReasonEnum _$kioskStateReasonEnumValueOf(String name) {
  switch (name) {
    case 'kioskUnprovisioned':
      return _$kioskStateReasonEnum_kioskUnprovisioned;
    case 'moduleDisabled':
      return _$kioskStateReasonEnum_moduleDisabled;
    case 'registerDisabled':
      return _$kioskStateReasonEnum_registerDisabled;
    case 'shiftClosed':
      return _$kioskStateReasonEnum_shiftClosed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KioskStateReasonEnum> _$kioskStateReasonEnumValues =
    BuiltSet<KioskStateReasonEnum>(const <KioskStateReasonEnum>[
  _$kioskStateReasonEnum_kioskUnprovisioned,
  _$kioskStateReasonEnum_moduleDisabled,
  _$kioskStateReasonEnum_registerDisabled,
  _$kioskStateReasonEnum_shiftClosed,
]);

Serializer<KioskStateReasonEnum> _$kioskStateReasonEnumSerializer =
    _$KioskStateReasonEnumSerializer();

class _$KioskStateReasonEnumSerializer
    implements PrimitiveSerializer<KioskStateReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'kioskUnprovisioned': 'kiosk_unprovisioned',
    'moduleDisabled': 'module_disabled',
    'registerDisabled': 'register_disabled',
    'shiftClosed': 'shift_closed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'kiosk_unprovisioned': 'kioskUnprovisioned',
    'module_disabled': 'moduleDisabled',
    'register_disabled': 'registerDisabled',
    'shift_closed': 'shiftClosed',
  };

  @override
  final Iterable<Type> types = const <Type>[KioskStateReasonEnum];
  @override
  final String wireName = 'KioskStateReasonEnum';

  @override
  Object serialize(Serializers serializers, KioskStateReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KioskStateReasonEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KioskStateReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KioskState extends KioskState {
  @override
  final bool open;
  @override
  final KioskStateReasonEnum? reason;
  @override
  final KioskRef branch;
  @override
  final KioskRef? register;
  @override
  final String currency;
  @override
  final int idleSeconds;
  @override
  final int qrTimeoutSeconds;
  @override
  final bool kitchenBeforePayment;
  @override
  final KioskStatePayments payments;

  factory _$KioskState([void Function(KioskStateBuilder)? updates]) =>
      (KioskStateBuilder()..update(updates))._build();

  _$KioskState._(
      {required this.open,
      this.reason,
      required this.branch,
      this.register,
      required this.currency,
      required this.idleSeconds,
      required this.qrTimeoutSeconds,
      required this.kitchenBeforePayment,
      required this.payments})
      : super._();
  @override
  KioskState rebuild(void Function(KioskStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskStateBuilder toBuilder() => KioskStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskState &&
        open == other.open &&
        reason == other.reason &&
        branch == other.branch &&
        register == other.register &&
        currency == other.currency &&
        idleSeconds == other.idleSeconds &&
        qrTimeoutSeconds == other.qrTimeoutSeconds &&
        kitchenBeforePayment == other.kitchenBeforePayment &&
        payments == other.payments;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, open.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, branch.hashCode);
    _$hash = $jc(_$hash, register.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, idleSeconds.hashCode);
    _$hash = $jc(_$hash, qrTimeoutSeconds.hashCode);
    _$hash = $jc(_$hash, kitchenBeforePayment.hashCode);
    _$hash = $jc(_$hash, payments.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskState')
          ..add('open', open)
          ..add('reason', reason)
          ..add('branch', branch)
          ..add('register', register)
          ..add('currency', currency)
          ..add('idleSeconds', idleSeconds)
          ..add('qrTimeoutSeconds', qrTimeoutSeconds)
          ..add('kitchenBeforePayment', kitchenBeforePayment)
          ..add('payments', payments))
        .toString();
  }
}

class KioskStateBuilder implements Builder<KioskState, KioskStateBuilder> {
  _$KioskState? _$v;

  bool? _open;
  bool? get open => _$this._open;
  set open(bool? open) => _$this._open = open;

  KioskStateReasonEnum? _reason;
  KioskStateReasonEnum? get reason => _$this._reason;
  set reason(KioskStateReasonEnum? reason) => _$this._reason = reason;

  KioskRefBuilder? _branch;
  KioskRefBuilder get branch => _$this._branch ??= KioskRefBuilder();
  set branch(KioskRefBuilder? branch) => _$this._branch = branch;

  KioskRefBuilder? _register;
  KioskRefBuilder get register => _$this._register ??= KioskRefBuilder();
  set register(KioskRefBuilder? register) => _$this._register = register;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  int? _idleSeconds;
  int? get idleSeconds => _$this._idleSeconds;
  set idleSeconds(int? idleSeconds) => _$this._idleSeconds = idleSeconds;

  int? _qrTimeoutSeconds;
  int? get qrTimeoutSeconds => _$this._qrTimeoutSeconds;
  set qrTimeoutSeconds(int? qrTimeoutSeconds) =>
      _$this._qrTimeoutSeconds = qrTimeoutSeconds;

  bool? _kitchenBeforePayment;
  bool? get kitchenBeforePayment => _$this._kitchenBeforePayment;
  set kitchenBeforePayment(bool? kitchenBeforePayment) =>
      _$this._kitchenBeforePayment = kitchenBeforePayment;

  KioskStatePaymentsBuilder? _payments;
  KioskStatePaymentsBuilder get payments =>
      _$this._payments ??= KioskStatePaymentsBuilder();
  set payments(KioskStatePaymentsBuilder? payments) =>
      _$this._payments = payments;

  KioskStateBuilder() {
    KioskState._defaults(this);
  }

  KioskStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _open = $v.open;
      _reason = $v.reason;
      _branch = $v.branch.toBuilder();
      _register = $v.register?.toBuilder();
      _currency = $v.currency;
      _idleSeconds = $v.idleSeconds;
      _qrTimeoutSeconds = $v.qrTimeoutSeconds;
      _kitchenBeforePayment = $v.kitchenBeforePayment;
      _payments = $v.payments.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskState other) {
    _$v = other as _$KioskState;
  }

  @override
  void update(void Function(KioskStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskState build() => _build();

  _$KioskState _build() {
    _$KioskState _$result;
    try {
      _$result = _$v ??
          _$KioskState._(
            open: BuiltValueNullFieldError.checkNotNull(
                open, r'KioskState', 'open'),
            reason: reason,
            branch: branch.build(),
            register: _register?.build(),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'KioskState', 'currency'),
            idleSeconds: BuiltValueNullFieldError.checkNotNull(
                idleSeconds, r'KioskState', 'idleSeconds'),
            qrTimeoutSeconds: BuiltValueNullFieldError.checkNotNull(
                qrTimeoutSeconds, r'KioskState', 'qrTimeoutSeconds'),
            kitchenBeforePayment: BuiltValueNullFieldError.checkNotNull(
                kitchenBeforePayment, r'KioskState', 'kitchenBeforePayment'),
            payments: payments.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'branch';
        branch.build();
        _$failedField = 'register';
        _register?.build();

        _$failedField = 'payments';
        payments.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
