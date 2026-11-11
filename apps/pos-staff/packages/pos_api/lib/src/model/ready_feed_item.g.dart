// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ready_feed_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReadyFeedItemStatusEnum _$readyFeedItemStatusEnum_ready =
    const ReadyFeedItemStatusEnum._('ready');
const ReadyFeedItemStatusEnum _$readyFeedItemStatusEnum_served =
    const ReadyFeedItemStatusEnum._('served');

ReadyFeedItemStatusEnum _$readyFeedItemStatusEnumValueOf(String name) {
  switch (name) {
    case 'ready':
      return _$readyFeedItemStatusEnum_ready;
    case 'served':
      return _$readyFeedItemStatusEnum_served;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReadyFeedItemStatusEnum> _$readyFeedItemStatusEnumValues =
    BuiltSet<ReadyFeedItemStatusEnum>(const <ReadyFeedItemStatusEnum>[
  _$readyFeedItemStatusEnum_ready,
  _$readyFeedItemStatusEnum_served,
]);

Serializer<ReadyFeedItemStatusEnum> _$readyFeedItemStatusEnumSerializer =
    _$ReadyFeedItemStatusEnumSerializer();

class _$ReadyFeedItemStatusEnumSerializer
    implements PrimitiveSerializer<ReadyFeedItemStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ready': 'ready',
    'served': 'served',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ready': 'ready',
    'served': 'served',
  };

  @override
  final Iterable<Type> types = const <Type>[ReadyFeedItemStatusEnum];
  @override
  final String wireName = 'ReadyFeedItemStatusEnum';

  @override
  Object serialize(Serializers serializers, ReadyFeedItemStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReadyFeedItemStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReadyFeedItemStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReadyFeedItem extends ReadyFeedItem {
  @override
  final String id;
  @override
  final String name;
  @override
  final String quantity;
  @override
  final BuiltList<KitchenTicketItemModifier> modifiers;
  @override
  final ReadyFeedItemStatusEnum status;
  @override
  final DateTime? readyAt;
  @override
  final DateTime? servedAt;
  @override
  final String stationName;
  @override
  final String workspaceId;
  @override
  final String? tableLabel;
  @override
  final String resourceId;
  @override
  final String tableName;

  factory _$ReadyFeedItem([void Function(ReadyFeedItemBuilder)? updates]) =>
      (ReadyFeedItemBuilder()..update(updates))._build();

  _$ReadyFeedItem._(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.modifiers,
      required this.status,
      this.readyAt,
      this.servedAt,
      required this.stationName,
      required this.workspaceId,
      this.tableLabel,
      required this.resourceId,
      required this.tableName})
      : super._();
  @override
  ReadyFeedItem rebuild(void Function(ReadyFeedItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReadyFeedItemBuilder toBuilder() => ReadyFeedItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReadyFeedItem &&
        id == other.id &&
        name == other.name &&
        quantity == other.quantity &&
        modifiers == other.modifiers &&
        status == other.status &&
        readyAt == other.readyAt &&
        servedAt == other.servedAt &&
        stationName == other.stationName &&
        workspaceId == other.workspaceId &&
        tableLabel == other.tableLabel &&
        resourceId == other.resourceId &&
        tableName == other.tableName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, readyAt.hashCode);
    _$hash = $jc(_$hash, servedAt.hashCode);
    _$hash = $jc(_$hash, stationName.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, tableLabel.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, tableName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReadyFeedItem')
          ..add('id', id)
          ..add('name', name)
          ..add('quantity', quantity)
          ..add('modifiers', modifiers)
          ..add('status', status)
          ..add('readyAt', readyAt)
          ..add('servedAt', servedAt)
          ..add('stationName', stationName)
          ..add('workspaceId', workspaceId)
          ..add('tableLabel', tableLabel)
          ..add('resourceId', resourceId)
          ..add('tableName', tableName))
        .toString();
  }
}

class ReadyFeedItemBuilder
    implements Builder<ReadyFeedItem, ReadyFeedItemBuilder> {
  _$ReadyFeedItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  ListBuilder<KitchenTicketItemModifier>? _modifiers;
  ListBuilder<KitchenTicketItemModifier> get modifiers =>
      _$this._modifiers ??= ListBuilder<KitchenTicketItemModifier>();
  set modifiers(ListBuilder<KitchenTicketItemModifier>? modifiers) =>
      _$this._modifiers = modifiers;

  ReadyFeedItemStatusEnum? _status;
  ReadyFeedItemStatusEnum? get status => _$this._status;
  set status(ReadyFeedItemStatusEnum? status) => _$this._status = status;

  DateTime? _readyAt;
  DateTime? get readyAt => _$this._readyAt;
  set readyAt(DateTime? readyAt) => _$this._readyAt = readyAt;

  DateTime? _servedAt;
  DateTime? get servedAt => _$this._servedAt;
  set servedAt(DateTime? servedAt) => _$this._servedAt = servedAt;

  String? _stationName;
  String? get stationName => _$this._stationName;
  set stationName(String? stationName) => _$this._stationName = stationName;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _tableLabel;
  String? get tableLabel => _$this._tableLabel;
  set tableLabel(String? tableLabel) => _$this._tableLabel = tableLabel;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _tableName;
  String? get tableName => _$this._tableName;
  set tableName(String? tableName) => _$this._tableName = tableName;

  ReadyFeedItemBuilder() {
    ReadyFeedItem._defaults(this);
  }

  ReadyFeedItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _quantity = $v.quantity;
      _modifiers = $v.modifiers.toBuilder();
      _status = $v.status;
      _readyAt = $v.readyAt;
      _servedAt = $v.servedAt;
      _stationName = $v.stationName;
      _workspaceId = $v.workspaceId;
      _tableLabel = $v.tableLabel;
      _resourceId = $v.resourceId;
      _tableName = $v.tableName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReadyFeedItem other) {
    _$v = other as _$ReadyFeedItem;
  }

  @override
  void update(void Function(ReadyFeedItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReadyFeedItem build() => _build();

  _$ReadyFeedItem _build() {
    _$ReadyFeedItem _$result;
    try {
      _$result = _$v ??
          _$ReadyFeedItem._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ReadyFeedItem', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ReadyFeedItem', 'name'),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'ReadyFeedItem', 'quantity'),
            modifiers: modifiers.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'ReadyFeedItem', 'status'),
            readyAt: readyAt,
            servedAt: servedAt,
            stationName: BuiltValueNullFieldError.checkNotNull(
                stationName, r'ReadyFeedItem', 'stationName'),
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'ReadyFeedItem', 'workspaceId'),
            tableLabel: tableLabel,
            resourceId: BuiltValueNullFieldError.checkNotNull(
                resourceId, r'ReadyFeedItem', 'resourceId'),
            tableName: BuiltValueNullFieldError.checkNotNull(
                tableName, r'ReadyFeedItem', 'tableName'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        modifiers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReadyFeedItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
