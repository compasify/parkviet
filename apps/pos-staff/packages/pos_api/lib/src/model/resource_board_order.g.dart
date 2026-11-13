// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_board_order.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ResourceBoardOrderOperationalStatusEnum
    _$resourceBoardOrderOperationalStatusEnum_editing =
    const ResourceBoardOrderOperationalStatusEnum._('editing');
const ResourceBoardOrderOperationalStatusEnum
    _$resourceBoardOrderOperationalStatusEnum_parked =
    const ResourceBoardOrderOperationalStatusEnum._('parked');

ResourceBoardOrderOperationalStatusEnum
    _$resourceBoardOrderOperationalStatusEnumValueOf(String name) {
  switch (name) {
    case 'editing':
      return _$resourceBoardOrderOperationalStatusEnum_editing;
    case 'parked':
      return _$resourceBoardOrderOperationalStatusEnum_parked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceBoardOrderOperationalStatusEnum>
    _$resourceBoardOrderOperationalStatusEnumValues = BuiltSet<
        ResourceBoardOrderOperationalStatusEnum>(const <ResourceBoardOrderOperationalStatusEnum>[
  _$resourceBoardOrderOperationalStatusEnum_editing,
  _$resourceBoardOrderOperationalStatusEnum_parked,
]);

Serializer<ResourceBoardOrderOperationalStatusEnum>
    _$resourceBoardOrderOperationalStatusEnumSerializer =
    _$ResourceBoardOrderOperationalStatusEnumSerializer();

class _$ResourceBoardOrderOperationalStatusEnumSerializer
    implements PrimitiveSerializer<ResourceBoardOrderOperationalStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'editing': 'editing',
    'parked': 'parked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'editing': 'editing',
    'parked': 'parked',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ResourceBoardOrderOperationalStatusEnum
  ];
  @override
  final String wireName = 'ResourceBoardOrderOperationalStatusEnum';

  @override
  Object serialize(Serializers serializers,
          ResourceBoardOrderOperationalStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceBoardOrderOperationalStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceBoardOrderOperationalStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResourceBoardOrder extends ResourceBoardOrder {
  @override
  final DateTime? buffetEndsAt;
  @override
  final String id;
  @override
  final String? tableLabel;
  @override
  final int? guestCount;
  @override
  final String total;
  @override
  final int revision;
  @override
  final ResourceBoardOrderOperationalStatusEnum operationalStatus;
  @override
  final bool paymentRequested;
  @override
  final bool prebilled;
  @override
  final bool editedAfterPrebill;
  @override
  final int pendingKitchenItems;
  @override
  final int unsentKitchenItems;

  factory _$ResourceBoardOrder(
          [void Function(ResourceBoardOrderBuilder)? updates]) =>
      (ResourceBoardOrderBuilder()..update(updates))._build();

  _$ResourceBoardOrder._(
      {this.buffetEndsAt,
      required this.id,
      this.tableLabel,
      this.guestCount,
      required this.total,
      required this.revision,
      required this.operationalStatus,
      required this.paymentRequested,
      required this.prebilled,
      required this.editedAfterPrebill,
      required this.pendingKitchenItems,
      required this.unsentKitchenItems})
      : super._();
  @override
  ResourceBoardOrder rebuild(
          void Function(ResourceBoardOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceBoardOrderBuilder toBuilder() =>
      ResourceBoardOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceBoardOrder &&
        buffetEndsAt == other.buffetEndsAt &&
        id == other.id &&
        tableLabel == other.tableLabel &&
        guestCount == other.guestCount &&
        total == other.total &&
        revision == other.revision &&
        operationalStatus == other.operationalStatus &&
        paymentRequested == other.paymentRequested &&
        prebilled == other.prebilled &&
        editedAfterPrebill == other.editedAfterPrebill &&
        pendingKitchenItems == other.pendingKitchenItems &&
        unsentKitchenItems == other.unsentKitchenItems;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, buffetEndsAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, tableLabel.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, operationalStatus.hashCode);
    _$hash = $jc(_$hash, paymentRequested.hashCode);
    _$hash = $jc(_$hash, prebilled.hashCode);
    _$hash = $jc(_$hash, editedAfterPrebill.hashCode);
    _$hash = $jc(_$hash, pendingKitchenItems.hashCode);
    _$hash = $jc(_$hash, unsentKitchenItems.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResourceBoardOrder')
          ..add('buffetEndsAt', buffetEndsAt)
          ..add('id', id)
          ..add('tableLabel', tableLabel)
          ..add('guestCount', guestCount)
          ..add('total', total)
          ..add('revision', revision)
          ..add('operationalStatus', operationalStatus)
          ..add('paymentRequested', paymentRequested)
          ..add('prebilled', prebilled)
          ..add('editedAfterPrebill', editedAfterPrebill)
          ..add('pendingKitchenItems', pendingKitchenItems)
          ..add('unsentKitchenItems', unsentKitchenItems))
        .toString();
  }
}

class ResourceBoardOrderBuilder
    implements Builder<ResourceBoardOrder, ResourceBoardOrderBuilder> {
  _$ResourceBoardOrder? _$v;

  DateTime? _buffetEndsAt;
  DateTime? get buffetEndsAt => _$this._buffetEndsAt;
  set buffetEndsAt(DateTime? buffetEndsAt) =>
      _$this._buffetEndsAt = buffetEndsAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tableLabel;
  String? get tableLabel => _$this._tableLabel;
  set tableLabel(String? tableLabel) => _$this._tableLabel = tableLabel;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  ResourceBoardOrderOperationalStatusEnum? _operationalStatus;
  ResourceBoardOrderOperationalStatusEnum? get operationalStatus =>
      _$this._operationalStatus;
  set operationalStatus(
          ResourceBoardOrderOperationalStatusEnum? operationalStatus) =>
      _$this._operationalStatus = operationalStatus;

  bool? _paymentRequested;
  bool? get paymentRequested => _$this._paymentRequested;
  set paymentRequested(bool? paymentRequested) =>
      _$this._paymentRequested = paymentRequested;

  bool? _prebilled;
  bool? get prebilled => _$this._prebilled;
  set prebilled(bool? prebilled) => _$this._prebilled = prebilled;

  bool? _editedAfterPrebill;
  bool? get editedAfterPrebill => _$this._editedAfterPrebill;
  set editedAfterPrebill(bool? editedAfterPrebill) =>
      _$this._editedAfterPrebill = editedAfterPrebill;

  int? _pendingKitchenItems;
  int? get pendingKitchenItems => _$this._pendingKitchenItems;
  set pendingKitchenItems(int? pendingKitchenItems) =>
      _$this._pendingKitchenItems = pendingKitchenItems;

  int? _unsentKitchenItems;
  int? get unsentKitchenItems => _$this._unsentKitchenItems;
  set unsentKitchenItems(int? unsentKitchenItems) =>
      _$this._unsentKitchenItems = unsentKitchenItems;

  ResourceBoardOrderBuilder() {
    ResourceBoardOrder._defaults(this);
  }

  ResourceBoardOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _buffetEndsAt = $v.buffetEndsAt;
      _id = $v.id;
      _tableLabel = $v.tableLabel;
      _guestCount = $v.guestCount;
      _total = $v.total;
      _revision = $v.revision;
      _operationalStatus = $v.operationalStatus;
      _paymentRequested = $v.paymentRequested;
      _prebilled = $v.prebilled;
      _editedAfterPrebill = $v.editedAfterPrebill;
      _pendingKitchenItems = $v.pendingKitchenItems;
      _unsentKitchenItems = $v.unsentKitchenItems;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceBoardOrder other) {
    _$v = other as _$ResourceBoardOrder;
  }

  @override
  void update(void Function(ResourceBoardOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceBoardOrder build() => _build();

  _$ResourceBoardOrder _build() {
    final _$result = _$v ??
        _$ResourceBoardOrder._(
          buffetEndsAt: buffetEndsAt,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ResourceBoardOrder', 'id'),
          tableLabel: tableLabel,
          guestCount: guestCount,
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'ResourceBoardOrder', 'total'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'ResourceBoardOrder', 'revision'),
          operationalStatus: BuiltValueNullFieldError.checkNotNull(
              operationalStatus, r'ResourceBoardOrder', 'operationalStatus'),
          paymentRequested: BuiltValueNullFieldError.checkNotNull(
              paymentRequested, r'ResourceBoardOrder', 'paymentRequested'),
          prebilled: BuiltValueNullFieldError.checkNotNull(
              prebilled, r'ResourceBoardOrder', 'prebilled'),
          editedAfterPrebill: BuiltValueNullFieldError.checkNotNull(
              editedAfterPrebill, r'ResourceBoardOrder', 'editedAfterPrebill'),
          pendingKitchenItems: BuiltValueNullFieldError.checkNotNull(
              pendingKitchenItems,
              r'ResourceBoardOrder',
              'pendingKitchenItems'),
          unsentKitchenItems: BuiltValueNullFieldError.checkNotNull(
              unsentKitchenItems, r'ResourceBoardOrder', 'unsentKitchenItems'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
