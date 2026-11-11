//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_block_one_of5.dart';
import 'package:pos_api/src/model/print_block_one_of.dart';
import 'package:pos_api/src/model/print_block_one_of3.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/print_block_one_of7.dart';
import 'package:pos_api/src/model/print_block_one_of2.dart';
import 'package:pos_api/src/model/print_block_one_of6.dart';
import 'package:pos_api/src/model/print_block_one_of1.dart';
import 'package:pos_api/src/model/print_block_one_of4_parties_inner.dart';
import 'package:pos_api/src/model/print_block_one_of4.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'print_block.g.dart';

/// PrintBlock
///
/// Properties:
/// * [kind]
/// * [lines]
/// * [align]
/// * [bold]
/// * [size]
/// * [invert] - White on black (a kitchen note). Absent means false.
/// * [src]
/// * [alt]
/// * [widthPct]
/// * [monochrome]
/// * [value]
/// * [caption]
/// * [parties]
/// * [title]
/// * [number]
/// * [style]
/// * [mm]
@BuiltValue()
abstract class PrintBlock implements Built<PrintBlock, PrintBlockBuilder> {
  /// One Of [PrintBlockOneOf], [PrintBlockOneOf1], [PrintBlockOneOf2], [PrintBlockOneOf3], [PrintBlockOneOf4], [PrintBlockOneOf5], [PrintBlockOneOf6], [PrintBlockOneOf7]
  OneOf get oneOf;

  PrintBlock._();

  factory PrintBlock([void updates(PrintBlockBuilder b)]) = _$PrintBlock;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlock> get serializer => _$PrintBlockSerializer();
}

class _$PrintBlockSerializer implements PrimitiveSerializer<PrintBlock> {
  @override
  final Iterable<Type> types = const [PrintBlock, _$PrintBlock];

  @override
  final String wireName = r'PrintBlock';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlock object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PrintBlock object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  PrintBlock deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [
      FullType(PrintBlockOneOf),
      FullType(PrintBlockOneOf1),
      FullType(PrintBlockOneOf2),
      FullType(PrintBlockOneOf3),
      FullType(PrintBlockOneOf4),
      FullType(PrintBlockOneOf5),
      FullType(PrintBlockOneOf6),
      FullType(PrintBlockOneOf7),
    ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc,
        specifiedType: targetType) as OneOf;
    return result.build();
  }
}

class PrintBlockAlignEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'left')
  static const PrintBlockAlignEnum left = _$printBlockAlignEnum_left;
  @BuiltValueEnumConst(wireName: r'center')
  static const PrintBlockAlignEnum center = _$printBlockAlignEnum_center;
  @BuiltValueEnumConst(wireName: r'right')
  static const PrintBlockAlignEnum right = _$printBlockAlignEnum_right;

  static Serializer<PrintBlockAlignEnum> get serializer =>
      _$printBlockAlignEnumSerializer;

  const PrintBlockAlignEnum._(String name) : super(name);

  static BuiltSet<PrintBlockAlignEnum> get values =>
      _$printBlockAlignEnumValues;
  static PrintBlockAlignEnum valueOf(String name) =>
      _$printBlockAlignEnumValueOf(name);
}

class PrintBlockSizeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r's')
  static const PrintBlockSizeEnum s = _$printBlockSizeEnum_s;
  @BuiltValueEnumConst(wireName: r'm')
  static const PrintBlockSizeEnum m = _$printBlockSizeEnum_m;
  @BuiltValueEnumConst(wireName: r'l')
  static const PrintBlockSizeEnum l = _$printBlockSizeEnum_l;

  static Serializer<PrintBlockSizeEnum> get serializer =>
      _$printBlockSizeEnumSerializer;

  const PrintBlockSizeEnum._(String name) : super(name);

  static BuiltSet<PrintBlockSizeEnum> get values => _$printBlockSizeEnumValues;
  static PrintBlockSizeEnum valueOf(String name) =>
      _$printBlockSizeEnumValueOf(name);
}

class PrintBlockStyleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'solid')
  static const PrintBlockStyleEnum solid = _$printBlockStyleEnum_solid;
  @BuiltValueEnumConst(wireName: r'dashed')
  static const PrintBlockStyleEnum dashed = _$printBlockStyleEnum_dashed;

  static Serializer<PrintBlockStyleEnum> get serializer =>
      _$printBlockStyleEnumSerializer;

  const PrintBlockStyleEnum._(String name) : super(name);

  static BuiltSet<PrintBlockStyleEnum> get values =>
      _$printBlockStyleEnumValues;
  static PrintBlockStyleEnum valueOf(String name) =>
      _$printBlockStyleEnumValueOf(name);
}
