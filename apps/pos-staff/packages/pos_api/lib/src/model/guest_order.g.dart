// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_order.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GuestOrderStatusEnum _$guestOrderStatusEnum_pending =
    const GuestOrderStatusEnum._('pending');
const GuestOrderStatusEnum _$guestOrderStatusEnum_accepted =
    const GuestOrderStatusEnum._('accepted');
const GuestOrderStatusEnum _$guestOrderStatusEnum_rejected =
    const GuestOrderStatusEnum._('rejected');
const GuestOrderStatusEnum _$guestOrderStatusEnum_expired =
    const GuestOrderStatusEnum._('expired');

GuestOrderStatusEnum _$guestOrderStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$guestOrderStatusEnum_pending;
    case 'accepted':
      return _$guestOrderStatusEnum_accepted;
    case 'rejected':
      return _$guestOrderStatusEnum_rejected;
    case 'expired':
      return _$guestOrderStatusEnum_expired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GuestOrderStatusEnum> _$guestOrderStatusEnumValues =
    BuiltSet<GuestOrderStatusEnum>(const <GuestOrderStatusEnum>[
  _$guestOrderStatusEnum_pending,
  _$guestOrderStatusEnum_accepted,
  _$guestOrderStatusEnum_rejected,
  _$guestOrderStatusEnum_expired,
]);

Serializer<GuestOrderStatusEnum> _$guestOrderStatusEnumSerializer =
    _$GuestOrderStatusEnumSerializer();

