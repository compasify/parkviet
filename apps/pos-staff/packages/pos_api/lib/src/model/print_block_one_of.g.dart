// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block_one_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintBlockOneOfAlignEnum _$printBlockOneOfAlignEnum_left =
    const PrintBlockOneOfAlignEnum._('left');
const PrintBlockOneOfAlignEnum _$printBlockOneOfAlignEnum_center =
    const PrintBlockOneOfAlignEnum._('center');
const PrintBlockOneOfAlignEnum _$printBlockOneOfAlignEnum_right =
    const PrintBlockOneOfAlignEnum._('right');

PrintBlockOneOfAlignEnum _$printBlockOneOfAlignEnumValueOf(String name) {
  switch (name) {
    case 'left':
      return _$printBlockOneOfAlignEnum_left;
    case 'center':
      return _$printBlockOneOfAlignEnum_center;
    case 'right':
      return _$printBlockOneOfAlignEnum_right;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockOneOfAlignEnum> _$printBlockOneOfAlignEnumValues =
    BuiltSet<PrintBlockOneOfAlignEnum>(const <PrintBlockOneOfAlignEnum>[
  _$printBlockOneOfAlignEnum_left,
  _$printBlockOneOfAlignEnum_center,
  _$printBlockOneOfAlignEnum_right,
]);

const PrintBlockOneOfSizeEnum _$printBlockOneOfSizeEnum_s =
    const PrintBlockOneOfSizeEnum._('s');
const PrintBlockOneOfSizeEnum _$printBlockOneOfSizeEnum_m =
    const PrintBlockOneOfSizeEnum._('m');
const PrintBlockOneOfSizeEnum _$printBlockOneOfSizeEnum_l =
    const PrintBlockOneOfSizeEnum._('l');

PrintBlockOneOfSizeEnum _$printBlockOneOfSizeEnumValueOf(String name) {
  switch (name) {
    case 's':
      return _$printBlockOneOfSizeEnum_s;
    case 'm':
      return _$printBlockOneOfSizeEnum_m;
    case 'l':
      return _$printBlockOneOfSizeEnum_l;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockOneOfSizeEnum> _$printBlockOneOfSizeEnumValues =
    BuiltSet<PrintBlockOneOfSizeEnum>(const <PrintBlockOneOfSizeEnum>[
  _$printBlockOneOfSizeEnum_s,
  _$printBlockOneOfSizeEnum_m,
  _$printBlockOneOfSizeEnum_l,
]);

Serializer<PrintBlockOneOfAlignEnum> _$printBlockOneOfAlignEnumSerializer =
    _$PrintBlockOneOfAlignEnumSerializer();
Serializer<PrintBlockOneOfSizeEnum> _$printBlockOneOfSizeEnumSerializer =
    _$PrintBlockOneOfSizeEnumSerializer();

class _$PrintBlockOneOfAlignEnumSerializer
    implements PrimitiveSerializer<PrintBlockOneOfAlignEnum> {
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
  final Iterable<Type> types = const <Type>[PrintBlockOneOfAlignEnum];
  @override
  final String wireName = 'PrintBlockOneOfAlignEnum';

  @override
  Object serialize(Serializers serializers, PrintBlockOneOfAlignEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockOneOfAlignEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockOneOfAlignEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlockOneOfSizeEnumSerializer
    implements PrimitiveSerializer<PrintBlockOneOfSizeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    's': 's',
    'm': 'm',
    'l': 'l',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    's': 's',
    'm': 'm',
    'l': 'l',
  };

  @override
  final Iterable<Type> types = const <Type>[PrintBlockOneOfSizeEnum];
  @override
  final String wireName = 'PrintBlockOneOfSizeEnum';

  @override
  Object serialize(Serializers serializers, PrintBlockOneOfSizeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockOneOfSizeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockOneOfSizeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlockOneOf extends PrintBlockOneOf {
  @override
  final JsonObject? kind;
  @override
  final BuiltList<String> lines;
  @override
  final PrintBlockOneOfAlignEnum align;
  @override
  final bool bold;
  @override
  final PrintBlockOneOfSizeEnum size;
  @override
  final bool? invert;

  factory _$PrintBlockOneOf([void Function(PrintBlockOneOfBuilder)? updates]) =>
      (PrintBlockOneOfBuilder()..update(updates))._build();

  _$PrintBlockOneOf._(
      {this.kind,
      required this.lines,
      required this.align,
      required this.bold,
      required this.size,
      this.invert})
      : super._();
  @override
  PrintBlockOneOf rebuild(void Function(PrintBlockOneOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockOneOfBuilder toBuilder() => PrintBlockOneOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlockOneOf &&
        kind == other.kind &&
        lines == other.lines &&
        align == other.align &&
        bold == other.bold &&
        size == other.size &&
        invert == other.invert;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jc(_$hash, align.hashCode);
    _$hash = $jc(_$hash, bold.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, invert.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlockOneOf')
          ..add('kind', kind)
          ..add('lines', lines)
          ..add('align', align)
          ..add('bold', bold)
          ..add('size', size)
          ..add('invert', invert))
        .toString();
  }
}

class PrintBlockOneOfBuilder
    implements Builder<PrintBlockOneOf, PrintBlockOneOfBuilder> {
  _$PrintBlockOneOf? _$v;

  JsonObject? _kind;
  JsonObject? get kind => _$this._kind;
  set kind(JsonObject? kind) => _$this._kind = kind;

  ListBuilder<String>? _lines;
  ListBuilder<String> get lines => _$this._lines ??= ListBuilder<String>();
  set lines(ListBuilder<String>? lines) => _$this._lines = lines;

  PrintBlockOneOfAlignEnum? _align;
  PrintBlockOneOfAlignEnum? get align => _$this._align;
  set align(PrintBlockOneOfAlignEnum? align) => _$this._align = align;

  bool? _bold;
  bool? get bold => _$this._bold;
  set bold(bool? bold) => _$this._bold = bold;

  PrintBlockOneOfSizeEnum? _size;
  PrintBlockOneOfSizeEnum? get size => _$this._size;
  set size(PrintBlockOneOfSizeEnum? size) => _$this._size = size;

  bool? _invert;
  bool? get invert => _$this._invert;
  set invert(bool? invert) => _$this._invert = invert;

  PrintBlockOneOfBuilder() {
    PrintBlockOneOf._defaults(this);
  }

  PrintBlockOneOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _lines = $v.lines.toBuilder();
      _align = $v.align;
      _bold = $v.bold;
      _size = $v.size;
      _invert = $v.invert;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlockOneOf other) {
    _$v = other as _$PrintBlockOneOf;
  }

  @override
  void update(void Function(PrintBlockOneOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlockOneOf build() => _build();

  _$PrintBlockOneOf _build() {
    _$PrintBlockOneOf _$result;
    try {
      _$result = _$v ??
          _$PrintBlockOneOf._(
            kind: kind,
            lines: lines.build(),
            align: BuiltValueNullFieldError.checkNotNull(
                align, r'PrintBlockOneOf', 'align'),
            bold: BuiltValueNullFieldError.checkNotNull(
                bold, r'PrintBlockOneOf', 'bold'),
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'PrintBlockOneOf', 'size'),
            invert: invert,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lines';
        lines.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintBlockOneOf', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
