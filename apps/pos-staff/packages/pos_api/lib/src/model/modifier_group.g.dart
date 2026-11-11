// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modifier_group.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ModifierGroup extends ModifierGroup {
  @override
  final String id;
  @override
  final String name;
  @override
  final int minSelect;
  @override
  final int maxSelect;
  @override
  final bool allowQuantity;
  @override
  final int position;
  @override
  final bool required_;
  @override
  final BuiltList<ModifierGroupOptionsInner> options;

  factory _$ModifierGroup([void Function(ModifierGroupBuilder)? updates]) =>
      (ModifierGroupBuilder()..update(updates))._build();

  _$ModifierGroup._(
      {required this.id,
      required this.name,
      required this.minSelect,
      required this.maxSelect,
      required this.allowQuantity,
      required this.position,
      required this.required_,
      required this.options})
      : super._();
  @override
  ModifierGroup rebuild(void Function(ModifierGroupBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ModifierGroupBuilder toBuilder() => ModifierGroupBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ModifierGroup &&
        id == other.id &&
        name == other.name &&
        minSelect == other.minSelect &&
        maxSelect == other.maxSelect &&
        allowQuantity == other.allowQuantity &&
        position == other.position &&
        required_ == other.required_ &&
        options == other.options;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, minSelect.hashCode);
    _$hash = $jc(_$hash, maxSelect.hashCode);
    _$hash = $jc(_$hash, allowQuantity.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, required_.hashCode);
    _$hash = $jc(_$hash, options.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ModifierGroup')
          ..add('id', id)
          ..add('name', name)
          ..add('minSelect', minSelect)
          ..add('maxSelect', maxSelect)
          ..add('allowQuantity', allowQuantity)
          ..add('position', position)
          ..add('required_', required_)
          ..add('options', options))
        .toString();
  }
}

class ModifierGroupBuilder
    implements Builder<ModifierGroup, ModifierGroupBuilder> {
  _$ModifierGroup? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _minSelect;
  int? get minSelect => _$this._minSelect;
  set minSelect(int? minSelect) => _$this._minSelect = minSelect;

  int? _maxSelect;
  int? get maxSelect => _$this._maxSelect;
  set maxSelect(int? maxSelect) => _$this._maxSelect = maxSelect;

  bool? _allowQuantity;
  bool? get allowQuantity => _$this._allowQuantity;
  set allowQuantity(bool? allowQuantity) =>
      _$this._allowQuantity = allowQuantity;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  bool? _required_;
  bool? get required_ => _$this._required_;
  set required_(bool? required_) => _$this._required_ = required_;

  ListBuilder<ModifierGroupOptionsInner>? _options;
  ListBuilder<ModifierGroupOptionsInner> get options =>
      _$this._options ??= ListBuilder<ModifierGroupOptionsInner>();
  set options(ListBuilder<ModifierGroupOptionsInner>? options) =>
      _$this._options = options;

  ModifierGroupBuilder() {
    ModifierGroup._defaults(this);
  }

  ModifierGroupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _minSelect = $v.minSelect;
      _maxSelect = $v.maxSelect;
      _allowQuantity = $v.allowQuantity;
      _position = $v.position;
      _required_ = $v.required_;
      _options = $v.options.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ModifierGroup other) {
    _$v = other as _$ModifierGroup;
  }

  @override
  void update(void Function(ModifierGroupBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ModifierGroup build() => _build();

  _$ModifierGroup _build() {
    _$ModifierGroup _$result;
    try {
      _$result = _$v ??
          _$ModifierGroup._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ModifierGroup', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ModifierGroup', 'name'),
            minSelect: BuiltValueNullFieldError.checkNotNull(
                minSelect, r'ModifierGroup', 'minSelect'),
            maxSelect: BuiltValueNullFieldError.checkNotNull(
                maxSelect, r'ModifierGroup', 'maxSelect'),
            allowQuantity: BuiltValueNullFieldError.checkNotNull(
                allowQuantity, r'ModifierGroup', 'allowQuantity'),
            position: BuiltValueNullFieldError.checkNotNull(
                position, r'ModifierGroup', 'position'),
            required_: BuiltValueNullFieldError.checkNotNull(
                required_, r'ModifierGroup', 'required_'),
            options: options.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'options';
        options.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ModifierGroup', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
