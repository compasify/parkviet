// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_component.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LineComponent extends LineComponent {
  @override
  final String id;
  @override
  final String variantId;
  @override
  final String name;
  @override
  final int quantity;

  factory _$LineComponent([void Function(LineComponentBuilder)? updates]) =>
      (LineComponentBuilder()..update(updates))._build();

  _$LineComponent._(
      {required this.id,
      required this.variantId,
      required this.name,
      required this.quantity})
      : super._();
  @override
  LineComponent rebuild(void Function(LineComponentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LineComponentBuilder toBuilder() => LineComponentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LineComponent &&
        id == other.id &&
        variantId == other.variantId &&
        name == other.name &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LineComponent')
          ..add('id', id)
          ..add('variantId', variantId)
          ..add('name', name)
          ..add('quantity', quantity))
        .toString();
  }
}

class LineComponentBuilder
    implements Builder<LineComponent, LineComponentBuilder> {
  _$LineComponent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  LineComponentBuilder() {
    LineComponent._defaults(this);
  }

  LineComponentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _variantId = $v.variantId;
      _name = $v.name;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LineComponent other) {
    _$v = other as _$LineComponent;
  }

  @override
  void update(void Function(LineComponentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LineComponent build() => _build();

  _$LineComponent _build() {
    final _$result = _$v ??
        _$LineComponent._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'LineComponent', 'id'),
          variantId: BuiltValueNullFieldError.checkNotNull(
              variantId, r'LineComponent', 'variantId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'LineComponent', 'name'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'LineComponent', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
