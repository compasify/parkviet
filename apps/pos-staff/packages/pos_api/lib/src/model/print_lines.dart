//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_lines_one_of1_columns_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/print_lines_one_of1.dart';
import 'package:pos_api/src/model/print_lines_one_of1_headings.dart';
import 'package:pos_api/src/model/print_lines_one_of1_rows_inner.dart';
import 'package:pos_api/src/model/print_lines_one_of_items_inner.dart';
import 'package:pos_api/src/model/print_lines_one_of.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'print_lines.g.dart';

/// PrintLines
///
/// Properties:
/// * [layout]
/// * [items]
/// * [headings]
/// * [columns]
/// * [rows]
@BuiltValue()
abstract class PrintLines implements Built<PrintLines, PrintLinesBuilder> {
  /// One Of [PrintLinesOneOf], [PrintLinesOneOf1]
  OneOf get oneOf;

  PrintLines._();

  factory PrintLines([void updates(PrintLinesBuilder b)]) = _$PrintLines;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintLinesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintLines> get serializer => _$PrintLinesSerializer();
}

class _$PrintLinesSerializer implements PrimitiveSerializer<PrintLines> {
  @override
  final Iterable<Type> types = const [PrintLines, _$PrintLines];

  @override
  final String wireName = r'PrintLines';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintLines object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PrintLines object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  PrintLines deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintLinesBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [
      FullType(PrintLinesOneOf),
      FullType(PrintLinesOneOf1),
    ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc,
        specifiedType: targetType) as OneOf;
    return result.build();
  }
}
