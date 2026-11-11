// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_lines_one_of1_columns_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintLinesOneOf1ColumnsInnerKeyEnum
    _$printLinesOneOf1ColumnsInnerKeyEnum_qty =
    const PrintLinesOneOf1ColumnsInnerKeyEnum._('qty');
const PrintLinesOneOf1ColumnsInnerKeyEnum
    _$printLinesOneOf1ColumnsInnerKeyEnum_price =
    const PrintLinesOneOf1ColumnsInnerKeyEnum._('price');
const PrintLinesOneOf1ColumnsInnerKeyEnum
    _$printLinesOneOf1ColumnsInnerKeyEnum_discount =
    const PrintLinesOneOf1ColumnsInnerKeyEnum._('discount');
const PrintLinesOneOf1ColumnsInnerKeyEnum
    _$printLinesOneOf1ColumnsInnerKeyEnum_amount =
    const PrintLinesOneOf1ColumnsInnerKeyEnum._('amount');

PrintLinesOneOf1ColumnsInnerKeyEnum
    _$printLinesOneOf1ColumnsInnerKeyEnumValueOf(String name) {
  switch (name) {
    case 'qty':
      return _$printLinesOneOf1ColumnsInnerKeyEnum_qty;
    case 'price':
      return _$printLinesOneOf1ColumnsInnerKeyEnum_price;
    case 'discount':
      return _$printLinesOneOf1ColumnsInnerKeyEnum_discount;
    case 'amount':
      return _$printLinesOneOf1ColumnsInnerKeyEnum_amount;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintLinesOneOf1ColumnsInnerKeyEnum>
    _$printLinesOneOf1ColumnsInnerKeyEnumValues = BuiltSet<
        PrintLinesOneOf1ColumnsInnerKeyEnum>(const <PrintLinesOneOf1ColumnsInnerKeyEnum>[
  _$printLinesOneOf1ColumnsInnerKeyEnum_qty,
  _$printLinesOneOf1ColumnsInnerKeyEnum_price,
  _$printLinesOneOf1ColumnsInnerKeyEnum_discount,
  _$printLinesOneOf1ColumnsInnerKeyEnum_amount,
]);

Serializer<PrintLinesOneOf1ColumnsInnerKeyEnum>
    _$printLinesOneOf1ColumnsInnerKeyEnumSerializer =
    _$PrintLinesOneOf1ColumnsInnerKeyEnumSerializer();

class _$PrintLinesOneOf1ColumnsInnerKeyEnumSerializer
    implements PrimitiveSerializer<PrintLinesOneOf1ColumnsInnerKeyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'qty': 'qty',
    'price': 'price',
    'discount': 'discount',
    'amount': 'amount',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'qty': 'qty',
    'price': 'price',
    'discount': 'discount',
    'amount': 'amount',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PrintLinesOneOf1ColumnsInnerKeyEnum
  ];
  @override
  final String wireName = 'PrintLinesOneOf1ColumnsInnerKeyEnum';

  @override
  Object serialize(
          Serializers serializers, PrintLinesOneOf1ColumnsInnerKeyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintLinesOneOf1ColumnsInnerKeyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintLinesOneOf1ColumnsInnerKeyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintLinesOneOf1ColumnsInner extends PrintLinesOneOf1ColumnsInner {
  @override
  final PrintLinesOneOf1ColumnsInnerKeyEnum key;
  @override
  final String label;

  factory _$PrintLinesOneOf1ColumnsInner(
          [void Function(PrintLinesOneOf1ColumnsInnerBuilder)? updates]) =>
      (PrintLinesOneOf1ColumnsInnerBuilder()..update(updates))._build();

  _$PrintLinesOneOf1ColumnsInner._({required this.key, required this.label})
      : super._();
  @override
  PrintLinesOneOf1ColumnsInner rebuild(
          void Function(PrintLinesOneOf1ColumnsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintLinesOneOf1ColumnsInnerBuilder toBuilder() =>
      PrintLinesOneOf1ColumnsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintLinesOneOf1ColumnsInner &&
        key == other.key &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintLinesOneOf1ColumnsInner')
          ..add('key', key)
          ..add('label', label))
        .toString();
  }
}

class PrintLinesOneOf1ColumnsInnerBuilder
    implements
        Builder<PrintLinesOneOf1ColumnsInner,
            PrintLinesOneOf1ColumnsInnerBuilder> {
  _$PrintLinesOneOf1ColumnsInner? _$v;

  PrintLinesOneOf1ColumnsInnerKeyEnum? _key;
  PrintLinesOneOf1ColumnsInnerKeyEnum? get key => _$this._key;
  set key(PrintLinesOneOf1ColumnsInnerKeyEnum? key) => _$this._key = key;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  PrintLinesOneOf1ColumnsInnerBuilder() {
    PrintLinesOneOf1ColumnsInner._defaults(this);
  }

  PrintLinesOneOf1ColumnsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintLinesOneOf1ColumnsInner other) {
    _$v = other as _$PrintLinesOneOf1ColumnsInner;
  }

  @override
  void update(void Function(PrintLinesOneOf1ColumnsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintLinesOneOf1ColumnsInner build() => _build();

  _$PrintLinesOneOf1ColumnsInner _build() {
    final _$result = _$v ??
        _$PrintLinesOneOf1ColumnsInner._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'PrintLinesOneOf1ColumnsInner', 'key'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'PrintLinesOneOf1ColumnsInner', 'label'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
