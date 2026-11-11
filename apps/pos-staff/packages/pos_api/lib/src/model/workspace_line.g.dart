// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_line.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkspaceLineKindEnum _$workspaceLineKindEnum_ordinary =
    const WorkspaceLineKindEnum._('ordinary');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_measured =
    const WorkspaceLineKindEnum._('measured');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_tracked =
    const WorkspaceLineKindEnum._('tracked');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_menu =
    const WorkspaceLineKindEnum._('menu');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_timed =
    const WorkspaceLineKindEnum._('timed');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_cover =
    const WorkspaceLineKindEnum._('cover');

WorkspaceLineKindEnum _$workspaceLineKindEnumValueOf(String name) {
  switch (name) {
    case 'ordinary':
      return _$workspaceLineKindEnum_ordinary;
    case 'measured':
      return _$workspaceLineKindEnum_measured;
    case 'tracked':
      return _$workspaceLineKindEnum_tracked;
    case 'menu':
      return _$workspaceLineKindEnum_menu;
    case 'timed':
      return _$workspaceLineKindEnum_timed;
    case 'cover':
      return _$workspaceLineKindEnum_cover;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkspaceLineKindEnum> _$workspaceLineKindEnumValues =
    BuiltSet<WorkspaceLineKindEnum>(const <WorkspaceLineKindEnum>[
  _$workspaceLineKindEnum_ordinary,
  _$workspaceLineKindEnum_measured,
  _$workspaceLineKindEnum_tracked,
  _$workspaceLineKindEnum_menu,
  _$workspaceLineKindEnum_timed,
  _$workspaceLineKindEnum_cover,
]);

Serializer<WorkspaceLineKindEnum> _$workspaceLineKindEnumSerializer =
    _$WorkspaceLineKindEnumSerializer();

class _$WorkspaceLineKindEnumSerializer
    implements PrimitiveSerializer<WorkspaceLineKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ordinary': 'ordinary',
    'measured': 'measured',
    'tracked': 'tracked',
    'menu': 'menu',
    'timed': 'timed',
    'cover': 'cover',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ordinary': 'ordinary',
    'measured': 'measured',
    'tracked': 'tracked',
    'menu': 'menu',
    'timed': 'timed',
    'cover': 'cover',
  };

  @override
  final Iterable<Type> types = const <Type>[WorkspaceLineKindEnum];
  @override
  final String wireName = 'WorkspaceLineKindEnum';

  @override
  Object serialize(Serializers serializers, WorkspaceLineKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkspaceLineKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkspaceLineKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkspaceLine extends WorkspaceLine {
  @override
  final String id;
  @override
  final String variantId;
  @override
  final String name;
  @override
  final int quantity;
  @override
  final String price;
  @override
  final String amount;
  @override
  final String? saleLineId;
  @override
  final WorkspaceLineKindEnum? kind;
  @override
  final String? unitPrice;
  @override
  final String? note;
  @override
  final BuiltList<LineModifier>? modifiers;
  @override
  final BuiltList<LineComponent>? components;

  factory _$WorkspaceLine([void Function(WorkspaceLineBuilder)? updates]) =>
      (WorkspaceLineBuilder()..update(updates))._build();

  _$WorkspaceLine._(
      {required this.id,
      required this.variantId,
      required this.name,
      required this.quantity,
      required this.price,
      required this.amount,
      this.saleLineId,
      this.kind,
      this.unitPrice,
      this.note,
      this.modifiers,
      this.components})
      : super._();
  @override
  WorkspaceLine rebuild(void Function(WorkspaceLineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceLineBuilder toBuilder() => WorkspaceLineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceLine &&
        id == other.id &&
        variantId == other.variantId &&
        name == other.name &&
        quantity == other.quantity &&
        price == other.price &&
        amount == other.amount &&
        saleLineId == other.saleLineId &&
        kind == other.kind &&
        unitPrice == other.unitPrice &&
        note == other.note &&
        modifiers == other.modifiers &&
        components == other.components;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, saleLineId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jc(_$hash, components.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceLine')
          ..add('id', id)
          ..add('variantId', variantId)
          ..add('name', name)
          ..add('quantity', quantity)
          ..add('price', price)
          ..add('amount', amount)
          ..add('saleLineId', saleLineId)
          ..add('kind', kind)
          ..add('unitPrice', unitPrice)
          ..add('note', note)
          ..add('modifiers', modifiers)
          ..add('components', components))
        .toString();
  }
}

class WorkspaceLineBuilder
    implements Builder<WorkspaceLine, WorkspaceLineBuilder> {
  _$WorkspaceLine? _$v;

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

  String? _price;
  String? get price => _$this._price;
  set price(String? price) => _$this._price = price;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _saleLineId;
  String? get saleLineId => _$this._saleLineId;
  set saleLineId(String? saleLineId) => _$this._saleLineId = saleLineId;

  WorkspaceLineKindEnum? _kind;
  WorkspaceLineKindEnum? get kind => _$this._kind;
  set kind(WorkspaceLineKindEnum? kind) => _$this._kind = kind;

  String? _unitPrice;
  String? get unitPrice => _$this._unitPrice;
  set unitPrice(String? unitPrice) => _$this._unitPrice = unitPrice;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<LineModifier>? _modifiers;
  ListBuilder<LineModifier> get modifiers =>
      _$this._modifiers ??= ListBuilder<LineModifier>();
  set modifiers(ListBuilder<LineModifier>? modifiers) =>
      _$this._modifiers = modifiers;

  ListBuilder<LineComponent>? _components;
  ListBuilder<LineComponent> get components =>
      _$this._components ??= ListBuilder<LineComponent>();
  set components(ListBuilder<LineComponent>? components) =>
      _$this._components = components;

  WorkspaceLineBuilder() {
    WorkspaceLine._defaults(this);
  }

  WorkspaceLineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _variantId = $v.variantId;
      _name = $v.name;
      _quantity = $v.quantity;
      _price = $v.price;
      _amount = $v.amount;
      _saleLineId = $v.saleLineId;
      _kind = $v.kind;
      _unitPrice = $v.unitPrice;
      _note = $v.note;
      _modifiers = $v.modifiers?.toBuilder();
      _components = $v.components?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceLine other) {
    _$v = other as _$WorkspaceLine;
  }

  @override
  void update(void Function(WorkspaceLineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceLine build() => _build();

  _$WorkspaceLine _build() {
    _$WorkspaceLine _$result;
    try {
      _$result = _$v ??
          _$WorkspaceLine._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'WorkspaceLine', 'id'),
            variantId: BuiltValueNullFieldError.checkNotNull(
                variantId, r'WorkspaceLine', 'variantId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'WorkspaceLine', 'name'),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'WorkspaceLine', 'quantity'),
            price: BuiltValueNullFieldError.checkNotNull(
                price, r'WorkspaceLine', 'price'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'WorkspaceLine', 'amount'),
            saleLineId: saleLineId,
            kind: kind,
            unitPrice: unitPrice,
            note: note,
            modifiers: _modifiers?.build(),
            components: _components?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        _modifiers?.build();
        _$failedField = 'components';
        _components?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkspaceLine', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
