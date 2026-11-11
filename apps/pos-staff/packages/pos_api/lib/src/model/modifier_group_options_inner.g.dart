// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modifier_group_options_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModifierGroupOptionsInner extends ModifierGroupOptionsInner {
  @override
  final String id;
  @override
  final String name;
  @override
  final String priceDelta;
  @override
  final String? variantId;
  @override
  final bool defaultSelected;
  @override
  final int position;
  @override
  final bool active;

  factory _$ModifierGroupOptionsInner(
          [void Function(ModifierGroupOptionsInnerBuilder)? updates]) =>
      (ModifierGroupOptionsInnerBuilder()..update(updates))._build();

  _$ModifierGroupOptionsInner._(
      {required this.id,
      required this.name,
      required this.priceDelta,
      this.variantId,
      required this.defaultSelected,
      required this.position,
      required this.active})
      : super._();
  @override
  ModifierGroupOptionsInner rebuild(
          void Function(ModifierGroupOptionsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ModifierGroupOptionsInnerBuilder toBuilder() =>
      ModifierGroupOptionsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModifierGroupOptionsInner &&
        id == other.id &&
        name == other.name &&
        priceDelta == other.priceDelta &&
        variantId == other.variantId &&
        defaultSelected == other.defaultSelected &&
        position == other.position &&
        active == other.active;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, priceDelta.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, defaultSelected.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModifierGroupOptionsInner')
          ..add('id', id)
          ..add('name', name)
          ..add('priceDelta', priceDelta)
          ..add('variantId', variantId)
          ..add('defaultSelected', defaultSelected)
          ..add('position', position)
          ..add('active', active))
        .toString();
  }
}

class ModifierGroupOptionsInnerBuilder
    implements
        Builder<ModifierGroupOptionsInner, ModifierGroupOptionsInnerBuilder> {
  _$ModifierGroupOptionsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _priceDelta;
  String? get priceDelta => _$this._priceDelta;
  set priceDelta(String? priceDelta) => _$this._priceDelta = priceDelta;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  bool? _defaultSelected;
  bool? get defaultSelected => _$this._defaultSelected;
  set defaultSelected(bool? defaultSelected) =>
      _$this._defaultSelected = defaultSelected;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  ModifierGroupOptionsInnerBuilder() {
    ModifierGroupOptionsInner._defaults(this);
  }

  ModifierGroupOptionsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _priceDelta = $v.priceDelta;
      _variantId = $v.variantId;
      _defaultSelected = $v.defaultSelected;
      _position = $v.position;
      _active = $v.active;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModifierGroupOptionsInner other) {
    _$v = other as _$ModifierGroupOptionsInner;
  }

  @override
  void update(void Function(ModifierGroupOptionsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModifierGroupOptionsInner build() => _build();

  _$ModifierGroupOptionsInner _build() {
    final _$result = _$v ??
        _$ModifierGroupOptionsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ModifierGroupOptionsInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ModifierGroupOptionsInner', 'name'),
          priceDelta: BuiltValueNullFieldError.checkNotNull(
              priceDelta, r'ModifierGroupOptionsInner', 'priceDelta'),
          variantId: variantId,
          defaultSelected: BuiltValueNullFieldError.checkNotNull(
              defaultSelected, r'ModifierGroupOptionsInner', 'defaultSelected'),
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'ModifierGroupOptionsInner', 'position'),
          active: BuiltValueNullFieldError.checkNotNull(
              active, r'ModifierGroupOptionsInner', 'active'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
