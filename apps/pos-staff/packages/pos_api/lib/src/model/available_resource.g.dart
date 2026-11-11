// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AvailableResourceKindEnum _$availableResourceKindEnum_table =
    const AvailableResourceKindEnum._('table');
const AvailableResourceKindEnum _$availableResourceKindEnum_room =
    const AvailableResourceKindEnum._('room');
const AvailableResourceKindEnum _$availableResourceKindEnum_billiard =
    const AvailableResourceKindEnum._('billiard');
const AvailableResourceKindEnum _$availableResourceKindEnum_vip =
    const AvailableResourceKindEnum._('vip');

AvailableResourceKindEnum _$availableResourceKindEnumValueOf(String name) {
  switch (name) {
    case 'table':
      return _$availableResourceKindEnum_table;
    case 'room':
      return _$availableResourceKindEnum_room;
    case 'billiard':
      return _$availableResourceKindEnum_billiard;
    case 'vip':
      return _$availableResourceKindEnum_vip;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AvailableResourceKindEnum> _$availableResourceKindEnumValues =
    BuiltSet<AvailableResourceKindEnum>(const <AvailableResourceKindEnum>[
  _$availableResourceKindEnum_table,
  _$availableResourceKindEnum_room,
  _$availableResourceKindEnum_billiard,
  _$availableResourceKindEnum_vip,
]);

Serializer<AvailableResourceKindEnum> _$availableResourceKindEnumSerializer =
    _$AvailableResourceKindEnumSerializer();

class _$AvailableResourceKindEnumSerializer
    implements PrimitiveSerializer<AvailableResourceKindEnum> {
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
  final Iterable<Type> types = const <Type>[AvailableResourceKindEnum];
  @override
  final String wireName = 'AvailableResourceKindEnum';

  @override
  Object serialize(Serializers serializers, AvailableResourceKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AvailableResourceKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AvailableResourceKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AvailableResource extends AvailableResource {
  @override
  final String id;
  @override
  final String name;
  @override
  final AvailableResourceKindEnum kind;
  @override
  final String? areaId;
  @override
  final int capacity;

  factory _$AvailableResource(
          [void Function(AvailableResourceBuilder)? updates]) =>
      (AvailableResourceBuilder()..update(updates))._build();

  _$AvailableResource._(
      {required this.id,
      required this.name,
      required this.kind,
      this.areaId,
      required this.capacity})
      : super._();
  @override
  AvailableResource rebuild(void Function(AvailableResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AvailableResourceBuilder toBuilder() =>
      AvailableResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AvailableResource &&
        id == other.id &&
        name == other.name &&
        kind == other.kind &&
        areaId == other.areaId &&
        capacity == other.capacity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, areaId.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AvailableResource')
          ..add('id', id)
          ..add('name', name)
          ..add('kind', kind)
          ..add('areaId', areaId)
          ..add('capacity', capacity))
        .toString();
  }
}

class AvailableResourceBuilder
    implements Builder<AvailableResource, AvailableResourceBuilder> {
  _$AvailableResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AvailableResourceKindEnum? _kind;
  AvailableResourceKindEnum? get kind => _$this._kind;
  set kind(AvailableResourceKindEnum? kind) => _$this._kind = kind;

  String? _areaId;
  String? get areaId => _$this._areaId;
  set areaId(String? areaId) => _$this._areaId = areaId;

  int? _capacity;
  int? get capacity => _$this._capacity;
  set capacity(int? capacity) => _$this._capacity = capacity;

  AvailableResourceBuilder() {
    AvailableResource._defaults(this);
  }

  AvailableResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _kind = $v.kind;
      _areaId = $v.areaId;
      _capacity = $v.capacity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AvailableResource other) {
    _$v = other as _$AvailableResource;
  }

  @override
  void update(void Function(AvailableResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AvailableResource build() => _build();

  _$AvailableResource _build() {
    final _$result = _$v ??
        _$AvailableResource._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AvailableResource', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AvailableResource', 'name'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'AvailableResource', 'kind'),
          areaId: areaId,
          capacity: BuiltValueNullFieldError.checkNotNull(
              capacity, r'AvailableResource', 'capacity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
