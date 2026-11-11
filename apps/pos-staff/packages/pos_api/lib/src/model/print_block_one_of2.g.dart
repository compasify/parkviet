// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block_one_of2.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintBlockOneOf2AlignEnum _$printBlockOneOf2AlignEnum_left =
    const PrintBlockOneOf2AlignEnum._('left');
const PrintBlockOneOf2AlignEnum _$printBlockOneOf2AlignEnum_center =
    const PrintBlockOneOf2AlignEnum._('center');
const PrintBlockOneOf2AlignEnum _$printBlockOneOf2AlignEnum_right =
    const PrintBlockOneOf2AlignEnum._('right');

PrintBlockOneOf2AlignEnum _$printBlockOneOf2AlignEnumValueOf(String name) {
  switch (name) {
    case 'left':
      return _$printBlockOneOf2AlignEnum_left;
    case 'center':
      return _$printBlockOneOf2AlignEnum_center;
    case 'right':
      return _$printBlockOneOf2AlignEnum_right;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockOneOf2AlignEnum> _$printBlockOneOf2AlignEnumValues =
    BuiltSet<PrintBlockOneOf2AlignEnum>(const <PrintBlockOneOf2AlignEnum>[
  _$printBlockOneOf2AlignEnum_left,
  _$printBlockOneOf2AlignEnum_center,
  _$printBlockOneOf2AlignEnum_right,
]);

Serializer<PrintBlockOneOf2AlignEnum> _$printBlockOneOf2AlignEnumSerializer =
    _$PrintBlockOneOf2AlignEnumSerializer();

class _$PrintBlockOneOf2AlignEnumSerializer
    implements PrimitiveSerializer<PrintBlockOneOf2AlignEnum> {
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
  final Iterable<Type> types = const <Type>[PrintBlockOneOf2AlignEnum];
  @override
  final String wireName = 'PrintBlockOneOf2AlignEnum';

  @override
  Object serialize(Serializers serializers, PrintBlockOneOf2AlignEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockOneOf2AlignEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockOneOf2AlignEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlockOneOf2 extends PrintBlockOneOf2 {
  @override
  final JsonObject? kind;
  @override
  final String value;
  @override
  final String? caption;
  @override
  final PrintBlockOneOf2AlignEnum align;

  factory _$PrintBlockOneOf2(
          [void Function(PrintBlockOneOf2Builder)? updates]) =>
      (PrintBlockOneOf2Builder()..update(updates))._build();

  _$PrintBlockOneOf2._(
      {this.kind, required this.value, this.caption, required this.align})
      : super._();
  @override
  PrintBlockOneOf2 rebuild(void Function(PrintBlockOneOf2Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockOneOf2Builder toBuilder() =>
      PrintBlockOneOf2Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlockOneOf2 &&
        kind == other.kind &&
        value == other.value &&
        caption == other.caption &&
        align == other.align;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, caption.hashCode);
    _$hash = $jc(_$hash, align.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlockOneOf2')
          ..add('kind', kind)
          ..add('value', value)
          ..add('caption', caption)
          ..add('align', align))
        .toString();
  }
}

class PrintBlockOneOf2Builder
    implements Builder<PrintBlockOneOf2, PrintBlockOneOf2Builder> {
  _$PrintBlockOneOf2? _$v;

  JsonObject? _kind;
  JsonObject? get kind => _$this._kind;
  set kind(JsonObject? kind) => _$this._kind = kind;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _caption;
  String? get caption => _$this._caption;
  set caption(String? caption) => _$this._caption = caption;

  PrintBlockOneOf2AlignEnum? _align;
  PrintBlockOneOf2AlignEnum? get align => _$this._align;
  set align(PrintBlockOneOf2AlignEnum? align) => _$this._align = align;

  PrintBlockOneOf2Builder() {
    PrintBlockOneOf2._defaults(this);
  }

  PrintBlockOneOf2Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _value = $v.value;
      _caption = $v.caption;
      _align = $v.align;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlockOneOf2 other) {
    _$v = other as _$PrintBlockOneOf2;
  }

  @override
  void update(void Function(PrintBlockOneOf2Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlockOneOf2 build() => _build();

  _$PrintBlockOneOf2 _build() {
    final _$result = _$v ??
        _$PrintBlockOneOf2._(
          kind: kind,
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'PrintBlockOneOf2', 'value'),
          caption: caption,
          align: BuiltValueNullFieldError.checkNotNull(
              align, r'PrintBlockOneOf2', 'align'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
