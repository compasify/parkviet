//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/print_lines_one_of_items_inner.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_lines_one_of.g.dart';

/// PrintLinesOneOf
///
/// Properties:
/// * [layout]
/// * [items]
@BuiltValue()
abstract class PrintLinesOneOf
    implements Built<PrintLinesOneOf, PrintLinesOneOfBuilder> {
  @BuiltValueField(wireName: r'layout')
  JsonObject? get layout;

  @BuiltValueField(wireName: r'items')
  BuiltList<PrintLinesOneOfItemsInner> get items;

  PrintLinesOneOf._();

  factory PrintLinesOneOf([void updates(PrintLinesOneOfBuilder b)]) =
      _$PrintLinesOneOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintLinesOneOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintLinesOneOf> get serializer =>
      _$PrintLinesOneOfSerializer();
}

class _$PrintLinesOneOfSerializer
    implements PrimitiveSerializer<PrintLinesOneOf> {
  @override
  final Iterable<Type> types = const [PrintLinesOneOf, _$PrintLinesOneOf];

  @override
  final String wireName = r'PrintLinesOneOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintLinesOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'layout';
    yield object.layout == null
        ? null
        : serializers.serialize(
            object.layout,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType:
          const FullType(BuiltList, [FullType(PrintLinesOneOfItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintLinesOneOf object, {
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
    required PrintLinesOneOfBuilder result,
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
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(PrintLinesOneOfItemsInner)]),
          ) as BuiltList<PrintLinesOneOfItemsInner>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintLinesOneOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintLinesOneOfBuilder();
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
