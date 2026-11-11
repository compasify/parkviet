// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AreaInput extends AreaInput {
  @override
  final String? branchId;
  @override
  final String? name;
  @override
  final int? position;
  @override
  final int? floorWidth;
  @override
  final int? floorHeight;

  factory _$AreaInput([void Function(AreaInputBuilder)? updates]) =>
      (AreaInputBuilder()..update(updates))._build();

  _$AreaInput._(
      {this.branchId,
      this.name,
      this.position,
      this.floorWidth,
      this.floorHeight})
      : super._();
  @override
  AreaInput rebuild(void Function(AreaInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AreaInputBuilder toBuilder() => AreaInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AreaInput &&
        branchId == other.branchId &&
        name == other.name &&
        position == other.position &&
        floorWidth == other.floorWidth &&
        floorHeight == other.floorHeight;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, floorWidth.hashCode);
    _$hash = $jc(_$hash, floorHeight.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AreaInput')
          ..add('branchId', branchId)
          ..add('name', name)
          ..add('position', position)
          ..add('floorWidth', floorWidth)
          ..add('floorHeight', floorHeight))
        .toString();
  }
}

class AreaInputBuilder implements Builder<AreaInput, AreaInputBuilder> {
  _$AreaInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

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

  AreaInputBuilder() {
    AreaInput._defaults(this);
  }

  AreaInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _name = $v.name;
      _position = $v.position;
      _floorWidth = $v.floorWidth;
      _floorHeight = $v.floorHeight;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AreaInput other) {
    _$v = other as _$AreaInput;
  }

  @override
  void update(void Function(AreaInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AreaInput build() => _build();

  _$AreaInput _build() {
    final _$result = _$v ??
        _$AreaInput._(
          branchId: branchId,
          name: name,
          position: position,
          floorWidth: floorWidth,
          floorHeight: floorHeight,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
