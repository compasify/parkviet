// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_modifier_option.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskModifierOption extends KioskModifierOption {
  @override
  final String id;
  @override
  final String name;
  @override
  final String priceDelta;
  @override
  final bool defaultSelected;

  factory _$KioskModifierOption(
          [void Function(KioskModifierOptionBuilder)? updates]) =>
      (KioskModifierOptionBuilder()..update(updates))._build();

  _$KioskModifierOption._(
      {required this.id,
      required this.name,
      required this.priceDelta,
      required this.defaultSelected})
      : super._();
  @override
  KioskModifierOption rebuild(
          void Function(KioskModifierOptionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskModifierOptionBuilder toBuilder() =>
      KioskModifierOptionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskModifierOption &&
        id == other.id &&
        name == other.name &&
        priceDelta == other.priceDelta &&
        defaultSelected == other.defaultSelected;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, priceDelta.hashCode);
    _$hash = $jc(_$hash, defaultSelected.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskModifierOption')
          ..add('id', id)
          ..add('name', name)
          ..add('priceDelta', priceDelta)
          ..add('defaultSelected', defaultSelected))
        .toString();
  }
}

class KioskModifierOptionBuilder
    implements Builder<KioskModifierOption, KioskModifierOptionBuilder> {
  _$KioskModifierOption? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _priceDelta;
  String? get priceDelta => _$this._priceDelta;
  set priceDelta(String? priceDelta) => _$this._priceDelta = priceDelta;

  bool? _defaultSelected;
  bool? get defaultSelected => _$this._defaultSelected;
  set defaultSelected(bool? defaultSelected) =>
      _$this._defaultSelected = defaultSelected;

  KioskModifierOptionBuilder() {
    KioskModifierOption._defaults(this);
  }

  KioskModifierOptionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _priceDelta = $v.priceDelta;
      _defaultSelected = $v.defaultSelected;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskModifierOption other) {
    _$v = other as _$KioskModifierOption;
  }

  @override
  void update(void Function(KioskModifierOptionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskModifierOption build() => _build();

  _$KioskModifierOption _build() {
    final _$result = _$v ??
        _$KioskModifierOption._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'KioskModifierOption', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KioskModifierOption', 'name'),
          priceDelta: BuiltValueNullFieldError.checkNotNull(
              priceDelta, r'KioskModifierOption', 'priceDelta'),
          defaultSelected: BuiltValueNullFieldError.checkNotNull(
              defaultSelected, r'KioskModifierOption', 'defaultSelected'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
