// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_handoff_order.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KioskHandoffOrderStatusEnum _$kioskHandoffOrderStatusEnum_draft =
    const KioskHandoffOrderStatusEnum._('draft');
const KioskHandoffOrderStatusEnum _$kioskHandoffOrderStatusEnum_editing =
    const KioskHandoffOrderStatusEnum._('editing');
const KioskHandoffOrderStatusEnum _$kioskHandoffOrderStatusEnum_parked =
    const KioskHandoffOrderStatusEnum._('parked');

KioskHandoffOrderStatusEnum _$kioskHandoffOrderStatusEnumValueOf(String name) {
  switch (name) {
    case 'draft':
      return _$kioskHandoffOrderStatusEnum_draft;
    case 'editing':
      return _$kioskHandoffOrderStatusEnum_editing;
    case 'parked':
      return _$kioskHandoffOrderStatusEnum_parked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KioskHandoffOrderStatusEnum>
    _$kioskHandoffOrderStatusEnumValues =
    BuiltSet<KioskHandoffOrderStatusEnum>(const <KioskHandoffOrderStatusEnum>[
  _$kioskHandoffOrderStatusEnum_draft,
  _$kioskHandoffOrderStatusEnum_editing,
  _$kioskHandoffOrderStatusEnum_parked,
]);

Serializer<KioskHandoffOrderStatusEnum>
    _$kioskHandoffOrderStatusEnumSerializer =
    _$KioskHandoffOrderStatusEnumSerializer();

class _$KioskHandoffOrderStatusEnumSerializer
    implements PrimitiveSerializer<KioskHandoffOrderStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'editing': 'editing',
    'parked': 'parked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'editing': 'editing',
    'parked': 'parked',
  };

  @override
  final Iterable<Type> types = const <Type>[KioskHandoffOrderStatusEnum];
  @override
  final String wireName = 'KioskHandoffOrderStatusEnum';

  @override
  Object serialize(Serializers serializers, KioskHandoffOrderStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KioskHandoffOrderStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KioskHandoffOrderStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KioskHandoffOrder extends KioskHandoffOrder {
  @override
  final String id;
  @override
  final String orderId;
  @override
  final String orderNumber;
  @override
  final int? callNumber;
  @override
  final KioskHandoffOrderStatusEnum status;
  @override
  final KioskRef? register;
  @override
  final String total;
  @override
  final String currency;
  @override
  final int itemCount;
  @override
  final String openedAt;
  @override
  final String waitingSince;
  @override
  final bool abandoned;

  factory _$KioskHandoffOrder(
          [void Function(KioskHandoffOrderBuilder)? updates]) =>
      (KioskHandoffOrderBuilder()..update(updates))._build();

  _$KioskHandoffOrder._(
      {required this.id,
      required this.orderId,
      required this.orderNumber,
      this.callNumber,
      required this.status,
      this.register,
      required this.total,
      required this.currency,
      required this.itemCount,
      required this.openedAt,
      required this.waitingSince,
      required this.abandoned})
      : super._();
  @override
  KioskHandoffOrder rebuild(void Function(KioskHandoffOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskHandoffOrderBuilder toBuilder() =>
      KioskHandoffOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskHandoffOrder &&
        id == other.id &&
        orderId == other.orderId &&
        orderNumber == other.orderNumber &&
        callNumber == other.callNumber &&
        status == other.status &&
        register == other.register &&
        total == other.total &&
        currency == other.currency &&
        itemCount == other.itemCount &&
        openedAt == other.openedAt &&
        waitingSince == other.waitingSince &&
        abandoned == other.abandoned;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, orderId.hashCode);
    _$hash = $jc(_$hash, orderNumber.hashCode);
    _$hash = $jc(_$hash, callNumber.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, register.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, itemCount.hashCode);
    _$hash = $jc(_$hash, openedAt.hashCode);
    _$hash = $jc(_$hash, waitingSince.hashCode);
    _$hash = $jc(_$hash, abandoned.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskHandoffOrder')
          ..add('id', id)
          ..add('orderId', orderId)
          ..add('orderNumber', orderNumber)
          ..add('callNumber', callNumber)
          ..add('status', status)
          ..add('register', register)
          ..add('total', total)
          ..add('currency', currency)
          ..add('itemCount', itemCount)
          ..add('openedAt', openedAt)
          ..add('waitingSince', waitingSince)
          ..add('abandoned', abandoned))
        .toString();
  }
}

class KioskHandoffOrderBuilder
    implements Builder<KioskHandoffOrder, KioskHandoffOrderBuilder> {
  _$KioskHandoffOrder? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _orderId;
  String? get orderId => _$this._orderId;
  set orderId(String? orderId) => _$this._orderId = orderId;

  String? _orderNumber;
  String? get orderNumber => _$this._orderNumber;
  set orderNumber(String? orderNumber) => _$this._orderNumber = orderNumber;

  int? _callNumber;
  int? get callNumber => _$this._callNumber;
  set callNumber(int? callNumber) => _$this._callNumber = callNumber;

  KioskHandoffOrderStatusEnum? _status;
  KioskHandoffOrderStatusEnum? get status => _$this._status;
  set status(KioskHandoffOrderStatusEnum? status) => _$this._status = status;

  KioskRefBuilder? _register;
  KioskRefBuilder get register => _$this._register ??= KioskRefBuilder();
  set register(KioskRefBuilder? register) => _$this._register = register;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  int? _itemCount;
  int? get itemCount => _$this._itemCount;
  set itemCount(int? itemCount) => _$this._itemCount = itemCount;

  String? _openedAt;
  String? get openedAt => _$this._openedAt;
  set openedAt(String? openedAt) => _$this._openedAt = openedAt;

  String? _waitingSince;
  String? get waitingSince => _$this._waitingSince;
  set waitingSince(String? waitingSince) => _$this._waitingSince = waitingSince;

  bool? _abandoned;
  bool? get abandoned => _$this._abandoned;
  set abandoned(bool? abandoned) => _$this._abandoned = abandoned;

  KioskHandoffOrderBuilder() {
    KioskHandoffOrder._defaults(this);
  }

  KioskHandoffOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _orderId = $v.orderId;
      _orderNumber = $v.orderNumber;
      _callNumber = $v.callNumber;
      _status = $v.status;
      _register = $v.register?.toBuilder();
      _total = $v.total;
      _currency = $v.currency;
      _itemCount = $v.itemCount;
      _openedAt = $v.openedAt;
      _waitingSince = $v.waitingSince;
      _abandoned = $v.abandoned;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskHandoffOrder other) {
    _$v = other as _$KioskHandoffOrder;
  }

  @override
  void update(void Function(KioskHandoffOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskHandoffOrder build() => _build();

  _$KioskHandoffOrder _build() {
    _$KioskHandoffOrder _$result;
    try {
      _$result = _$v ??
          _$KioskHandoffOrder._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'KioskHandoffOrder', 'id'),
            orderId: BuiltValueNullFieldError.checkNotNull(
                orderId, r'KioskHandoffOrder', 'orderId'),
            orderNumber: BuiltValueNullFieldError.checkNotNull(
                orderNumber, r'KioskHandoffOrder', 'orderNumber'),
            callNumber: callNumber,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'KioskHandoffOrder', 'status'),
            register: _register?.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'KioskHandoffOrder', 'total'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'KioskHandoffOrder', 'currency'),
            itemCount: BuiltValueNullFieldError.checkNotNull(
                itemCount, r'KioskHandoffOrder', 'itemCount'),
            openedAt: BuiltValueNullFieldError.checkNotNull(
                openedAt, r'KioskHandoffOrder', 'openedAt'),
            waitingSince: BuiltValueNullFieldError.checkNotNull(
                waitingSince, r'KioskHandoffOrder', 'waitingSince'),
            abandoned: BuiltValueNullFieldError.checkNotNull(
                abandoned, r'KioskHandoffOrder', 'abandoned'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'register';
        _register?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskHandoffOrder', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
