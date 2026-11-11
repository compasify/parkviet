// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ResourceRefKindEnum _$resourceRefKindEnum_table =
    const ResourceRefKindEnum._('table');
const ResourceRefKindEnum _$resourceRefKindEnum_room =
    const ResourceRefKindEnum._('room');
const ResourceRefKindEnum _$resourceRefKindEnum_billiard =
    const ResourceRefKindEnum._('billiard');
const ResourceRefKindEnum _$resourceRefKindEnum_vip =
    const ResourceRefKindEnum._('vip');

ResourceRefKindEnum _$resourceRefKindEnumValueOf(String name) {
  switch (name) {
    case 'table':
      return _$resourceRefKindEnum_table;
    case 'room':
      return _$resourceRefKindEnum_room;
    case 'billiard':
      return _$resourceRefKindEnum_billiard;
    case 'vip':
      return _$resourceRefKindEnum_vip;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceRefKindEnum> _$resourceRefKindEnumValues =
    BuiltSet<ResourceRefKindEnum>(const <ResourceRefKindEnum>[
  _$resourceRefKindEnum_table,
  _$resourceRefKindEnum_room,
  _$resourceRefKindEnum_billiard,
  _$resourceRefKindEnum_vip,
]);

Serializer<ResourceRefKindEnum> _$resourceRefKindEnumSerializer =
    _$ResourceRefKindEnumSerializer();

class _$ResourceRefKindEnumSerializer
    implements PrimitiveSerializer<ResourceRefKindEnum> {
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
  final Iterable<Type> types = const <Type>[ResourceRefKindEnum];
  @override
  final String wireName = 'ResourceRefKindEnum';

  @override
  Object serialize(Serializers serializers, ResourceRefKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceRefKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceRefKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResourceRef extends ResourceRef {
  @override
  final String id;
  @override
  final String name;
  @override
  final ResourceRefKindEnum kind;
  @override
  final String? areaId;

  factory _$ResourceRef([void Function(ResourceRefBuilder)? updates]) =>
      (ResourceRefBuilder()..update(updates))._build();

  _$ResourceRef._(
      {required this.id, required this.name, required this.kind, this.areaId})
      : super._();
  @override
  ResourceRef rebuild(void Function(ResourceRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceRefBuilder toBuilder() => ResourceRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceRef &&
        id == other.id &&
        name == other.name &&
        kind == other.kind &&
        areaId == other.areaId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, areaId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResourceRef')
          ..add('id', id)
          ..add('name', name)
          ..add('kind', kind)
          ..add('areaId', areaId))
        .toString();
  }
}

class ResourceRefBuilder implements Builder<ResourceRef, ResourceRefBuilder> {
  _$ResourceRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ResourceRefKindEnum? _kind;
  ResourceRefKindEnum? get kind => _$this._kind;
  set kind(ResourceRefKindEnum? kind) => _$this._kind = kind;

  String? _areaId;
  String? get areaId => _$this._areaId;
  set areaId(String? areaId) => _$this._areaId = areaId;

  ResourceRefBuilder() {
    ResourceRef._defaults(this);
  }

  ResourceRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _kind = $v.kind;
      _areaId = $v.areaId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceRef other) {
    _$v = other as _$ResourceRef;
  }

  @override
  void update(void Function(ResourceRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceRef build() => _build();

  _$ResourceRef _build() {
    final _$result = _$v ??
        _$ResourceRef._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'ResourceRef', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ResourceRef', 'name'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'ResourceRef', 'kind'),
          areaId: areaId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
