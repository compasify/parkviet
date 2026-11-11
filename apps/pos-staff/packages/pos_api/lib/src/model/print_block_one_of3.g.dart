// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block_one_of3.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintBlockOneOf3AlignEnum _$printBlockOneOf3AlignEnum_left =
    const PrintBlockOneOf3AlignEnum._('left');
const PrintBlockOneOf3AlignEnum _$printBlockOneOf3AlignEnum_center =
    const PrintBlockOneOf3AlignEnum._('center');
const PrintBlockOneOf3AlignEnum _$printBlockOneOf3AlignEnum_right =
    const PrintBlockOneOf3AlignEnum._('right');

PrintBlockOneOf3AlignEnum _$printBlockOneOf3AlignEnumValueOf(String name) {
  switch (name) {
    case 'left':
      return _$printBlockOneOf3AlignEnum_left;
    case 'center':
      return _$printBlockOneOf3AlignEnum_center;
    case 'right':
      return _$printBlockOneOf3AlignEnum_right;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockOneOf3AlignEnum> _$printBlockOneOf3AlignEnumValues =
    BuiltSet<PrintBlockOneOf3AlignEnum>(const <PrintBlockOneOf3AlignEnum>[
  _$printBlockOneOf3AlignEnum_left,
  _$printBlockOneOf3AlignEnum_center,
  _$printBlockOneOf3AlignEnum_right,
]);

Serializer<PrintBlockOneOf3AlignEnum> _$printBlockOneOf3AlignEnumSerializer =
    _$PrintBlockOneOf3AlignEnumSerializer();

class _$PrintBlockOneOf3AlignEnumSerializer
    implements PrimitiveSerializer<PrintBlockOneOf3AlignEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'left': 'left',
    'center': 'center',
    'right': 'right',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'left': 'left',
    'center': 'center',
    'right': 'right',
  };

  @override
  final Iterable<Type> types = const <Type>[PrintBlockOneOf3AlignEnum];
  @override
  final String wireName = 'PrintBlockOneOf3AlignEnum';

  @override
  Object serialize(Serializers serializers, PrintBlockOneOf3AlignEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockOneOf3AlignEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockOneOf3AlignEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlockOneOf3 extends PrintBlockOneOf3 {
  @override
  final JsonObject? kind;
  @override
  final String value;
  @override
  final PrintBlockOneOf3AlignEnum align;

  factory _$PrintBlockOneOf3(
          [void Function(PrintBlockOneOf3Builder)? updates]) =>
      (PrintBlockOneOf3Builder()..update(updates))._build();

  _$PrintBlockOneOf3._({this.kind, required this.value, required this.align})
      : super._();
  @override
  PrintBlockOneOf3 rebuild(void Function(PrintBlockOneOf3Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockOneOf3Builder toBuilder() =>
      PrintBlockOneOf3Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlockOneOf3 &&
        kind == other.kind &&
        value == other.value &&
        align == other.align;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, align.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlockOneOf3')
          ..add('kind', kind)
          ..add('value', value)
          ..add('align', align))
        .toString();
  }
}

class PrintBlockOneOf3Builder
    implements Builder<PrintBlockOneOf3, PrintBlockOneOf3Builder> {
  _$PrintBlockOneOf3? _$v;

  JsonObject? _kind;
  JsonObject? get kind => _$this._kind;
  set kind(JsonObject? kind) => _$this._kind = kind;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  PrintBlockOneOf3AlignEnum? _align;
  PrintBlockOneOf3AlignEnum? get align => _$this._align;
  set align(PrintBlockOneOf3AlignEnum? align) => _$this._align = align;

  PrintBlockOneOf3Builder() {
    PrintBlockOneOf3._defaults(this);
  }

  PrintBlockOneOf3Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _value = $v.value;
      _align = $v.align;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlockOneOf3 other) {
    _$v = other as _$PrintBlockOneOf3;
  }

  @override
  void update(void Function(PrintBlockOneOf3Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlockOneOf3 build() => _build();

  _$PrintBlockOneOf3 _build() {
    final _$result = _$v ??
        _$PrintBlockOneOf3._(
          kind: kind,
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'PrintBlockOneOf3', 'value'),
          align: BuiltValueNullFieldError.checkNotNull(
              align, r'PrintBlockOneOf3', 'align'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
