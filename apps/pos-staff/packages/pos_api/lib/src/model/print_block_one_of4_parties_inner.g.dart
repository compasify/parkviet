// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block_one_of4_parties_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintBlockOneOf4PartiesInnerPartyEnum
    _$printBlockOneOf4PartiesInnerPartyEnum_buyer =
    const PrintBlockOneOf4PartiesInnerPartyEnum._('buyer');
const PrintBlockOneOf4PartiesInnerPartyEnum
    _$printBlockOneOf4PartiesInnerPartyEnum_seller =
    const PrintBlockOneOf4PartiesInnerPartyEnum._('seller');
const PrintBlockOneOf4PartiesInnerPartyEnum
    _$printBlockOneOf4PartiesInnerPartyEnum_cashier =
    const PrintBlockOneOf4PartiesInnerPartyEnum._('cashier');

PrintBlockOneOf4PartiesInnerPartyEnum
    _$printBlockOneOf4PartiesInnerPartyEnumValueOf(String name) {
  switch (name) {
    case 'buyer':
      return _$printBlockOneOf4PartiesInnerPartyEnum_buyer;
    case 'seller':
      return _$printBlockOneOf4PartiesInnerPartyEnum_seller;
    case 'cashier':
      return _$printBlockOneOf4PartiesInnerPartyEnum_cashier;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockOneOf4PartiesInnerPartyEnum>
    _$printBlockOneOf4PartiesInnerPartyEnumValues = BuiltSet<
        PrintBlockOneOf4PartiesInnerPartyEnum>(const <PrintBlockOneOf4PartiesInnerPartyEnum>[
  _$printBlockOneOf4PartiesInnerPartyEnum_buyer,
  _$printBlockOneOf4PartiesInnerPartyEnum_seller,
  _$printBlockOneOf4PartiesInnerPartyEnum_cashier,
]);

Serializer<PrintBlockOneOf4PartiesInnerPartyEnum>
    _$printBlockOneOf4PartiesInnerPartyEnumSerializer =
    _$PrintBlockOneOf4PartiesInnerPartyEnumSerializer();

class _$PrintBlockOneOf4PartiesInnerPartyEnumSerializer
    implements PrimitiveSerializer<PrintBlockOneOf4PartiesInnerPartyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'buyer': 'buyer',
    'seller': 'seller',
    'cashier': 'cashier',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'buyer': 'buyer',
    'seller': 'seller',
    'cashier': 'cashier',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PrintBlockOneOf4PartiesInnerPartyEnum
  ];
  @override
  final String wireName = 'PrintBlockOneOf4PartiesInnerPartyEnum';

  @override
  Object serialize(
          Serializers serializers, PrintBlockOneOf4PartiesInnerPartyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockOneOf4PartiesInnerPartyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockOneOf4PartiesInnerPartyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlockOneOf4PartiesInner extends PrintBlockOneOf4PartiesInner {
  @override
  final PrintBlockOneOf4PartiesInnerPartyEnum party;
  @override
  final String label;

  factory _$PrintBlockOneOf4PartiesInner(
          [void Function(PrintBlockOneOf4PartiesInnerBuilder)? updates]) =>
      (PrintBlockOneOf4PartiesInnerBuilder()..update(updates))._build();

  _$PrintBlockOneOf4PartiesInner._({required this.party, required this.label})
      : super._();
  @override
  PrintBlockOneOf4PartiesInner rebuild(
          void Function(PrintBlockOneOf4PartiesInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockOneOf4PartiesInnerBuilder toBuilder() =>
      PrintBlockOneOf4PartiesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlockOneOf4PartiesInner &&
        party == other.party &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, party.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlockOneOf4PartiesInner')
          ..add('party', party)
          ..add('label', label))
        .toString();
  }
}

class PrintBlockOneOf4PartiesInnerBuilder
    implements
        Builder<PrintBlockOneOf4PartiesInner,
            PrintBlockOneOf4PartiesInnerBuilder> {
  _$PrintBlockOneOf4PartiesInner? _$v;

  PrintBlockOneOf4PartiesInnerPartyEnum? _party;
  PrintBlockOneOf4PartiesInnerPartyEnum? get party => _$this._party;
  set party(PrintBlockOneOf4PartiesInnerPartyEnum? party) =>
      _$this._party = party;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  PrintBlockOneOf4PartiesInnerBuilder() {
    PrintBlockOneOf4PartiesInner._defaults(this);
  }

  PrintBlockOneOf4PartiesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _party = $v.party;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlockOneOf4PartiesInner other) {
    _$v = other as _$PrintBlockOneOf4PartiesInner;
  }

  @override
  void update(void Function(PrintBlockOneOf4PartiesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlockOneOf4PartiesInner build() => _build();

  _$PrintBlockOneOf4PartiesInner _build() {
    final _$result = _$v ??
        _$PrintBlockOneOf4PartiesInner._(
          party: BuiltValueNullFieldError.checkNotNull(
              party, r'PrintBlockOneOf4PartiesInner', 'party'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'PrintBlockOneOf4PartiesInner', 'label'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
