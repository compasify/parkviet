// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_board_area.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResourceBoardArea extends ResourceBoardArea {
  @override
  final String id;
  @override
  final String name;
  @override
  final int position;
  @override
  final int floorWidth;
  @override
  final int floorHeight;

  factory _$ResourceBoardArea(
          [void Function(ResourceBoardAreaBuilder)? updates]) =>
      (ResourceBoardAreaBuilder()..update(updates))._build();

  _$ResourceBoardArea._(
      {required this.id,
      required this.name,
      required this.position,
      required this.floorWidth,
      required this.floorHeight})
      : super._();
  @override
  ResourceBoardArea rebuild(void Function(ResourceBoardAreaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceBoardAreaBuilder toBuilder() =>
      ResourceBoardAreaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceBoardArea &&
        id == other.id &&
        name == other.name &&
        position == other.position &&
        floorWidth == other.floorWidth &&
        floorHeight == other.floorHeight;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, floorWidth.hashCode);
    _$hash = $jc(_$hash, floorHeight.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResourceBoardArea')
          ..add('id', id)
          ..add('name', name)
          ..add('position', position)
          ..add('floorWidth', floorWidth)
          ..add('floorHeight', floorHeight))
        .toString();
  }
}

class ResourceBoardAreaBuilder
    implements Builder<ResourceBoardArea, ResourceBoardAreaBuilder> {
  _$ResourceBoardArea? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  int? _floorWidth;
  int? get floorWidth => _$this._floorWidth;
  set floorWidth(int? floorWidth) => _$this._floorWidth = floorWidth;

  int? _floorHeight;
  int? get floorHeight => _$this._floorHeight;
  set floorHeight(int? floorHeight) => _$this._floorHeight = floorHeight;

  ResourceBoardAreaBuilder() {
    ResourceBoardArea._defaults(this);
  }

  ResourceBoardAreaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _position = $v.position;
      _floorWidth = $v.floorWidth;
      _floorHeight = $v.floorHeight;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceBoardArea other) {
    _$v = other as _$ResourceBoardArea;
  }

  @override
  void update(void Function(ResourceBoardAreaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceBoardArea build() => _build();

  _$ResourceBoardArea _build() {
    final _$result = _$v ??
        _$ResourceBoardArea._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ResourceBoardArea', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ResourceBoardArea', 'name'),
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'ResourceBoardArea', 'position'),
          floorWidth: BuiltValueNullFieldError.checkNotNull(
              floorWidth, r'ResourceBoardArea', 'floorWidth'),
          floorHeight: BuiltValueNullFieldError.checkNotNull(
              floorHeight, r'ResourceBoardArea', 'floorHeight'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
