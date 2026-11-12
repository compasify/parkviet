// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_order_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GuestOrderItemOutcomeEnum _$guestOrderItemOutcomeEnum_added =
    const GuestOrderItemOutcomeEnum._('added');
const GuestOrderItemOutcomeEnum _$guestOrderItemOutcomeEnum_leftOut =
    const GuestOrderItemOutcomeEnum._('leftOut');

GuestOrderItemOutcomeEnum _$guestOrderItemOutcomeEnumValueOf(String name) {
  switch (name) {
    case 'added':
      return _$guestOrderItemOutcomeEnum_added;
    case 'leftOut':
      return _$guestOrderItemOutcomeEnum_leftOut;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GuestOrderItemOutcomeEnum> _$guestOrderItemOutcomeEnumValues =
    BuiltSet<GuestOrderItemOutcomeEnum>(const <GuestOrderItemOutcomeEnum>[
  _$guestOrderItemOutcomeEnum_added,
  _$guestOrderItemOutcomeEnum_leftOut,
]);

Serializer<GuestOrderItemOutcomeEnum> _$guestOrderItemOutcomeEnumSerializer =
    _$GuestOrderItemOutcomeEnumSerializer();

class _$GuestOrderItemOutcomeEnumSerializer
    implements PrimitiveSerializer<GuestOrderItemOutcomeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'added': 'added',
    'leftOut': 'left_out',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'added': 'added',
    'left_out': 'leftOut',
  };

  @override
  final Iterable<Type> types = const <Type>[GuestOrderItemOutcomeEnum];
  @override
  final String wireName = 'GuestOrderItemOutcomeEnum';

  @override
  Object serialize(Serializers serializers, GuestOrderItemOutcomeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GuestOrderItemOutcomeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GuestOrderItemOutcomeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GuestOrderItem extends GuestOrderItem {
  @override
  final String variantId;
  @override
  final String menuItemId;
  @override
  final String name;
  @override
  final String? size;
  @override
  final int quantity;
  @override
  final String unitPrice;
  @override
  final String amount;
  @override
  final String? note;
  @override
  final GuestOrderItemOutcomeEnum? outcome;
  @override
  final String? reason;
  @override
  final BuiltList<GuestOrderModifier> modifiers;

  factory _$GuestOrderItem([void Function(GuestOrderItemBuilder)? updates]) =>
      (GuestOrderItemBuilder()..update(updates))._build();

  _$GuestOrderItem._(
      {required this.variantId,
      required this.menuItemId,
      required this.name,
      this.size,
      required this.quantity,
      required this.unitPrice,
      required this.amount,
      this.note,
      this.outcome,
      this.reason,
      required this.modifiers})
      : super._();
  @override
  GuestOrderItem rebuild(void Function(GuestOrderItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestOrderItemBuilder toBuilder() => GuestOrderItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestOrderItem &&
        variantId == other.variantId &&
        menuItemId == other.menuItemId &&
        name == other.name &&
        size == other.size &&
        quantity == other.quantity &&
        unitPrice == other.unitPrice &&
        amount == other.amount &&
        note == other.note &&
        outcome == other.outcome &&
        reason == other.reason &&
        modifiers == other.modifiers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, menuItemId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GuestOrderItem')
          ..add('variantId', variantId)
          ..add('menuItemId', menuItemId)
          ..add('name', name)
          ..add('size', size)
          ..add('quantity', quantity)
          ..add('unitPrice', unitPrice)
          ..add('amount', amount)
          ..add('note', note)
          ..add('outcome', outcome)
          ..add('reason', reason)
          ..add('modifiers', modifiers))
        .toString();
  }
}

class GuestOrderItemBuilder
    implements Builder<GuestOrderItem, GuestOrderItemBuilder> {
  _$GuestOrderItem? _$v;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  String? _menuItemId;
  String? get menuItemId => _$this._menuItemId;
  set menuItemId(String? menuItemId) => _$this._menuItemId = menuItemId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _size;
  String? get size => _$this._size;
  set size(String? size) => _$this._size = size;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _unitPrice;
  String? get unitPrice => _$this._unitPrice;
  set unitPrice(String? unitPrice) => _$this._unitPrice = unitPrice;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  GuestOrderItemOutcomeEnum? _outcome;
  GuestOrderItemOutcomeEnum? get outcome => _$this._outcome;
  set outcome(GuestOrderItemOutcomeEnum? outcome) => _$this._outcome = outcome;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ListBuilder<GuestOrderModifier>? _modifiers;
  ListBuilder<GuestOrderModifier> get modifiers =>
      _$this._modifiers ??= ListBuilder<GuestOrderModifier>();
  set modifiers(ListBuilder<GuestOrderModifier>? modifiers) =>
      _$this._modifiers = modifiers;

  GuestOrderItemBuilder() {
    GuestOrderItem._defaults(this);
  }

  GuestOrderItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _variantId = $v.variantId;
      _menuItemId = $v.menuItemId;
      _name = $v.name;
      _size = $v.size;
      _quantity = $v.quantity;
      _unitPrice = $v.unitPrice;
      _amount = $v.amount;
      _note = $v.note;
      _outcome = $v.outcome;
      _reason = $v.reason;
      _modifiers = $v.modifiers.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestOrderItem other) {
    _$v = other as _$GuestOrderItem;
  }

  @override
  void update(void Function(GuestOrderItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestOrderItem build() => _build();

  _$GuestOrderItem _build() {
    _$GuestOrderItem _$result;
    try {
      _$result = _$v ??
          _$GuestOrderItem._(
            variantId: BuiltValueNullFieldError.checkNotNull(
                variantId, r'GuestOrderItem', 'variantId'),
            menuItemId: BuiltValueNullFieldError.checkNotNull(
                menuItemId, r'GuestOrderItem', 'menuItemId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'GuestOrderItem', 'name'),
            size: size,
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'GuestOrderItem', 'quantity'),
            unitPrice: BuiltValueNullFieldError.checkNotNull(
                unitPrice, r'GuestOrderItem', 'unitPrice'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'GuestOrderItem', 'amount'),
            note: note,
            outcome: outcome,
            reason: reason,
            modifiers: modifiers.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        modifiers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GuestOrderItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
