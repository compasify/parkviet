// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ResourceKindEnum _$resourceKindEnum_table =
    const ResourceKindEnum._('table');
const ResourceKindEnum _$resourceKindEnum_room =
    const ResourceKindEnum._('room');
const ResourceKindEnum _$resourceKindEnum_billiard =
    const ResourceKindEnum._('billiard');
const ResourceKindEnum _$resourceKindEnum_vip = const ResourceKindEnum._('vip');

ResourceKindEnum _$resourceKindEnumValueOf(String name) {
  switch (name) {
    case 'table':
      return _$resourceKindEnum_table;
    case 'room':
      return _$resourceKindEnum_room;
    case 'billiard':
      return _$resourceKindEnum_billiard;
    case 'vip':
      return _$resourceKindEnum_vip;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceKindEnum> _$resourceKindEnumValues =
    BuiltSet<ResourceKindEnum>(const <ResourceKindEnum>[
  _$resourceKindEnum_table,
  _$resourceKindEnum_room,
  _$resourceKindEnum_billiard,
  _$resourceKindEnum_vip,
]);

const ResourceShapeEnum _$resourceShapeEnum_rect =
    const ResourceShapeEnum._('rect');
const ResourceShapeEnum _$resourceShapeEnum_round =
    const ResourceShapeEnum._('round');

ResourceShapeEnum _$resourceShapeEnumValueOf(String name) {
  switch (name) {
    case 'rect':
      return _$resourceShapeEnum_rect;
    case 'round':
      return _$resourceShapeEnum_round;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceShapeEnum> _$resourceShapeEnumValues =
    BuiltSet<ResourceShapeEnum>(const <ResourceShapeEnum>[
  _$resourceShapeEnum_rect,
  _$resourceShapeEnum_round,
]);

const ResourceManualStatusEnum _$resourceManualStatusEnum_available =
    const ResourceManualStatusEnum._('available');
const ResourceManualStatusEnum _$resourceManualStatusEnum_cleaning =
    const ResourceManualStatusEnum._('cleaning');
const ResourceManualStatusEnum _$resourceManualStatusEnum_outOfService =
    const ResourceManualStatusEnum._('outOfService');

ResourceManualStatusEnum _$resourceManualStatusEnumValueOf(String name) {
  switch (name) {
    case 'available':
      return _$resourceManualStatusEnum_available;
    case 'cleaning':
      return _$resourceManualStatusEnum_cleaning;
    case 'outOfService':
      return _$resourceManualStatusEnum_outOfService;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceManualStatusEnum> _$resourceManualStatusEnumValues =
    BuiltSet<ResourceManualStatusEnum>(const <ResourceManualStatusEnum>[
  _$resourceManualStatusEnum_available,
  _$resourceManualStatusEnum_cleaning,
  _$resourceManualStatusEnum_outOfService,
]);

const ResourceStatusEnum _$resourceStatusEnum_active =
    const ResourceStatusEnum._('active');
const ResourceStatusEnum _$resourceStatusEnum_archived =
    const ResourceStatusEnum._('archived');

ResourceStatusEnum _$resourceStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$resourceStatusEnum_active;
    case 'archived':
      return _$resourceStatusEnum_archived;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceStatusEnum> _$resourceStatusEnumValues =
    BuiltSet<ResourceStatusEnum>(const <ResourceStatusEnum>[
  _$resourceStatusEnum_active,
  _$resourceStatusEnum_archived,
]);

Serializer<ResourceKindEnum> _$resourceKindEnumSerializer =
    _$ResourceKindEnumSerializer();
Serializer<ResourceShapeEnum> _$resourceShapeEnumSerializer =
    _$ResourceShapeEnumSerializer();
Serializer<ResourceManualStatusEnum> _$resourceManualStatusEnumSerializer =
    _$ResourceManualStatusEnumSerializer();
Serializer<ResourceStatusEnum> _$resourceStatusEnumSerializer =
    _$ResourceStatusEnumSerializer();

class _$ResourceKindEnumSerializer
    implements PrimitiveSerializer<ResourceKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'table': 'table',
    'room': 'room',
    'billiard': 'billiard',
    'vip': 'vip',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'table': 'table',
    'room': 'room',
    'billiard': 'billiard',
    'vip': 'vip',
  };

  @override
  final Iterable<Type> types = const <Type>[ResourceKindEnum];
  @override
  final String wireName = 'ResourceKindEnum';

  @override
  Object serialize(Serializers serializers, ResourceKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResourceShapeEnumSerializer
    implements PrimitiveSerializer<ResourceShapeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'rect': 'rect',
    'round': 'round',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'rect': 'rect',
    'round': 'round',
  };

  @override
  final Iterable<Type> types = const <Type>[ResourceShapeEnum];
  @override
  final String wireName = 'ResourceShapeEnum';

  @override
  Object serialize(Serializers serializers, ResourceShapeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceShapeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceShapeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResourceManualStatusEnumSerializer
    implements PrimitiveSerializer<ResourceManualStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'available': 'available',
    'cleaning': 'cleaning',
    'outOfService': 'out_of_service',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'available': 'available',
    'cleaning': 'cleaning',
    'out_of_service': 'outOfService',
  };

  @override
  final Iterable<Type> types = const <Type>[ResourceManualStatusEnum];
  @override
  final String wireName = 'ResourceManualStatusEnum';

  @override
  Object serialize(Serializers serializers, ResourceManualStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceManualStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceManualStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResourceStatusEnumSerializer
    implements PrimitiveSerializer<ResourceStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'archived': 'archived',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'archived': 'archived',
  };

  @override
  final Iterable<Type> types = const <Type>[ResourceStatusEnum];
  @override
  final String wireName = 'ResourceStatusEnum';

  @override
  Object serialize(Serializers serializers, ResourceStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Resource extends Resource {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String areaId;
  @override
  final ResourceKindEnum kind;
  @override
  final String name;
  @override
  final int capacity;
  @override
  final ResourceShapeEnum shape;
  @override
  final int x;
  @override
  final int y;
  @override
  final int w;
  @override
  final int h;
  @override
  final int rotation;
  @override
  final ResourceManualStatusEnum manualStatus;
  @override
  final String? resourceTypeCode;
  @override
  final ResourceStatusEnum status;
  @override
  final int position;

  factory _$Resource([void Function(ResourceBuilder)? updates]) =>
      (ResourceBuilder()..update(updates))._build();

  _$Resource._(
      {required this.id,
      required this.branchId,
      required this.areaId,
      required this.kind,
      required this.name,
      required this.capacity,
      required this.shape,
      required this.x,
      required this.y,
      required this.w,
      required this.h,
      required this.rotation,
      required this.manualStatus,
      this.resourceTypeCode,
      required this.status,
      required this.position})
      : super._();
  @override
  Resource rebuild(void Function(ResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceBuilder toBuilder() => ResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Resource &&
        id == other.id &&
        branchId == other.branchId &&
        areaId == other.areaId &&
        kind == other.kind &&
        name == other.name &&
        capacity == other.capacity &&
        shape == other.shape &&
        x == other.x &&
        y == other.y &&
        w == other.w &&
        h == other.h &&
        rotation == other.rotation &&
        manualStatus == other.manualStatus &&
        resourceTypeCode == other.resourceTypeCode &&
        status == other.status &&
        position == other.position;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, areaId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jc(_$hash, shape.hashCode);
    _$hash = $jc(_$hash, x.hashCode);
    _$hash = $jc(_$hash, y.hashCode);
    _$hash = $jc(_$hash, w.hashCode);
    _$hash = $jc(_$hash, h.hashCode);
    _$hash = $jc(_$hash, rotation.hashCode);
    _$hash = $jc(_$hash, manualStatus.hashCode);
    _$hash = $jc(_$hash, resourceTypeCode.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Resource')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('areaId', areaId)
          ..add('kind', kind)
          ..add('name', name)
          ..add('capacity', capacity)
          ..add('shape', shape)
          ..add('x', x)
          ..add('y', y)
          ..add('w', w)
          ..add('h', h)
          ..add('rotation', rotation)
          ..add('manualStatus', manualStatus)
          ..add('resourceTypeCode', resourceTypeCode)
          ..add('status', status)
          ..add('position', position))
        .toString();
  }
}

class ResourceBuilder implements Builder<Resource, ResourceBuilder> {
  _$Resource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _areaId;
  String? get areaId => _$this._areaId;
  set areaId(String? areaId) => _$this._areaId = areaId;

  ResourceKindEnum? _kind;
  ResourceKindEnum? get kind => _$this._kind;
  set kind(ResourceKindEnum? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _capacity;
  int? get capacity => _$this._capacity;
  set capacity(int? capacity) => _$this._capacity = capacity;

  ResourceShapeEnum? _shape;
  ResourceShapeEnum? get shape => _$this._shape;
  set shape(ResourceShapeEnum? shape) => _$this._shape = shape;

  int? _x;
  int? get x => _$this._x;
  set x(int? x) => _$this._x = x;

  int? _y;
  int? get y => _$this._y;
  set y(int? y) => _$this._y = y;

  int? _w;
  int? get w => _$this._w;
  set w(int? w) => _$this._w = w;

  int? _h;
  int? get h => _$this._h;
  set h(int? h) => _$this._h = h;

  int? _rotation;
  int? get rotation => _$this._rotation;
  set rotation(int? rotation) => _$this._rotation = rotation;

  ResourceManualStatusEnum? _manualStatus;
  ResourceManualStatusEnum? get manualStatus => _$this._manualStatus;
  set manualStatus(ResourceManualStatusEnum? manualStatus) =>
      _$this._manualStatus = manualStatus;

  String? _resourceTypeCode;
  String? get resourceTypeCode => _$this._resourceTypeCode;
  set resourceTypeCode(String? resourceTypeCode) =>
      _$this._resourceTypeCode = resourceTypeCode;

  ResourceStatusEnum? _status;
  ResourceStatusEnum? get status => _$this._status;
  set status(ResourceStatusEnum? status) => _$this._status = status;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  ResourceBuilder() {
    Resource._defaults(this);
  }

  ResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _areaId = $v.areaId;
      _kind = $v.kind;
      _name = $v.name;
      _capacity = $v.capacity;
      _shape = $v.shape;
      _x = $v.x;
      _y = $v.y;
      _w = $v.w;
      _h = $v.h;
      _rotation = $v.rotation;
      _manualStatus = $v.manualStatus;
      _resourceTypeCode = $v.resourceTypeCode;
      _status = $v.status;
      _position = $v.position;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Resource other) {
    _$v = other as _$Resource;
  }

  @override
  void update(void Function(ResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Resource build() => _build();

  _$Resource _build() {
    final _$result = _$v ??
        _$Resource._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Resource', 'id'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'Resource', 'branchId'),
          areaId: BuiltValueNullFieldError.checkNotNull(
              areaId, r'Resource', 'areaId'),
          kind:
              BuiltValueNullFieldError.checkNotNull(kind, r'Resource', 'kind'),
          name:
              BuiltValueNullFieldError.checkNotNull(name, r'Resource', 'name'),
          capacity: BuiltValueNullFieldError.checkNotNull(
              capacity, r'Resource', 'capacity'),
          shape: BuiltValueNullFieldError.checkNotNull(
              shape, r'Resource', 'shape'),
          x: BuiltValueNullFieldError.checkNotNull(x, r'Resource', 'x'),
          y: BuiltValueNullFieldError.checkNotNull(y, r'Resource', 'y'),
          w: BuiltValueNullFieldError.checkNotNull(w, r'Resource', 'w'),
          h: BuiltValueNullFieldError.checkNotNull(h, r'Resource', 'h'),
          rotation: BuiltValueNullFieldError.checkNotNull(
              rotation, r'Resource', 'rotation'),
          manualStatus: BuiltValueNullFieldError.checkNotNull(
              manualStatus, r'Resource', 'manualStatus'),
          resourceTypeCode: resourceTypeCode,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Resource', 'status'),
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'Resource', 'position'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
