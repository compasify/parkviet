// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block_one_of6.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintBlockOneOf6StyleEnum _$printBlockOneOf6StyleEnum_solid =
    const PrintBlockOneOf6StyleEnum._('solid');
const PrintBlockOneOf6StyleEnum _$printBlockOneOf6StyleEnum_dashed =
    const PrintBlockOneOf6StyleEnum._('dashed');

PrintBlockOneOf6StyleEnum _$printBlockOneOf6StyleEnumValueOf(String name) {
  switch (name) {
    case 'solid':
      return _$printBlockOneOf6StyleEnum_solid;
    case 'dashed':
      return _$printBlockOneOf6StyleEnum_dashed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockOneOf6StyleEnum> _$printBlockOneOf6StyleEnumValues =
    BuiltSet<PrintBlockOneOf6StyleEnum>(const <PrintBlockOneOf6StyleEnum>[
  _$printBlockOneOf6StyleEnum_solid,
  _$printBlockOneOf6StyleEnum_dashed,
]);

Serializer<PrintBlockOneOf6StyleEnum> _$printBlockOneOf6StyleEnumSerializer =
    _$PrintBlockOneOf6StyleEnumSerializer();

class _$PrintBlockOneOf6StyleEnumSerializer
    implements PrimitiveSerializer<PrintBlockOneOf6StyleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'solid': 'solid',
    'dashed': 'dashed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'solid': 'solid',
    'dashed': 'dashed',
  };

  @override
  final Iterable<Type> types = const <Type>[PrintBlockOneOf6StyleEnum];
  @override
  final String wireName = 'PrintBlockOneOf6StyleEnum';

  @override
  Object serialize(Serializers serializers, PrintBlockOneOf6StyleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockOneOf6StyleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockOneOf6StyleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlockOneOf6 extends PrintBlockOneOf6 {
  @override
  final JsonObject? kind;
  @override
  final PrintBlockOneOf6StyleEnum style;

  factory _$PrintBlockOneOf6(
          [void Function(PrintBlockOneOf6Builder)? updates]) =>
      (PrintBlockOneOf6Builder()..update(updates))._build();

  _$PrintBlockOneOf6._({this.kind, required this.style}) : super._();
  @override
  PrintBlockOneOf6 rebuild(void Function(PrintBlockOneOf6Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockOneOf6Builder toBuilder() =>
      PrintBlockOneOf6Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlockOneOf6 &&
        kind == other.kind &&
        style == other.style;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, style.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlockOneOf6')
          ..add('kind', kind)
          ..add('style', style))
        .toString();
  }
}

class PrintBlockOneOf6Builder
    implements Builder<PrintBlockOneOf6, PrintBlockOneOf6Builder> {
  _$PrintBlockOneOf6? _$v;

  JsonObject? _kind;
  JsonObject? get kind => _$this._kind;
  set kind(JsonObject? kind) => _$this._kind = kind;

  PrintBlockOneOf6StyleEnum? _style;
  PrintBlockOneOf6StyleEnum? get style => _$this._style;
  set style(PrintBlockOneOf6StyleEnum? style) => _$this._style = style;

  PrintBlockOneOf6Builder() {
    PrintBlockOneOf6._defaults(this);
  }

  PrintBlockOneOf6Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _style = $v.style;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlockOneOf6 other) {
    _$v = other as _$PrintBlockOneOf6;
  }

  @override
  void update(void Function(PrintBlockOneOf6Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlockOneOf6 build() => _build();

  _$PrintBlockOneOf6 _build() {
    final _$result = _$v ??
        _$PrintBlockOneOf6._(
          kind: kind,
          style: BuiltValueNullFieldError.checkNotNull(
              style, r'PrintBlockOneOf6', 'style'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
