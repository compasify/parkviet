// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintBlockAlignEnum _$printBlockAlignEnum_left =
    const PrintBlockAlignEnum._('left');
const PrintBlockAlignEnum _$printBlockAlignEnum_center =
    const PrintBlockAlignEnum._('center');
const PrintBlockAlignEnum _$printBlockAlignEnum_right =
    const PrintBlockAlignEnum._('right');

PrintBlockAlignEnum _$printBlockAlignEnumValueOf(String name) {
  switch (name) {
    case 'left':
      return _$printBlockAlignEnum_left;
    case 'center':
      return _$printBlockAlignEnum_center;
    case 'right':
      return _$printBlockAlignEnum_right;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockAlignEnum> _$printBlockAlignEnumValues =
    BuiltSet<PrintBlockAlignEnum>(const <PrintBlockAlignEnum>[
  _$printBlockAlignEnum_left,
  _$printBlockAlignEnum_center,
  _$printBlockAlignEnum_right,
]);

const PrintBlockSizeEnum _$printBlockSizeEnum_s =
    const PrintBlockSizeEnum._('s');
const PrintBlockSizeEnum _$printBlockSizeEnum_m =
    const PrintBlockSizeEnum._('m');
const PrintBlockSizeEnum _$printBlockSizeEnum_l =
    const PrintBlockSizeEnum._('l');

PrintBlockSizeEnum _$printBlockSizeEnumValueOf(String name) {
  switch (name) {
    case 's':
      return _$printBlockSizeEnum_s;
    case 'm':
      return _$printBlockSizeEnum_m;
    case 'l':
      return _$printBlockSizeEnum_l;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockSizeEnum> _$printBlockSizeEnumValues =
    BuiltSet<PrintBlockSizeEnum>(const <PrintBlockSizeEnum>[
  _$printBlockSizeEnum_s,
  _$printBlockSizeEnum_m,
  _$printBlockSizeEnum_l,
]);

const PrintBlockStyleEnum _$printBlockStyleEnum_solid =
    const PrintBlockStyleEnum._('solid');
const PrintBlockStyleEnum _$printBlockStyleEnum_dashed =
    const PrintBlockStyleEnum._('dashed');

PrintBlockStyleEnum _$printBlockStyleEnumValueOf(String name) {
  switch (name) {
    case 'solid':
      return _$printBlockStyleEnum_solid;
    case 'dashed':
      return _$printBlockStyleEnum_dashed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockStyleEnum> _$printBlockStyleEnumValues =
    BuiltSet<PrintBlockStyleEnum>(const <PrintBlockStyleEnum>[
  _$printBlockStyleEnum_solid,
  _$printBlockStyleEnum_dashed,
]);

Serializer<PrintBlockAlignEnum> _$printBlockAlignEnumSerializer =
    _$PrintBlockAlignEnumSerializer();
Serializer<PrintBlockSizeEnum> _$printBlockSizeEnumSerializer =
    _$PrintBlockSizeEnumSerializer();
Serializer<PrintBlockStyleEnum> _$printBlockStyleEnumSerializer =
    _$PrintBlockStyleEnumSerializer();

class _$PrintBlockAlignEnumSerializer
    implements PrimitiveSerializer<PrintBlockAlignEnum> {
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
  final Iterable<Type> types = const <Type>[PrintBlockAlignEnum];
  @override
  final String wireName = 'PrintBlockAlignEnum';

  @override
  Object serialize(Serializers serializers, PrintBlockAlignEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockAlignEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockAlignEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlockSizeEnumSerializer
    implements PrimitiveSerializer<PrintBlockSizeEnum> {
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
  final Iterable<Type> types = const <Type>[PrintBlockSizeEnum];
  @override
  final String wireName = 'PrintBlockSizeEnum';

  @override
  Object serialize(Serializers serializers, PrintBlockSizeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockSizeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockSizeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlockStyleEnumSerializer
    implements PrimitiveSerializer<PrintBlockStyleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'solid': 'solid',
    'dashed': 'dashed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'solid': 'solid',
    'dashed': 'dashed',
  };

  @override
  final Iterable<Type> types = const <Type>[PrintBlockStyleEnum];
  @override
  final String wireName = 'PrintBlockStyleEnum';

  @override
  Object serialize(Serializers serializers, PrintBlockStyleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockStyleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockStyleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlock extends PrintBlock {
  @override
  final OneOf oneOf;

  factory _$PrintBlock([void Function(PrintBlockBuilder)? updates]) =>
      (PrintBlockBuilder()..update(updates))._build();

  _$PrintBlock._({required this.oneOf}) : super._();
  @override
  PrintBlock rebuild(void Function(PrintBlockBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockBuilder toBuilder() => PrintBlockBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlock && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlock')..add('oneOf', oneOf))
        .toString();
  }
}

class PrintBlockBuilder implements Builder<PrintBlock, PrintBlockBuilder> {
  _$PrintBlock? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  PrintBlockBuilder() {
    PrintBlock._defaults(this);
  }

  PrintBlockBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlock other) {
    _$v = other as _$PrintBlock;
  }

  @override
  void update(void Function(PrintBlockBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlock build() => _build();

  _$PrintBlock _build() {
    final _$result = _$v ??
        _$PrintBlock._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'PrintBlock', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
