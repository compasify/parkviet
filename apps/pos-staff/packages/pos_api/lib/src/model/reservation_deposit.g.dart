// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_deposit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReservationDepositKindEnum _$reservationDepositKindEnum_cash =
    const ReservationDepositKindEnum._('cash');
const ReservationDepositKindEnum _$reservationDepositKindEnum_bankManual =
    const ReservationDepositKindEnum._('bankManual');

ReservationDepositKindEnum _$reservationDepositKindEnumValueOf(String name) {
  switch (name) {
    case 'cash':
      return _$reservationDepositKindEnum_cash;
    case 'bankManual':
      return _$reservationDepositKindEnum_bankManual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationDepositKindEnum> _$reservationDepositKindEnumValues =
    BuiltSet<ReservationDepositKindEnum>(const <ReservationDepositKindEnum>[
  _$reservationDepositKindEnum_cash,
  _$reservationDepositKindEnum_bankManual,
]);

const ReservationDepositStatusEnum _$reservationDepositStatusEnum_held =
    const ReservationDepositStatusEnum._('held');
const ReservationDepositStatusEnum _$reservationDepositStatusEnum_applied =
    const ReservationDepositStatusEnum._('applied');
const ReservationDepositStatusEnum _$reservationDepositStatusEnum_refunded =
    const ReservationDepositStatusEnum._('refunded');
const ReservationDepositStatusEnum _$reservationDepositStatusEnum_forfeited =
    const ReservationDepositStatusEnum._('forfeited');

ReservationDepositStatusEnum _$reservationDepositStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'held':
      return _$reservationDepositStatusEnum_held;
    case 'applied':
      return _$reservationDepositStatusEnum_applied;
    case 'refunded':
      return _$reservationDepositStatusEnum_refunded;
    case 'forfeited':
      return _$reservationDepositStatusEnum_forfeited;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationDepositStatusEnum>
    _$reservationDepositStatusEnumValues =
    BuiltSet<ReservationDepositStatusEnum>(const <ReservationDepositStatusEnum>[
  _$reservationDepositStatusEnum_held,
  _$reservationDepositStatusEnum_applied,
  _$reservationDepositStatusEnum_refunded,
  _$reservationDepositStatusEnum_forfeited,
]);

Serializer<ReservationDepositKindEnum> _$reservationDepositKindEnumSerializer =
    _$ReservationDepositKindEnumSerializer();
Serializer<ReservationDepositStatusEnum>
    _$reservationDepositStatusEnumSerializer =
    _$ReservationDepositStatusEnumSerializer();

class _$ReservationDepositKindEnumSerializer
    implements PrimitiveSerializer<ReservationDepositKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'bankManual': 'bank_manual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'bank_manual': 'bankManual',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationDepositKindEnum];
  @override
  final String wireName = 'ReservationDepositKindEnum';

  @override
  Object serialize(Serializers serializers, ReservationDepositKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationDepositKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationDepositKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationDepositStatusEnumSerializer
    implements PrimitiveSerializer<ReservationDepositStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'held': 'held',
    'applied': 'applied',
    'refunded': 'refunded',
    'forfeited': 'forfeited',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'held': 'held',
    'applied': 'applied',
    'refunded': 'refunded',
    'forfeited': 'forfeited',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationDepositStatusEnum];
  @override
  final String wireName = 'ReservationDepositStatusEnum';

  @override
  Object serialize(Serializers serializers, ReservationDepositStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationDepositStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationDepositStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationDeposit extends ReservationDeposit {
  @override
  final String id;
  @override
  final String reservationId;
  @override
  final String receivedFundsId;
  @override
  final ReservationDepositKindEnum kind;
  @override
  final String amount;
  @override
  final String currency;
  @override
  final ReservationDepositStatusEnum status;
  @override
  final String available;
  @override
  final String? resolutionOrderId;
  @override
  final String? liabilityPayoutId;
  @override
  final String? fundsAllocationId;
  @override
  final DateTime? receivedAt;
  @override
  final DateTime? resolvedAt;

  factory _$ReservationDeposit(
          [void Function(ReservationDepositBuilder)? updates]) =>
      (ReservationDepositBuilder()..update(updates))._build();

  _$ReservationDeposit._(
      {required this.id,
      required this.reservationId,
      required this.receivedFundsId,
      required this.kind,
      required this.amount,
      required this.currency,
      required this.status,
      required this.available,
      this.resolutionOrderId,
      this.liabilityPayoutId,
      this.fundsAllocationId,
      this.receivedAt,
      this.resolvedAt})
      : super._();
  @override
  ReservationDeposit rebuild(
          void Function(ReservationDepositBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDepositBuilder toBuilder() =>
      ReservationDepositBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDeposit &&
        id == other.id &&
        reservationId == other.reservationId &&
        receivedFundsId == other.receivedFundsId &&
        kind == other.kind &&
        amount == other.amount &&
        currency == other.currency &&
        status == other.status &&
        available == other.available &&
        resolutionOrderId == other.resolutionOrderId &&
        liabilityPayoutId == other.liabilityPayoutId &&
        fundsAllocationId == other.fundsAllocationId &&
        receivedAt == other.receivedAt &&
        resolvedAt == other.resolvedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, reservationId.hashCode);
    _$hash = $jc(_$hash, receivedFundsId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, available.hashCode);
    _$hash = $jc(_$hash, resolutionOrderId.hashCode);
    _$hash = $jc(_$hash, liabilityPayoutId.hashCode);
    _$hash = $jc(_$hash, fundsAllocationId.hashCode);
    _$hash = $jc(_$hash, receivedAt.hashCode);
    _$hash = $jc(_$hash, resolvedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDeposit')
          ..add('id', id)
          ..add('reservationId', reservationId)
          ..add('receivedFundsId', receivedFundsId)
          ..add('kind', kind)
          ..add('amount', amount)
          ..add('currency', currency)
          ..add('status', status)
          ..add('available', available)
          ..add('resolutionOrderId', resolutionOrderId)
          ..add('liabilityPayoutId', liabilityPayoutId)
          ..add('fundsAllocationId', fundsAllocationId)
          ..add('receivedAt', receivedAt)
          ..add('resolvedAt', resolvedAt))
        .toString();
  }
}

class ReservationDepositBuilder
    implements Builder<ReservationDeposit, ReservationDepositBuilder> {
  _$ReservationDeposit? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _reservationId;
  String? get reservationId => _$this._reservationId;
  set reservationId(String? reservationId) =>
      _$this._reservationId = reservationId;

  String? _receivedFundsId;
  String? get receivedFundsId => _$this._receivedFundsId;
  set receivedFundsId(String? receivedFundsId) =>
      _$this._receivedFundsId = receivedFundsId;

  ReservationDepositKindEnum? _kind;
  ReservationDepositKindEnum? get kind => _$this._kind;
  set kind(ReservationDepositKindEnum? kind) => _$this._kind = kind;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  ReservationDepositStatusEnum? _status;
  ReservationDepositStatusEnum? get status => _$this._status;
  set status(ReservationDepositStatusEnum? status) => _$this._status = status;

  String? _available;
  String? get available => _$this._available;
  set available(String? available) => _$this._available = available;

  String? _resolutionOrderId;
  String? get resolutionOrderId => _$this._resolutionOrderId;
  set resolutionOrderId(String? resolutionOrderId) =>
      _$this._resolutionOrderId = resolutionOrderId;

  String? _liabilityPayoutId;
  String? get liabilityPayoutId => _$this._liabilityPayoutId;
  set liabilityPayoutId(String? liabilityPayoutId) =>
      _$this._liabilityPayoutId = liabilityPayoutId;

  String? _fundsAllocationId;
  String? get fundsAllocationId => _$this._fundsAllocationId;
  set fundsAllocationId(String? fundsAllocationId) =>
      _$this._fundsAllocationId = fundsAllocationId;

  DateTime? _receivedAt;
  DateTime? get receivedAt => _$this._receivedAt;
  set receivedAt(DateTime? receivedAt) => _$this._receivedAt = receivedAt;

  DateTime? _resolvedAt;
  DateTime? get resolvedAt => _$this._resolvedAt;
  set resolvedAt(DateTime? resolvedAt) => _$this._resolvedAt = resolvedAt;

  ReservationDepositBuilder() {
    ReservationDeposit._defaults(this);
  }

  ReservationDepositBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _reservationId = $v.reservationId;
      _receivedFundsId = $v.receivedFundsId;
      _kind = $v.kind;
      _amount = $v.amount;
      _currency = $v.currency;
      _status = $v.status;
      _available = $v.available;
      _resolutionOrderId = $v.resolutionOrderId;
      _liabilityPayoutId = $v.liabilityPayoutId;
      _fundsAllocationId = $v.fundsAllocationId;
      _receivedAt = $v.receivedAt;
      _resolvedAt = $v.resolvedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDeposit other) {
    _$v = other as _$ReservationDeposit;
  }

  @override
  void update(void Function(ReservationDepositBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDeposit build() => _build();

  _$ReservationDeposit _build() {
    final _$result = _$v ??
        _$ReservationDeposit._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ReservationDeposit', 'id'),
          reservationId: BuiltValueNullFieldError.checkNotNull(
              reservationId, r'ReservationDeposit', 'reservationId'),
          receivedFundsId: BuiltValueNullFieldError.checkNotNull(
              receivedFundsId, r'ReservationDeposit', 'receivedFundsId'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'ReservationDeposit', 'kind'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'ReservationDeposit', 'amount'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'ReservationDeposit', 'currency'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ReservationDeposit', 'status'),
          available: BuiltValueNullFieldError.checkNotNull(
              available, r'ReservationDeposit', 'available'),
          resolutionOrderId: resolutionOrderId,
          liabilityPayoutId: liabilityPayoutId,
          fundsAllocationId: fundsAllocationId,
          receivedAt: receivedAt,
          resolvedAt: resolvedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
