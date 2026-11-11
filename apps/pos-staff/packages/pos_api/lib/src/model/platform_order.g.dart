// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_order.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlatformOrderPlatformEnum _$platformOrderPlatformEnum_grabfood =
    const PlatformOrderPlatformEnum._('grabfood');
const PlatformOrderPlatformEnum _$platformOrderPlatformEnum_shopeefood =
    const PlatformOrderPlatformEnum._('shopeefood');

PlatformOrderPlatformEnum _$platformOrderPlatformEnumValueOf(String name) {
  switch (name) {
    case 'grabfood':
      return _$platformOrderPlatformEnum_grabfood;
    case 'shopeefood':
      return _$platformOrderPlatformEnum_shopeefood;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlatformOrderPlatformEnum> _$platformOrderPlatformEnumValues =
    BuiltSet<PlatformOrderPlatformEnum>(const <PlatformOrderPlatformEnum>[
  _$platformOrderPlatformEnum_grabfood,
  _$platformOrderPlatformEnum_shopeefood,
]);

const PlatformOrderStatusEnum _$platformOrderStatusEnum_accepted =
    const PlatformOrderStatusEnum._('accepted');
const PlatformOrderStatusEnum _$platformOrderStatusEnum_ready =
    const PlatformOrderStatusEnum._('ready');
const PlatformOrderStatusEnum _$platformOrderStatusEnum_completed =
    const PlatformOrderStatusEnum._('completed');
const PlatformOrderStatusEnum _$platformOrderStatusEnum_canceled =
    const PlatformOrderStatusEnum._('canceled');

PlatformOrderStatusEnum _$platformOrderStatusEnumValueOf(String name) {
  switch (name) {
    case 'accepted':
      return _$platformOrderStatusEnum_accepted;
    case 'ready':
      return _$platformOrderStatusEnum_ready;
    case 'completed':
      return _$platformOrderStatusEnum_completed;
    case 'canceled':
      return _$platformOrderStatusEnum_canceled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlatformOrderStatusEnum> _$platformOrderStatusEnumValues =
    BuiltSet<PlatformOrderStatusEnum>(const <PlatformOrderStatusEnum>[
  _$platformOrderStatusEnum_accepted,
  _$platformOrderStatusEnum_ready,
  _$platformOrderStatusEnum_completed,
  _$platformOrderStatusEnum_canceled,
]);

Serializer<PlatformOrderPlatformEnum> _$platformOrderPlatformEnumSerializer =
    _$PlatformOrderPlatformEnumSerializer();
Serializer<PlatformOrderStatusEnum> _$platformOrderStatusEnumSerializer =
    _$PlatformOrderStatusEnumSerializer();

class _$PlatformOrderPlatformEnumSerializer
    implements PrimitiveSerializer<PlatformOrderPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };

  @override
  final Iterable<Type> types = const <Type>[PlatformOrderPlatformEnum];
  @override
  final String wireName = 'PlatformOrderPlatformEnum';

  @override
  Object serialize(Serializers serializers, PlatformOrderPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlatformOrderPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlatformOrderPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlatformOrderStatusEnumSerializer
    implements PrimitiveSerializer<PlatformOrderStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'accepted': 'accepted',
    'ready': 'ready',
    'completed': 'completed',
    'canceled': 'canceled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'accepted': 'accepted',
    'ready': 'ready',
    'completed': 'completed',
    'canceled': 'canceled',
  };

  @override
  final Iterable<Type> types = const <Type>[PlatformOrderStatusEnum];
  @override
  final String wireName = 'PlatformOrderStatusEnum';

  @override
  Object serialize(Serializers serializers, PlatformOrderStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlatformOrderStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlatformOrderStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlatformOrder extends PlatformOrder {
  @override
  final String id;
  @override
  final String workspaceId;
  @override
  final String orderId;
  @override
  final int? orderNumber;
  @override
  final Date? businessDate;
  @override
  final PlatformOrderPlatformEnum platform;
  @override
  final String platformOrderRef;
  @override
  final String? pickupCode;
  @override
  final PlatformOrderStatusEnum status;
  @override
  final String grossAmount;
  @override
  final String commissionRate;
  @override
  final String commissionAmount;
  @override
  final String netAmount;
  @override
  final String currency;
  @override
  final DateTime? enteredAt;
  @override
  final DateTime? readyAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? canceledAt;
  @override
  final String? cancelReason;
  @override
  final DateTime? settledAt;
  @override
  final String? settlementReference;
  @override
  final BuiltList<PlatformOrderItem> items;

  factory _$PlatformOrder([void Function(PlatformOrderBuilder)? updates]) =>
      (PlatformOrderBuilder()..update(updates))._build();

  _$PlatformOrder._(
      {required this.id,
      required this.workspaceId,
      required this.orderId,
      this.orderNumber,
      this.businessDate,
      required this.platform,
      required this.platformOrderRef,
      this.pickupCode,
      required this.status,
      required this.grossAmount,
      required this.commissionRate,
      required this.commissionAmount,
      required this.netAmount,
      required this.currency,
      this.enteredAt,
      this.readyAt,
      this.completedAt,
      this.canceledAt,
      this.cancelReason,
      this.settledAt,
      this.settlementReference,
      required this.items})
      : super._();
  @override
  PlatformOrder rebuild(void Function(PlatformOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformOrderBuilder toBuilder() => PlatformOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformOrder &&
        id == other.id &&
        workspaceId == other.workspaceId &&
        orderId == other.orderId &&
        orderNumber == other.orderNumber &&
        businessDate == other.businessDate &&
        platform == other.platform &&
        platformOrderRef == other.platformOrderRef &&
        pickupCode == other.pickupCode &&
        status == other.status &&
        grossAmount == other.grossAmount &&
        commissionRate == other.commissionRate &&
        commissionAmount == other.commissionAmount &&
        netAmount == other.netAmount &&
        currency == other.currency &&
        enteredAt == other.enteredAt &&
        readyAt == other.readyAt &&
        completedAt == other.completedAt &&
        canceledAt == other.canceledAt &&
        cancelReason == other.cancelReason &&
        settledAt == other.settledAt &&
        settlementReference == other.settlementReference &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, orderId.hashCode);
    _$hash = $jc(_$hash, orderNumber.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, platformOrderRef.hashCode);
    _$hash = $jc(_$hash, pickupCode.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, grossAmount.hashCode);
    _$hash = $jc(_$hash, commissionRate.hashCode);
    _$hash = $jc(_$hash, commissionAmount.hashCode);
    _$hash = $jc(_$hash, netAmount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, enteredAt.hashCode);
    _$hash = $jc(_$hash, readyAt.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, canceledAt.hashCode);
    _$hash = $jc(_$hash, cancelReason.hashCode);
    _$hash = $jc(_$hash, settledAt.hashCode);
    _$hash = $jc(_$hash, settlementReference.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformOrder')
          ..add('id', id)
          ..add('workspaceId', workspaceId)
          ..add('orderId', orderId)
          ..add('orderNumber', orderNumber)
          ..add('businessDate', businessDate)
          ..add('platform', platform)
          ..add('platformOrderRef', platformOrderRef)
          ..add('pickupCode', pickupCode)
          ..add('status', status)
          ..add('grossAmount', grossAmount)
          ..add('commissionRate', commissionRate)
          ..add('commissionAmount', commissionAmount)
          ..add('netAmount', netAmount)
          ..add('currency', currency)
          ..add('enteredAt', enteredAt)
          ..add('readyAt', readyAt)
          ..add('completedAt', completedAt)
          ..add('canceledAt', canceledAt)
          ..add('cancelReason', cancelReason)
          ..add('settledAt', settledAt)
          ..add('settlementReference', settlementReference)
          ..add('items', items))
        .toString();
  }
}

class PlatformOrderBuilder
    implements Builder<PlatformOrder, PlatformOrderBuilder> {
  _$PlatformOrder? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _orderId;
  String? get orderId => _$this._orderId;
  set orderId(String? orderId) => _$this._orderId = orderId;

  int? _orderNumber;
  int? get orderNumber => _$this._orderNumber;
  set orderNumber(int? orderNumber) => _$this._orderNumber = orderNumber;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  PlatformOrderPlatformEnum? _platform;
  PlatformOrderPlatformEnum? get platform => _$this._platform;
  set platform(PlatformOrderPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _platformOrderRef;
  String? get platformOrderRef => _$this._platformOrderRef;
  set platformOrderRef(String? platformOrderRef) =>
      _$this._platformOrderRef = platformOrderRef;

  String? _pickupCode;
  String? get pickupCode => _$this._pickupCode;
  set pickupCode(String? pickupCode) => _$this._pickupCode = pickupCode;

  PlatformOrderStatusEnum? _status;
  PlatformOrderStatusEnum? get status => _$this._status;
  set status(PlatformOrderStatusEnum? status) => _$this._status = status;

  String? _grossAmount;
  String? get grossAmount => _$this._grossAmount;
  set grossAmount(String? grossAmount) => _$this._grossAmount = grossAmount;

  String? _commissionRate;
  String? get commissionRate => _$this._commissionRate;
  set commissionRate(String? commissionRate) =>
      _$this._commissionRate = commissionRate;

  String? _commissionAmount;
  String? get commissionAmount => _$this._commissionAmount;
  set commissionAmount(String? commissionAmount) =>
      _$this._commissionAmount = commissionAmount;

  String? _netAmount;
  String? get netAmount => _$this._netAmount;
  set netAmount(String? netAmount) => _$this._netAmount = netAmount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  DateTime? _enteredAt;
  DateTime? get enteredAt => _$this._enteredAt;
  set enteredAt(DateTime? enteredAt) => _$this._enteredAt = enteredAt;

  DateTime? _readyAt;
  DateTime? get readyAt => _$this._readyAt;
  set readyAt(DateTime? readyAt) => _$this._readyAt = readyAt;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  DateTime? _canceledAt;
  DateTime? get canceledAt => _$this._canceledAt;
  set canceledAt(DateTime? canceledAt) => _$this._canceledAt = canceledAt;

  String? _cancelReason;
  String? get cancelReason => _$this._cancelReason;
  set cancelReason(String? cancelReason) => _$this._cancelReason = cancelReason;

  DateTime? _settledAt;
  DateTime? get settledAt => _$this._settledAt;
  set settledAt(DateTime? settledAt) => _$this._settledAt = settledAt;

  String? _settlementReference;
  String? get settlementReference => _$this._settlementReference;
  set settlementReference(String? settlementReference) =>
      _$this._settlementReference = settlementReference;

  ListBuilder<PlatformOrderItem>? _items;
  ListBuilder<PlatformOrderItem> get items =>
      _$this._items ??= ListBuilder<PlatformOrderItem>();
  set items(ListBuilder<PlatformOrderItem>? items) => _$this._items = items;

  PlatformOrderBuilder() {
    PlatformOrder._defaults(this);
  }

  PlatformOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _workspaceId = $v.workspaceId;
      _orderId = $v.orderId;
      _orderNumber = $v.orderNumber;
      _businessDate = $v.businessDate;
      _platform = $v.platform;
      _platformOrderRef = $v.platformOrderRef;
      _pickupCode = $v.pickupCode;
      _status = $v.status;
      _grossAmount = $v.grossAmount;
      _commissionRate = $v.commissionRate;
      _commissionAmount = $v.commissionAmount;
      _netAmount = $v.netAmount;
      _currency = $v.currency;
      _enteredAt = $v.enteredAt;
      _readyAt = $v.readyAt;
      _completedAt = $v.completedAt;
      _canceledAt = $v.canceledAt;
      _cancelReason = $v.cancelReason;
      _settledAt = $v.settledAt;
      _settlementReference = $v.settlementReference;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformOrder other) {
    _$v = other as _$PlatformOrder;
  }

  @override
  void update(void Function(PlatformOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformOrder build() => _build();

  _$PlatformOrder _build() {
    _$PlatformOrder _$result;
    try {
      _$result = _$v ??
          _$PlatformOrder._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PlatformOrder', 'id'),
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'PlatformOrder', 'workspaceId'),
            orderId: BuiltValueNullFieldError.checkNotNull(
                orderId, r'PlatformOrder', 'orderId'),
            orderNumber: orderNumber,
            businessDate: businessDate,
            platform: BuiltValueNullFieldError.checkNotNull(
                platform, r'PlatformOrder', 'platform'),
            platformOrderRef: BuiltValueNullFieldError.checkNotNull(
                platformOrderRef, r'PlatformOrder', 'platformOrderRef'),
            pickupCode: pickupCode,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'PlatformOrder', 'status'),
            grossAmount: BuiltValueNullFieldError.checkNotNull(
                grossAmount, r'PlatformOrder', 'grossAmount'),
            commissionRate: BuiltValueNullFieldError.checkNotNull(
                commissionRate, r'PlatformOrder', 'commissionRate'),
            commissionAmount: BuiltValueNullFieldError.checkNotNull(
                commissionAmount, r'PlatformOrder', 'commissionAmount'),
            netAmount: BuiltValueNullFieldError.checkNotNull(
                netAmount, r'PlatformOrder', 'netAmount'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'PlatformOrder', 'currency'),
            enteredAt: enteredAt,
            readyAt: readyAt,
            completedAt: completedAt,
            canceledAt: canceledAt,
            cancelReason: cancelReason,
            settledAt: settledAt,
            settlementReference: settlementReference,
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformOrder', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
