// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AreaStatusEnum _$areaStatusEnum_active = const AreaStatusEnum._('active');
const AreaStatusEnum _$areaStatusEnum_archived =
    const AreaStatusEnum._('archived');

AreaStatusEnum _$areaStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$areaStatusEnum_active;
    case 'archived':
      return _$areaStatusEnum_archived;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AreaStatusEnum> _$areaStatusEnumValues =
    BuiltSet<AreaStatusEnum>(const <AreaStatusEnum>[
  _$areaStatusEnum_active,
  _$areaStatusEnum_archived,
]);

Serializer<AreaStatusEnum> _$areaStatusEnumSerializer =
    _$AreaStatusEnumSerializer();

class _$AreaStatusEnumSerializer
    implements PrimitiveSerializer<AreaStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'archived': 'archived',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'archived': 'archived',
  };

  @override
  final Iterable<Type> types = const <Type>[AreaStatusEnum];
  @override
  final String wireName = 'AreaStatusEnum';

  @override
  Object serialize(Serializers serializers, AreaStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AreaStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AreaStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Area extends Area {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String name;
  @override
  final int position;
  @override
  final AreaStatusEnum status;
  @override
  final int floorWidth;
  @override
  final int floorHeight;

  factory _$Area([void Function(AreaBuilder)? updates]) =>
      (AreaBuilder()..update(updates))._build();

  _$Area._(
      {required this.id,
      required this.branchId,
      required this.name,
      required this.position,
      required this.status,
      required this.floorWidth,
      required this.floorHeight})
      : super._();
  @override
  Area rebuild(void Function(AreaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AreaBuilder toBuilder() => AreaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Area &&
        id == other.id &&
        branchId == other.branchId &&
        name == other.name &&
        position == other.position &&
        status == other.status &&
        floorWidth == other.floorWidth &&
        floorHeight == other.floorHeight;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, floorWidth.hashCode);
    _$hash = $jc(_$hash, floorHeight.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Area')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('name', name)
          ..add('position', position)
          ..add('status', status)
          ..add('floorWidth', floorWidth)
          ..add('floorHeight', floorHeight))
        .toString();
  }
}

class AreaBuilder implements Builder<Area, AreaBuilder> {
  _$Area? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  AreaStatusEnum? _status;
  AreaStatusEnum? get status => _$this._status;
  set status(AreaStatusEnum? status) => _$this._status = status;

  int? _floorWidth;
  int? get floorWidth => _$this._floorWidth;
  set floorWidth(int? floorWidth) => _$this._floorWidth = floorWidth;

  int? _floorHeight;
  int? get floorHeight => _$this._floorHeight;
  set floorHeight(int? floorHeight) => _$this._floorHeight = floorHeight;

  AreaBuilder() {
    Area._defaults(this);
  }

  AreaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _name = $v.name;
      _position = $v.position;
      _status = $v.status;
      _floorWidth = $v.floorWidth;
      _floorHeight = $v.floorHeight;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Area other) {
    _$v = other as _$Area;
  }

  @override
  void update(void Function(AreaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Area build() => _build();

  _$Area _build() {
    final _$result = _$v ??
        _$Area._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Area', 'id'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'Area', 'branchId'),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Area', 'name'),
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'Area', 'position'),
          status:
              BuiltValueNullFieldError.checkNotNull(status, r'Area', 'status'),
          floorWidth: BuiltValueNullFieldError.checkNotNull(
              floorWidth, r'Area', 'floorWidth'),
          floorHeight: BuiltValueNullFieldError.checkNotNull(
              floorHeight, r'Area', 'floorHeight'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
