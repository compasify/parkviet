// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_payment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KioskPaymentKindEnum _$kioskPaymentKindEnum_vietqr =
    const KioskPaymentKindEnum._('vietqr');

KioskPaymentKindEnum _$kioskPaymentKindEnumValueOf(String name) {
  switch (name) {
    case 'vietqr':
      return _$kioskPaymentKindEnum_vietqr;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KioskPaymentKindEnum> _$kioskPaymentKindEnumValues =
    BuiltSet<KioskPaymentKindEnum>(const <KioskPaymentKindEnum>[
  _$kioskPaymentKindEnum_vietqr,
]);

const KioskPaymentStateEnum _$kioskPaymentStateEnum_waiting =
    const KioskPaymentStateEnum._('waiting');
const KioskPaymentStateEnum _$kioskPaymentStateEnum_received =
    const KioskPaymentStateEnum._('received');
const KioskPaymentStateEnum _$kioskPaymentStateEnum_expired =
    const KioskPaymentStateEnum._('expired');

KioskPaymentStateEnum _$kioskPaymentStateEnumValueOf(String name) {
  switch (name) {
    case 'waiting':
      return _$kioskPaymentStateEnum_waiting;
    case 'received':
      return _$kioskPaymentStateEnum_received;
    case 'expired':
      return _$kioskPaymentStateEnum_expired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KioskPaymentStateEnum> _$kioskPaymentStateEnumValues =
    BuiltSet<KioskPaymentStateEnum>(const <KioskPaymentStateEnum>[
  _$kioskPaymentStateEnum_waiting,
  _$kioskPaymentStateEnum_received,
  _$kioskPaymentStateEnum_expired,
]);

Serializer<KioskPaymentKindEnum> _$kioskPaymentKindEnumSerializer =
    _$KioskPaymentKindEnumSerializer();
Serializer<KioskPaymentStateEnum> _$kioskPaymentStateEnumSerializer =
    _$KioskPaymentStateEnumSerializer();

class _$KioskPaymentKindEnumSerializer
    implements PrimitiveSerializer<KioskPaymentKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'vietqr': 'vietqr',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'vietqr': 'vietqr',
  };

  @override
  final Iterable<Type> types = const <Type>[KioskPaymentKindEnum];
  @override
  final String wireName = 'KioskPaymentKindEnum';

  @override
  Object serialize(Serializers serializers, KioskPaymentKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KioskPaymentKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KioskPaymentKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KioskPaymentStateEnumSerializer
    implements PrimitiveSerializer<KioskPaymentStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'waiting': 'waiting',
    'received': 'received',
    'expired': 'expired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'waiting': 'waiting',
    'received': 'received',
    'expired': 'expired',
  };

  @override
  final Iterable<Type> types = const <Type>[KioskPaymentStateEnum];
  @override
  final String wireName = 'KioskPaymentStateEnum';

  @override
  Object serialize(Serializers serializers, KioskPaymentStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KioskPaymentStateEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KioskPaymentStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KioskPayment extends KioskPayment {
  @override
  final KioskPaymentKindEnum kind;
  @override
  final String attemptId;
  @override
  final String amount;
  @override
  final KioskPaymentStateEnum state;
  @override
  final DateTime expiresAt;
  @override
  final KioskQr? qr;

  factory _$KioskPayment([void Function(KioskPaymentBuilder)? updates]) =>
      (KioskPaymentBuilder()..update(updates))._build();

  _$KioskPayment._(
      {required this.kind,
      required this.attemptId,
      required this.amount,
      required this.state,
      required this.expiresAt,
      this.qr})
      : super._();
  @override
  KioskPayment rebuild(void Function(KioskPaymentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskPaymentBuilder toBuilder() => KioskPaymentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskPayment &&
        kind == other.kind &&
        attemptId == other.attemptId &&
        amount == other.amount &&
        state == other.state &&
        expiresAt == other.expiresAt &&
        qr == other.qr;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, attemptId.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, qr.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskPayment')
          ..add('kind', kind)
          ..add('attemptId', attemptId)
          ..add('amount', amount)
          ..add('state', state)
          ..add('expiresAt', expiresAt)
          ..add('qr', qr))
        .toString();
  }
}

class KioskPaymentBuilder
    implements Builder<KioskPayment, KioskPaymentBuilder> {
  _$KioskPayment? _$v;

  KioskPaymentKindEnum? _kind;
  KioskPaymentKindEnum? get kind => _$this._kind;
  set kind(KioskPaymentKindEnum? kind) => _$this._kind = kind;

  String? _attemptId;
  String? get attemptId => _$this._attemptId;
  set attemptId(String? attemptId) => _$this._attemptId = attemptId;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  KioskPaymentStateEnum? _state;
  KioskPaymentStateEnum? get state => _$this._state;
  set state(KioskPaymentStateEnum? state) => _$this._state = state;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  KioskQrBuilder? _qr;
  KioskQrBuilder get qr => _$this._qr ??= KioskQrBuilder();
  set qr(KioskQrBuilder? qr) => _$this._qr = qr;

  KioskPaymentBuilder() {
    KioskPayment._defaults(this);
  }

  KioskPaymentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _attemptId = $v.attemptId;
      _amount = $v.amount;
      _state = $v.state;
      _expiresAt = $v.expiresAt;
      _qr = $v.qr?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskPayment other) {
    _$v = other as _$KioskPayment;
  }

  @override
  void update(void Function(KioskPaymentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskPayment build() => _build();

  _$KioskPayment _build() {
    _$KioskPayment _$result;
    try {
      _$result = _$v ??
          _$KioskPayment._(
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'KioskPayment', 'kind'),
            attemptId: BuiltValueNullFieldError.checkNotNull(
                attemptId, r'KioskPayment', 'attemptId'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'KioskPayment', 'amount'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'KioskPayment', 'state'),
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'KioskPayment', 'expiresAt'),
            qr: _qr?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'qr';
        _qr?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskPayment', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
