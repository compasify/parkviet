// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_order.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KioskOrderStatusEnum _$kioskOrderStatusEnum_draft =
    const KioskOrderStatusEnum._('draft');
const KioskOrderStatusEnum _$kioskOrderStatusEnum_awaitingPayment =
    const KioskOrderStatusEnum._('awaitingPayment');
const KioskOrderStatusEnum _$kioskOrderStatusEnum_atCounter =
    const KioskOrderStatusEnum._('atCounter');
const KioskOrderStatusEnum _$kioskOrderStatusEnum_paid =
    const KioskOrderStatusEnum._('paid');
const KioskOrderStatusEnum _$kioskOrderStatusEnum_canceled =
    const KioskOrderStatusEnum._('canceled');

KioskOrderStatusEnum _$kioskOrderStatusEnumValueOf(String name) {
  switch (name) {
    case 'draft':
      return _$kioskOrderStatusEnum_draft;
    case 'awaitingPayment':
      return _$kioskOrderStatusEnum_awaitingPayment;
    case 'atCounter':
      return _$kioskOrderStatusEnum_atCounter;
    case 'paid':
      return _$kioskOrderStatusEnum_paid;
    case 'canceled':
      return _$kioskOrderStatusEnum_canceled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KioskOrderStatusEnum> _$kioskOrderStatusEnumValues =
    BuiltSet<KioskOrderStatusEnum>(const <KioskOrderStatusEnum>[
  _$kioskOrderStatusEnum_draft,
  _$kioskOrderStatusEnum_awaitingPayment,
  _$kioskOrderStatusEnum_atCounter,
  _$kioskOrderStatusEnum_paid,
  _$kioskOrderStatusEnum_canceled,
]);

Serializer<KioskOrderStatusEnum> _$kioskOrderStatusEnumSerializer =
    _$KioskOrderStatusEnumSerializer();

class _$KioskOrderStatusEnumSerializer
    implements PrimitiveSerializer<KioskOrderStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'awaitingPayment': 'awaiting_payment',
    'atCounter': 'at_counter',
    'paid': 'paid',
    'canceled': 'canceled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'awaiting_payment': 'awaitingPayment',
    'at_counter': 'atCounter',
    'paid': 'paid',
    'canceled': 'canceled',
  };

  @override
  final Iterable<Type> types = const <Type>[KioskOrderStatusEnum];
  @override
  final String wireName = 'KioskOrderStatusEnum';

  @override
  Object serialize(Serializers serializers, KioskOrderStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KioskOrderStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KioskOrderStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KioskOrder extends KioskOrder {
  @override
  final String id;
  @override
  final KioskOrderStatusEnum status;
  @override
  final int? callNumber;
  @override
  final String orderNumber;
  @override
  final String currency;
  @override
  final String total;
  @override
  final String itemTotal;
  @override
  final BuiltList<KioskOrderLine> lines;
  @override
  final KioskPayment? payment;
  @override
  final String deviceId;

  factory _$KioskOrder([void Function(KioskOrderBuilder)? updates]) =>
      (KioskOrderBuilder()..update(updates))._build();

  _$KioskOrder._(
      {required this.id,
      required this.status,
      this.callNumber,
      required this.orderNumber,
      required this.currency,
      required this.total,
      required this.itemTotal,
      required this.lines,
      this.payment,
      required this.deviceId})
      : super._();
  @override
  KioskOrder rebuild(void Function(KioskOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskOrderBuilder toBuilder() => KioskOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskOrder &&
        id == other.id &&
        status == other.status &&
        callNumber == other.callNumber &&
        orderNumber == other.orderNumber &&
        currency == other.currency &&
        total == other.total &&
        itemTotal == other.itemTotal &&
        lines == other.lines &&
        payment == other.payment &&
        deviceId == other.deviceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, callNumber.hashCode);
    _$hash = $jc(_$hash, orderNumber.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, itemTotal.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jc(_$hash, payment.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskOrder')
          ..add('id', id)
          ..add('status', status)
          ..add('callNumber', callNumber)
          ..add('orderNumber', orderNumber)
          ..add('currency', currency)
          ..add('total', total)
          ..add('itemTotal', itemTotal)
          ..add('lines', lines)
          ..add('payment', payment)
          ..add('deviceId', deviceId))
        .toString();
  }
}

class KioskOrderBuilder implements Builder<KioskOrder, KioskOrderBuilder> {
  _$KioskOrder? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  KioskOrderStatusEnum? _status;
  KioskOrderStatusEnum? get status => _$this._status;
  set status(KioskOrderStatusEnum? status) => _$this._status = status;

  int? _callNumber;
  int? get callNumber => _$this._callNumber;
  set callNumber(int? callNumber) => _$this._callNumber = callNumber;

  String? _orderNumber;
  String? get orderNumber => _$this._orderNumber;
  set orderNumber(String? orderNumber) => _$this._orderNumber = orderNumber;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  String? _itemTotal;
  String? get itemTotal => _$this._itemTotal;
  set itemTotal(String? itemTotal) => _$this._itemTotal = itemTotal;

  ListBuilder<KioskOrderLine>? _lines;
  ListBuilder<KioskOrderLine> get lines =>
      _$this._lines ??= ListBuilder<KioskOrderLine>();
  set lines(ListBuilder<KioskOrderLine>? lines) => _$this._lines = lines;

  KioskPaymentBuilder? _payment;
  KioskPaymentBuilder get payment => _$this._payment ??= KioskPaymentBuilder();
  set payment(KioskPaymentBuilder? payment) => _$this._payment = payment;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  KioskOrderBuilder() {
    KioskOrder._defaults(this);
  }

  KioskOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _callNumber = $v.callNumber;
      _orderNumber = $v.orderNumber;
      _currency = $v.currency;
      _total = $v.total;
      _itemTotal = $v.itemTotal;
      _lines = $v.lines.toBuilder();
      _payment = $v.payment?.toBuilder();
      _deviceId = $v.deviceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskOrder other) {
    _$v = other as _$KioskOrder;
  }

  @override
  void update(void Function(KioskOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskOrder build() => _build();

  _$KioskOrder _build() {
    _$KioskOrder _$result;
    try {
      _$result = _$v ??
          _$KioskOrder._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'KioskOrder', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'KioskOrder', 'status'),
            callNumber: callNumber,
            orderNumber: BuiltValueNullFieldError.checkNotNull(
                orderNumber, r'KioskOrder', 'orderNumber'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'KioskOrder', 'currency'),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'KioskOrder', 'total'),
            itemTotal: BuiltValueNullFieldError.checkNotNull(
                itemTotal, r'KioskOrder', 'itemTotal'),
            lines: lines.build(),
            payment: _payment?.build(),
            deviceId: BuiltValueNullFieldError.checkNotNull(
                deviceId, r'KioskOrder', 'deviceId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lines';
        lines.build();
        _$failedField = 'payment';
        _payment?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskOrder', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
