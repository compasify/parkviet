//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_lines_one_of1_columns_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/print_lines_one_of1_headings.dart';
import 'package:pos_api/src/model/print_lines_one_of1_rows_inner.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_lines_one_of1.g.dart';

/// PrintLinesOneOf1
///
/// Properties:
/// * [layout]
/// * [headings]
/// * [columns]
/// * [rows]
@BuiltValue()
abstract class PrintLinesOneOf1
    implements Built<PrintLinesOneOf1, PrintLinesOneOf1Builder> {
  @BuiltValueField(wireName: r'layout')
  JsonObject? get layout;

  @BuiltValueField(wireName: r'headings')
  PrintLinesOneOf1Headings get headings;

  @BuiltValueField(wireName: r'columns')
  BuiltList<PrintLinesOneOf1ColumnsInner> get columns;

  @BuiltValueField(wireName: r'rows')
  BuiltList<PrintLinesOneOf1RowsInner> get rows;

  PrintLinesOneOf1._();

  factory PrintLinesOneOf1([void updates(PrintLinesOneOf1Builder b)]) =
      _$PrintLinesOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintLinesOneOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintLinesOneOf1> get serializer =>
      _$PrintLinesOneOf1Serializer();
}

class _$PrintLinesOneOf1Serializer
    implements PrimitiveSerializer<PrintLinesOneOf1> {
  @override
  final Iterable<Type> types = const [PrintLinesOneOf1, _$PrintLinesOneOf1];

  @override
  final String wireName = r'PrintLinesOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintLinesOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'layout';
    yield object.layout == null
        ? null
        : serializers.serialize(
            object.layout,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'headings';
    yield serializers.serialize(
      object.headings,
      specifiedType: const FullType(PrintLinesOneOf1Headings),
    );
    yield r'columns';
    yield serializers.serialize(
      object.columns,
      specifiedType:
          const FullType(BuiltList, [FullType(PrintLinesOneOf1ColumnsInner)]),
    );
    yield r'rows';
    yield serializers.serialize(
      object.rows,
      specifiedType:
          const FullType(BuiltList, [FullType(PrintLinesOneOf1RowsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintLinesOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PrintLinesOneOf1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'layout':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.layout = valueDes;
          break;
        case r'headings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintLinesOneOf1Headings),
          ) as PrintLinesOneOf1Headings;
          result.headings.replace(valueDes);
          break;
        case r'columns':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(PrintLinesOneOf1ColumnsInner)]),
          ) as BuiltList<PrintLinesOneOf1ColumnsInner>;
          result.columns.replace(valueDes);
          break;
        case r'rows':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(PrintLinesOneOf1RowsInner)]),
          ) as BuiltList<PrintLinesOneOf1RowsInner>;
          result.rows.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintLinesOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintLinesOneOf1Builder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
