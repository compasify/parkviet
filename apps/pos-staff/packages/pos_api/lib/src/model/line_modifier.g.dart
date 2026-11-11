// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_modifier.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LineModifier extends LineModifier {
  @override
  final String id;
  @override
  final String? optionId;
  @override
  final String name;
  @override
  final String groupName;
  @override
  final String priceDelta;
  @override
  final int quantity;

  factory _$LineModifier([void Function(LineModifierBuilder)? updates]) =>
      (LineModifierBuilder()..update(updates))._build();

  _$LineModifier._(
      {required this.id,
      this.optionId,
      required this.name,
      required this.groupName,
      required this.priceDelta,
      required this.quantity})
      : super._();
  @override
  LineModifier rebuild(void Function(LineModifierBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LineModifierBuilder toBuilder() => LineModifierBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LineModifier &&
        id == other.id &&
        optionId == other.optionId &&
        name == other.name &&
        groupName == other.groupName &&
        priceDelta == other.priceDelta &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, optionId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, groupName.hashCode);
    _$hash = $jc(_$hash, priceDelta.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LineModifier')
          ..add('id', id)
          ..add('optionId', optionId)
          ..add('name', name)
          ..add('groupName', groupName)
          ..add('priceDelta', priceDelta)
          ..add('quantity', quantity))
        .toString();
  }
}

class LineModifierBuilder
    implements Builder<LineModifier, LineModifierBuilder> {
  _$LineModifier? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _optionId;
  String? get optionId => _$this._optionId;
  set optionId(String? optionId) => _$this._optionId = optionId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _groupName;
  String? get groupName => _$this._groupName;
  set groupName(String? groupName) => _$this._groupName = groupName;

  String? _priceDelta;
  String? get priceDelta => _$this._priceDelta;
  set priceDelta(String? priceDelta) => _$this._priceDelta = priceDelta;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  LineModifierBuilder() {
    LineModifier._defaults(this);
  }

  LineModifierBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _optionId = $v.optionId;
      _name = $v.name;
      _groupName = $v.groupName;
      _priceDelta = $v.priceDelta;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LineModifier other) {
    _$v = other as _$LineModifier;
  }

  @override
  void update(void Function(LineModifierBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LineModifier build() => _build();

  _$LineModifier _build() {
    final _$result = _$v ??
        _$LineModifier._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'LineModifier', 'id'),
          optionId: optionId,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'LineModifier', 'name'),
          groupName: BuiltValueNullFieldError.checkNotNull(
              groupName, r'LineModifier', 'groupName'),
          priceDelta: BuiltValueNullFieldError.checkNotNull(
              priceDelta, r'LineModifier', 'priceDelta'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'LineModifier', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
