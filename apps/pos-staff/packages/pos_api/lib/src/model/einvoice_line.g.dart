// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_line.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EinvoiceLineKindEnum _$einvoiceLineKindEnum_goods =
    const EinvoiceLineKindEnum._('goods');
const EinvoiceLineKindEnum _$einvoiceLineKindEnum_serviceCharge =
    const EinvoiceLineKindEnum._('serviceCharge');
const EinvoiceLineKindEnum _$einvoiceLineKindEnum_fee =
    const EinvoiceLineKindEnum._('fee');

EinvoiceLineKindEnum _$einvoiceLineKindEnumValueOf(String name) {
  switch (name) {
    case 'goods':
      return _$einvoiceLineKindEnum_goods;
    case 'serviceCharge':
      return _$einvoiceLineKindEnum_serviceCharge;
    case 'fee':
      return _$einvoiceLineKindEnum_fee;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoiceLineKindEnum> _$einvoiceLineKindEnumValues =
    BuiltSet<EinvoiceLineKindEnum>(const <EinvoiceLineKindEnum>[
  _$einvoiceLineKindEnum_goods,
  _$einvoiceLineKindEnum_serviceCharge,
  _$einvoiceLineKindEnum_fee,
]);

Serializer<EinvoiceLineKindEnum> _$einvoiceLineKindEnumSerializer =
    _$EinvoiceLineKindEnumSerializer();

class _$EinvoiceLineKindEnumSerializer
    implements PrimitiveSerializer<EinvoiceLineKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'goods': 'goods',
    'serviceCharge': 'service_charge',
    'fee': 'fee',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'goods': 'goods',
    'service_charge': 'serviceCharge',
    'fee': 'fee',
  };

  @override
  final Iterable<Type> types = const <Type>[EinvoiceLineKindEnum];
  @override
  final String wireName = 'EinvoiceLineKindEnum';

  @override
  Object serialize(Serializers serializers, EinvoiceLineKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoiceLineKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoiceLineKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EinvoiceLine extends EinvoiceLine {
  @override
  final int position;
  @override
  final EinvoiceLineKindEnum kind;
  @override
  final String name;
  @override
  final String? sku;
  @override
  final String unit;
  @override
  final String quantity;
  @override
  final String unitPrice;
  @override
  final String discount;
  @override
  final String? taxRate;
  @override
  final String taxAmount;
  @override
  final String amountBeforeTax;
  @override
  final String amount;
  @override
  final bool priceIncludesTax;

  factory _$EinvoiceLine([void Function(EinvoiceLineBuilder)? updates]) =>
      (EinvoiceLineBuilder()..update(updates))._build();

  _$EinvoiceLine._(
      {required this.position,
      required this.kind,
      required this.name,
      this.sku,
      required this.unit,
      required this.quantity,
      required this.unitPrice,
      required this.discount,
      this.taxRate,
      required this.taxAmount,
      required this.amountBeforeTax,
      required this.amount,
      required this.priceIncludesTax})
      : super._();
  @override
  EinvoiceLine rebuild(void Function(EinvoiceLineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceLineBuilder toBuilder() => EinvoiceLineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceLine &&
        position == other.position &&
        kind == other.kind &&
        name == other.name &&
        sku == other.sku &&
        unit == other.unit &&
        quantity == other.quantity &&
        unitPrice == other.unitPrice &&
        discount == other.discount &&
        taxRate == other.taxRate &&
        taxAmount == other.taxAmount &&
        amountBeforeTax == other.amountBeforeTax &&
        amount == other.amount &&
        priceIncludesTax == other.priceIncludesTax;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sku.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, discount.hashCode);
    _$hash = $jc(_$hash, taxRate.hashCode);
    _$hash = $jc(_$hash, taxAmount.hashCode);
    _$hash = $jc(_$hash, amountBeforeTax.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, priceIncludesTax.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceLine')
          ..add('position', position)
          ..add('kind', kind)
          ..add('name', name)
          ..add('sku', sku)
          ..add('unit', unit)
          ..add('quantity', quantity)
          ..add('unitPrice', unitPrice)
          ..add('discount', discount)
          ..add('taxRate', taxRate)
          ..add('taxAmount', taxAmount)
          ..add('amountBeforeTax', amountBeforeTax)
          ..add('amount', amount)
          ..add('priceIncludesTax', priceIncludesTax))
        .toString();
  }
}

class EinvoiceLineBuilder
    implements Builder<EinvoiceLine, EinvoiceLineBuilder> {
  _$EinvoiceLine? _$v;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  EinvoiceLineKindEnum? _kind;
  EinvoiceLineKindEnum? get kind => _$this._kind;
  set kind(EinvoiceLineKindEnum? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _sku;
  String? get sku => _$this._sku;
  set sku(String? sku) => _$this._sku = sku;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  String? _unitPrice;
  String? get unitPrice => _$this._unitPrice;
  set unitPrice(String? unitPrice) => _$this._unitPrice = unitPrice;

  String? _discount;
  String? get discount => _$this._discount;
  set discount(String? discount) => _$this._discount = discount;

  String? _taxRate;
  String? get taxRate => _$this._taxRate;
  set taxRate(String? taxRate) => _$this._taxRate = taxRate;

  String? _taxAmount;
  String? get taxAmount => _$this._taxAmount;
  set taxAmount(String? taxAmount) => _$this._taxAmount = taxAmount;

  String? _amountBeforeTax;
  String? get amountBeforeTax => _$this._amountBeforeTax;
  set amountBeforeTax(String? amountBeforeTax) =>
      _$this._amountBeforeTax = amountBeforeTax;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  bool? _priceIncludesTax;
  bool? get priceIncludesTax => _$this._priceIncludesTax;
  set priceIncludesTax(bool? priceIncludesTax) =>
      _$this._priceIncludesTax = priceIncludesTax;

  EinvoiceLineBuilder() {
    EinvoiceLine._defaults(this);
  }

  EinvoiceLineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _position = $v.position;
      _kind = $v.kind;
      _name = $v.name;
      _sku = $v.sku;
      _unit = $v.unit;
      _quantity = $v.quantity;
      _unitPrice = $v.unitPrice;
      _discount = $v.discount;
      _taxRate = $v.taxRate;
      _taxAmount = $v.taxAmount;
      _amountBeforeTax = $v.amountBeforeTax;
      _amount = $v.amount;
      _priceIncludesTax = $v.priceIncludesTax;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceLine other) {
    _$v = other as _$EinvoiceLine;
  }

  @override
  void update(void Function(EinvoiceLineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceLine build() => _build();

  _$EinvoiceLine _build() {
    final _$result = _$v ??
        _$EinvoiceLine._(
          position: BuiltValueNullFieldError.checkNotNull(
              position, r'EinvoiceLine', 'position'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'EinvoiceLine', 'kind'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'EinvoiceLine', 'name'),
          sku: sku,
          unit: BuiltValueNullFieldError.checkNotNull(
              unit, r'EinvoiceLine', 'unit'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'EinvoiceLine', 'quantity'),
          unitPrice: BuiltValueNullFieldError.checkNotNull(
              unitPrice, r'EinvoiceLine', 'unitPrice'),
          discount: BuiltValueNullFieldError.checkNotNull(
              discount, r'EinvoiceLine', 'discount'),
          taxRate: taxRate,
          taxAmount: BuiltValueNullFieldError.checkNotNull(
              taxAmount, r'EinvoiceLine', 'taxAmount'),
          amountBeforeTax: BuiltValueNullFieldError.checkNotNull(
              amountBeforeTax, r'EinvoiceLine', 'amountBeforeTax'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'EinvoiceLine', 'amount'),
          priceIncludesTax: BuiltValueNullFieldError.checkNotNull(
              priceIncludesTax, r'EinvoiceLine', 'priceIncludesTax'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
