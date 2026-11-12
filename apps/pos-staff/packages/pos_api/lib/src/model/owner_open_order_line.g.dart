// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_open_order_line.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OwnerOpenOrderLineKitchenEnum _$ownerOpenOrderLineKitchenEnum_none =
    const OwnerOpenOrderLineKitchenEnum._('none');
const OwnerOpenOrderLineKitchenEnum _$ownerOpenOrderLineKitchenEnum_unsent =
    const OwnerOpenOrderLineKitchenEnum._('unsent');
const OwnerOpenOrderLineKitchenEnum _$ownerOpenOrderLineKitchenEnum_waiting =
    const OwnerOpenOrderLineKitchenEnum._('waiting');
const OwnerOpenOrderLineKitchenEnum _$ownerOpenOrderLineKitchenEnum_ready =
    const OwnerOpenOrderLineKitchenEnum._('ready');
const OwnerOpenOrderLineKitchenEnum _$ownerOpenOrderLineKitchenEnum_served =
    const OwnerOpenOrderLineKitchenEnum._('served');

OwnerOpenOrderLineKitchenEnum _$ownerOpenOrderLineKitchenEnumValueOf(
    String name) {
  switch (name) {
    case 'none':
      return _$ownerOpenOrderLineKitchenEnum_none;
    case 'unsent':
      return _$ownerOpenOrderLineKitchenEnum_unsent;
    case 'waiting':
      return _$ownerOpenOrderLineKitchenEnum_waiting;
    case 'ready':
      return _$ownerOpenOrderLineKitchenEnum_ready;
    case 'served':
      return _$ownerOpenOrderLineKitchenEnum_served;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OwnerOpenOrderLineKitchenEnum>
    _$ownerOpenOrderLineKitchenEnumValues = BuiltSet<
        OwnerOpenOrderLineKitchenEnum>(const <OwnerOpenOrderLineKitchenEnum>[
  _$ownerOpenOrderLineKitchenEnum_none,
  _$ownerOpenOrderLineKitchenEnum_unsent,
  _$ownerOpenOrderLineKitchenEnum_waiting,
  _$ownerOpenOrderLineKitchenEnum_ready,
  _$ownerOpenOrderLineKitchenEnum_served,
]);

Serializer<OwnerOpenOrderLineKitchenEnum>
    _$ownerOpenOrderLineKitchenEnumSerializer =
    _$OwnerOpenOrderLineKitchenEnumSerializer();

class _$OwnerOpenOrderLineKitchenEnumSerializer
    implements PrimitiveSerializer<OwnerOpenOrderLineKitchenEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'none': 'none',
    'unsent': 'unsent',
    'waiting': 'waiting',
    'ready': 'ready',
    'served': 'served',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'none': 'none',
    'unsent': 'unsent',
    'waiting': 'waiting',
    'ready': 'ready',
    'served': 'served',
  };

  @override
  final Iterable<Type> types = const <Type>[OwnerOpenOrderLineKitchenEnum];
  @override
  final String wireName = 'OwnerOpenOrderLineKitchenEnum';

  @override
  Object serialize(
          Serializers serializers, OwnerOpenOrderLineKitchenEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OwnerOpenOrderLineKitchenEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OwnerOpenOrderLineKitchenEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OwnerOpenOrderLine extends OwnerOpenOrderLine {
  @override
  final String id;
  @override
  final String name;
  @override
  final String quantity;
  @override
  final String? unit;
  @override
  final String amount;
  @override
  final OwnerOpenOrderLineKitchenEnum kitchen;

  factory _$OwnerOpenOrderLine(
          [void Function(OwnerOpenOrderLineBuilder)? updates]) =>
      (OwnerOpenOrderLineBuilder()..update(updates))._build();

  _$OwnerOpenOrderLine._(
      {required this.id,
      required this.name,
      required this.quantity,
      this.unit,
      required this.amount,
      required this.kitchen})
      : super._();
  @override
  OwnerOpenOrderLine rebuild(
          void Function(OwnerOpenOrderLineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerOpenOrderLineBuilder toBuilder() =>
      OwnerOpenOrderLineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerOpenOrderLine &&
        id == other.id &&
        name == other.name &&
        quantity == other.quantity &&
        unit == other.unit &&
        amount == other.amount &&
        kitchen == other.kitchen;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, kitchen.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnerOpenOrderLine')
          ..add('id', id)
          ..add('name', name)
          ..add('quantity', quantity)
          ..add('unit', unit)
          ..add('amount', amount)
          ..add('kitchen', kitchen))
        .toString();
  }
}

class OwnerOpenOrderLineBuilder
    implements Builder<OwnerOpenOrderLine, OwnerOpenOrderLineBuilder> {
  _$OwnerOpenOrderLine? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  OwnerOpenOrderLineKitchenEnum? _kitchen;
  OwnerOpenOrderLineKitchenEnum? get kitchen => _$this._kitchen;
  set kitchen(OwnerOpenOrderLineKitchenEnum? kitchen) =>
      _$this._kitchen = kitchen;

  OwnerOpenOrderLineBuilder() {
    OwnerOpenOrderLine._defaults(this);
  }

  OwnerOpenOrderLineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _quantity = $v.quantity;
      _unit = $v.unit;
      _amount = $v.amount;
      _kitchen = $v.kitchen;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerOpenOrderLine other) {
    _$v = other as _$OwnerOpenOrderLine;
  }

  @override
  void update(void Function(OwnerOpenOrderLineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerOpenOrderLine build() => _build();

  _$OwnerOpenOrderLine _build() {
    final _$result = _$v ??
        _$OwnerOpenOrderLine._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OwnerOpenOrderLine', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'OwnerOpenOrderLine', 'name'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'OwnerOpenOrderLine', 'quantity'),
          unit: unit,
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'OwnerOpenOrderLine', 'amount'),
          kitchen: BuiltValueNullFieldError.checkNotNull(
              kitchen, r'OwnerOpenOrderLine', 'kitchen'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
