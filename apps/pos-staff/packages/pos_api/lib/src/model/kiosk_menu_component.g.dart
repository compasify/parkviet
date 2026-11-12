// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_menu_component.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskMenuComponent extends KioskMenuComponent {
  @override
  final String name;
  @override
  final int quantity;

  factory _$KioskMenuComponent(
          [void Function(KioskMenuComponentBuilder)? updates]) =>
      (KioskMenuComponentBuilder()..update(updates))._build();

  _$KioskMenuComponent._({required this.name, required this.quantity})
      : super._();
  @override
  KioskMenuComponent rebuild(
          void Function(KioskMenuComponentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskMenuComponentBuilder toBuilder() =>
      KioskMenuComponentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskMenuComponent &&
        name == other.name &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskMenuComponent')
          ..add('name', name)
          ..add('quantity', quantity))
        .toString();
  }
}

class KioskMenuComponentBuilder
    implements Builder<KioskMenuComponent, KioskMenuComponentBuilder> {
  _$KioskMenuComponent? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  KioskMenuComponentBuilder() {
    KioskMenuComponent._defaults(this);
  }

  KioskMenuComponentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskMenuComponent other) {
    _$v = other as _$KioskMenuComponent;
  }

  @override
  void update(void Function(KioskMenuComponentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskMenuComponent build() => _build();

  _$KioskMenuComponent _build() {
    final _$result = _$v ??
        _$KioskMenuComponent._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KioskMenuComponent', 'name'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'KioskMenuComponent', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