class _$GuestOrderStatusEnumSerializer
    implements PrimitiveSerializer<GuestOrderStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'accepted': 'accepted',
    'rejected': 'rejected',
    'expired': 'expired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'accepted': 'accepted',
    'rejected': 'rejected',
    'expired': 'expired',
  };

  @override
  final Iterable<Type> types = const <Type>[GuestOrderStatusEnum];
  @override
  final String wireName = 'GuestOrderStatusEnum';

  @override
  Object serialize(Serializers serializers, GuestOrderStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GuestOrderStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GuestOrderStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GuestOrder extends GuestOrder {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String workspaceId;
  @override
  final String resourceId;
  @override
  final String tableName;
  @override
  final String? areaId;
  @override
  final GuestOrderStatusEnum status;
  @override
  final bool automatic;
  @override
  final BuiltList<GuestOrderItem> items;
  @override
  final String quotedTotal;
  @override
  final String currency;
  @override
  final int itemCount;
  @override
  final String? rejectReason;
  @override
  final String? decidedById;
  @override
  final String? decidedByName;
  @override
  final DateTime? decidedAt;
  @override
  final DateTime createdAt;

  factory _$GuestOrder([void Function(GuestOrderBuilder)? updates]) =>
      (GuestOrderBuilder()..update(updates))._build();

  _$GuestOrder._(
      {required this.id,
      required this.branchId,
      required this.workspaceId,
      required this.resourceId,
      required this.tableName,
      this.areaId,
      required this.status,
      required this.automatic,
      required this.items,
      required this.quotedTotal,
      required this.currency,
      required this.itemCount,
      this.rejectReason,
      this.decidedById,
      this.decidedByName,
      this.decidedAt,
      required this.createdAt})
      : super._();
  @override
  GuestOrder rebuild(void Function(GuestOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestOrderBuilder toBuilder() => GuestOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestOrder &&
        id == other.id &&
        branchId == other.branchId &&
        workspaceId == other.workspaceId &&
        resourceId == other.resourceId &&
        tableName == other.tableName &&
        areaId == other.areaId &&
        status == other.status &&
        automatic == other.automatic &&
        items == other.items &&
        quotedTotal == other.quotedTotal &&
        currency == other.currency &&
        itemCount == other.itemCount &&
        rejectReason == other.rejectReason &&
        decidedById == other.decidedById &&
        decidedByName == other.decidedByName &&
        decidedAt == other.decidedAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, tableName.hashCode);
    _$hash = $jc(_$hash, areaId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, automatic.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, quotedTotal.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, itemCount.hashCode);
    _$hash = $jc(_$hash, rejectReason.hashCode);
    _$hash = $jc(_$hash, decidedById.hashCode);
    _$hash = $jc(_$hash, decidedByName.hashCode);
    _$hash = $jc(_$hash, decidedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GuestOrder')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('workspaceId', workspaceId)
          ..add('resourceId', resourceId)
          ..add('tableName', tableName)
          ..add('areaId', areaId)
          ..add('status', status)
          ..add('automatic', automatic)
          ..add('items', items)
          ..add('quotedTotal', quotedTotal)
          ..add('currency', currency)
          ..add('itemCount', itemCount)
          ..add('rejectReason', rejectReason)
          ..add('decidedById', decidedById)
          ..add('decidedByName', decidedByName)
          ..add('decidedAt', decidedAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GuestOrderBuilder implements Builder<GuestOrder, GuestOrderBuilder> {
  _$GuestOrder? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _tableName;
  String? get tableName => _$this._tableName;
  set tableName(String? tableName) => _$this._tableName = tableName;

  String? _areaId;
  String? get areaId => _$this._areaId;
  set areaId(String? areaId) => _$this._areaId = areaId;

  GuestOrderStatusEnum? _status;
  GuestOrderStatusEnum? get status => _$this._status;
  set status(GuestOrderStatusEnum? status) => _$this._status = status;

  bool? _automatic;
  bool? get automatic => _$this._automatic;
  set automatic(bool? automatic) => _$this._automatic = automatic;

  ListBuilder<GuestOrderItem>? _items;
  ListBuilder<GuestOrderItem> get items =>
      _$this._items ??= ListBuilder<GuestOrderItem>();
  set items(ListBuilder<GuestOrderItem>? items) => _$this._items = items;

  String? _quotedTotal;
  String? get quotedTotal => _$this._quotedTotal;
  set quotedTotal(String? quotedTotal) => _$this._quotedTotal = quotedTotal;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  int? _itemCount;
  int? get itemCount => _$this._itemCount;
  set itemCount(int? itemCount) => _$this._itemCount = itemCount;

  String? _rejectReason;
  String? get rejectReason => _$this._rejectReason;
  set rejectReason(String? rejectReason) => _$this._rejectReason = rejectReason;

  String? _decidedById;
  String? get decidedById => _$this._decidedById;
  set decidedById(String? decidedById) => _$this._decidedById = decidedById;

  String? _decidedByName;
  String? get decidedByName => _$this._decidedByName;
  set decidedByName(String? decidedByName) =>
      _$this._decidedByName = decidedByName;

  DateTime? _decidedAt;
  DateTime? get decidedAt => _$this._decidedAt;
  set decidedAt(DateTime? decidedAt) => _$this._decidedAt = decidedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  GuestOrderBuilder() {
    GuestOrder._defaults(this);
  }

  GuestOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _workspaceId = $v.workspaceId;
      _resourceId = $v.resourceId;
      _tableName = $v.tableName;
      _areaId = $v.areaId;
      _status = $v.status;
      _automatic = $v.automatic;
      _items = $v.items.toBuilder();
      _quotedTotal = $v.quotedTotal;
      _currency = $v.currency;
      _itemCount = $v.itemCount;
      _rejectReason = $v.rejectReason;
      _decidedById = $v.decidedById;
      _decidedByName = $v.decidedByName;
      _decidedAt = $v.decidedAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestOrder other) {
    _$v = other as _$GuestOrder;
  }

  @override
  void update(void Function(GuestOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestOrder build() => _build();

  _$GuestOrder _build() {
    _$GuestOrder _$result;
    try {
      _$result = _$v ??
          _$GuestOrder._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'GuestOrder', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'GuestOrder', 'branchId'),
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'GuestOrder', 'workspaceId'),
            resourceId: BuiltValueNullFieldError.checkNotNull(
                resourceId, r'GuestOrder', 'resourceId'),
            tableName: BuiltValueNullFieldError.checkNotNull(
                tableName, r'GuestOrder', 'tableName'),
            areaId: areaId,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GuestOrder', 'status'),
            automatic: BuiltValueNullFieldError.checkNotNull(
                automatic, r'GuestOrder', 'automatic'),
            items: items.build(),
            quotedTotal: BuiltValueNullFieldError.checkNotNull(
                quotedTotal, r'GuestOrder', 'quotedTotal'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'GuestOrder', 'currency'),
            itemCount: BuiltValueNullFieldError.checkNotNull(
                itemCount, r'GuestOrder', 'itemCount'),
            rejectReason: rejectReason,
            decidedById: decidedById,
            decidedByName: decidedByName,
            decidedAt: decidedAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'GuestOrder', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GuestOrder', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
