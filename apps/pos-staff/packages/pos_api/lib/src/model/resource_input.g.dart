// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ResourceInputKindEnum _$resourceInputKindEnum_table =
    const ResourceInputKindEnum._('table');
const ResourceInputKindEnum _$resourceInputKindEnum_room =
    const ResourceInputKindEnum._('room');
const ResourceInputKindEnum _$resourceInputKindEnum_billiard =
    const ResourceInputKindEnum._('billiard');
const ResourceInputKindEnum _$resourceInputKindEnum_vip =
    const ResourceInputKindEnum._('vip');

ResourceInputKindEnum _$resourceInputKindEnumValueOf(String name) {
  switch (name) {
    case 'table':
      return _$resourceInputKindEnum_table;
    case 'room':
      return _$resourceInputKindEnum_room;
    case 'billiard':
      return _$resourceInputKindEnum_billiard;
    case 'vip':
      return _$resourceInputKindEnum_vip;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceInputKindEnum> _$resourceInputKindEnumValues =
    BuiltSet<ResourceInputKindEnum>(const <ResourceInputKindEnum>[
  _$resourceInputKindEnum_table,
  _$resourceInputKindEnum_room,
  _$resourceInputKindEnum_billiard,
  _$resourceInputKindEnum_vip,
]);

const ResourceInputShapeEnum _$resourceInputShapeEnum_rect =
    const ResourceInputShapeEnum._('rect');
const ResourceInputShapeEnum _$resourceInputShapeEnum_round =
    const ResourceInputShapeEnum._('round');

ResourceInputShapeEnum _$resourceInputShapeEnumValueOf(String name) {
  switch (name) {
    case 'rect':
      return _$resourceInputShapeEnum_rect;
    case 'round':
      return _$resourceInputShapeEnum_round;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceInputShapeEnum> _$resourceInputShapeEnumValues =
    BuiltSet<ResourceInputShapeEnum>(const <ResourceInputShapeEnum>[
  _$resourceInputShapeEnum_rect,
  _$resourceInputShapeEnum_round,
]);

Serializer<ResourceInputKindEnum> _$resourceInputKindEnumSerializer =
    _$ResourceInputKindEnumSerializer();
Serializer<ResourceInputShapeEnum> _$resourceInputShapeEnumSerializer =
    _$ResourceInputShapeEnumSerializer();

class _$ResourceInputKindEnumSerializer
    implements PrimitiveSerializer<ResourceInputKindEnum> {
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
  final Iterable<Type> types = const <Type>[ResourceInputKindEnum];
  @override
  final String wireName = 'ResourceInputKindEnum';

  @override
  Object serialize(Serializers serializers, ResourceInputKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceInputKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceInputKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResourceInputShapeEnumSerializer
    implements PrimitiveSerializer<ResourceInputShapeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'rect': 'rect',
    'round': 'round',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'rect': 'rect',
    'round': 'round',
  };

  @override
  final Iterable<Type> types = const <Type>[ResourceInputShapeEnum];
  @override
  final String wireName = 'ResourceInputShapeEnum';

  @override
  Object serialize(Serializers serializers, ResourceInputShapeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceInputShapeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceInputShapeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResourceInput extends ResourceInput {
  @override
  final String? branchId;
  @override
  final String? areaId;
  @override
  final String? name;
  @override
  final ResourceInputKindEnum? kind;
  @override
  final int? capacity;
  @override
  final ResourceInputShapeEnum? shape;
  @override
  final int? x;
  @override
  final int? y;
  @override
  final int? w;
  @override
  final int? h;
  @override
  final int? rotation;
  @override
  final int? position;
  @override
  final String? resourceTypeCode;

  factory _$ResourceInput([void Function(ResourceInputBuilder)? updates]) =>
      (ResourceInputBuilder()..update(updates))._build();

  _$ResourceInput._(
      {this.branchId,
      this.areaId,
      this.name,
      this.kind,
      this.capacity,
      this.shape,
      this.x,
      this.y,
      this.w,
      this.h,
      this.rotation,
      this.position,
      this.resourceTypeCode})
      : super._();
  @override
  ResourceInput rebuild(void Function(ResourceInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceInputBuilder toBuilder() => ResourceInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceInput &&
        branchId == other.branchId &&
        areaId == other.areaId &&
        name == other.name &&
        kind == other.kind &&
        capacity == other.capacity &&
        shape == other.shape &&
        x == other.x &&
        y == other.y &&
        w == other.w &&
        h == other.h &&
        rotation == other.rotation &&
        position == other.position &&
        resourceTypeCode == other.resourceTypeCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, areaId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jc(_$hash, shape.hashCode);
    _$hash = $jc(_$hash, x.hashCode);
    _$hash = $jc(_$hash, y.hashCode);
    _$hash = $jc(_$hash, w.hashCode);
    _$hash = $jc(_$hash, h.hashCode);
    _$hash = $jc(_$hash, rotation.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, resourceTypeCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResourceInput')
          ..add('branchId', branchId)
          ..add('areaId', areaId)
          ..add('name', name)
          ..add('kind', kind)
          ..add('capacity', capacity)
          ..add('shape', shape)
          ..add('x', x)
          ..add('y', y)
          ..add('w', w)
          ..add('h', h)
          ..add('rotation', rotation)
          ..add('position', position)
          ..add('resourceTypeCode', resourceTypeCode))
        .toString();
  }
}

class ResourceInputBuilder
    implements Builder<ResourceInput, ResourceInputBuilder> {
  _$ResourceInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _areaId;
  String? get areaId => _$this._areaId;
  set areaId(String? areaId) => _$this._areaId = areaId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ResourceInputKindEnum? _kind;
  ResourceInputKindEnum? get kind => _$this._kind;
  set kind(ResourceInputKindEnum? kind) => _$this._kind = kind;

  int? _capacity;
  int? get capacity => _$this._capacity;
  set capacity(int? capacity) => _$this._capacity = capacity;

  ResourceInputShapeEnum? _shape;
  ResourceInputShapeEnum? get shape => _$this._shape;
  set shape(ResourceInputShapeEnum? shape) => _$this._shape = shape;

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

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  String? _resourceTypeCode;
  String? get resourceTypeCode => _$this._resourceTypeCode;
  set resourceTypeCode(String? resourceTypeCode) =>
      _$this._resourceTypeCode = resourceTypeCode;

  ResourceInputBuilder() {
    ResourceInput._defaults(this);
  }

  ResourceInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _areaId = $v.areaId;
      _name = $v.name;
      _kind = $v.kind;
      _capacity = $v.capacity;
      _shape = $v.shape;
      _x = $v.x;
      _y = $v.y;
      _w = $v.w;
      _h = $v.h;
      _rotation = $v.rotation;
      _position = $v.position;
      _resourceTypeCode = $v.resourceTypeCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceInput other) {
    _$v = other as _$ResourceInput;
  }

  @override
  void update(void Function(ResourceInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceInput build() => _build();

  _$ResourceInput _build() {
    final _$result = _$v ??
        _$ResourceInput._(
          branchId: branchId,
          areaId: areaId,
          name: name,
          kind: kind,
          capacity: capacity,
          shape: shape,
          x: x,
          y: y,
          w: w,
          h: h,
          rotation: rotation,
          position: position,
          resourceTypeCode: resourceTypeCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
