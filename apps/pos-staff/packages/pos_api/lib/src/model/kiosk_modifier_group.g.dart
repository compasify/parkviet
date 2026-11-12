// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_modifier_group.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskModifierGroup extends KioskModifierGroup {
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
  final bool required_;
  @override
  final BuiltList<KioskModifierOption> options;

  factory _$KioskModifierGroup(
          [void Function(KioskModifierGroupBuilder)? updates]) =>
      (KioskModifierGroupBuilder()..update(updates))._build();

  _$KioskModifierGroup._(
      {required this.id,
      required this.name,
      required this.minSelect,
      required this.maxSelect,
      required this.allowQuantity,
      required this.required_,
      required this.options})
      : super._();
  @override
  KioskModifierGroup rebuild(
          void Function(KioskModifierGroupBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskModifierGroupBuilder toBuilder() =>
      KioskModifierGroupBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskModifierGroup &&
        id == other.id &&
        name == other.name &&
        minSelect == other.minSelect &&
        maxSelect == other.maxSelect &&
        allowQuantity == other.allowQuantity &&
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
    _$hash = $jc(_$hash, required_.hashCode);
    _$hash = $jc(_$hash, options.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskModifierGroup')
          ..add('id', id)
          ..add('name', name)
          ..add('minSelect', minSelect)
          ..add('maxSelect', maxSelect)
          ..add('allowQuantity', allowQuantity)
          ..add('required_', required_)
          ..add('options', options))
        .toString();
  }
}

class KioskModifierGroupBuilder
    implements Builder<KioskModifierGroup, KioskModifierGroupBuilder> {
  _$KioskModifierGroup? _$v;

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

  bool? _required_;
  bool? get required_ => _$this._required_;
  set required_(bool? required_) => _$this._required_ = required_;

  ListBuilder<KioskModifierOption>? _options;
  ListBuilder<KioskModifierOption> get options =>
      _$this._options ??= ListBuilder<KioskModifierOption>();
  set options(ListBuilder<KioskModifierOption>? options) =>
      _$this._options = options;

  KioskModifierGroupBuilder() {
    KioskModifierGroup._defaults(this);
  }

  KioskModifierGroupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _minSelect = $v.minSelect;
      _maxSelect = $v.maxSelect;
      _allowQuantity = $v.allowQuantity;
      _required_ = $v.required_;
      _options = $v.options.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskModifierGroup other) {
    _$v = other as _$KioskModifierGroup;
  }

  @override
  void update(void Function(KioskModifierGroupBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskModifierGroup build() => _build();

  _$KioskModifierGroup _build() {
    _$KioskModifierGroup _$result;
    try {
      _$result = _$v ??
          _$KioskModifierGroup._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'KioskModifierGroup', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'KioskModifierGroup', 'name'),
            minSelect: BuiltValueNullFieldError.checkNotNull(
                minSelect, r'KioskModifierGroup', 'minSelect'),
            maxSelect: BuiltValueNullFieldError.checkNotNull(
                maxSelect, r'KioskModifierGroup', 'maxSelect'),
            allowQuantity: BuiltValueNullFieldError.checkNotNull(
                allowQuantity, r'KioskModifierGroup', 'allowQuantity'),
            required_: BuiltValueNullFieldError.checkNotNull(
                required_, r'KioskModifierGroup', 'required_'),
            options: options.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'options';
        options.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskModifierGroup', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
