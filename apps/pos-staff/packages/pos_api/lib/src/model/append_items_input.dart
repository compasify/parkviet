//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/append_item.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'append_items_input.g.dart';

/// AppendItemsInput
///
/// Properties:
/// * [items]
/// * [appendBatchId] - One per \"add to order\" press; groups the batch's lines.
@BuiltValue()
abstract class AppendItemsInput
    implements Built<AppendItemsInput, AppendItemsInputBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<AppendItem> get items;

  /// One per \"add to order\" press; groups the batch's lines.
  @BuiltValueField(wireName: r'append_batch_id')
  String? get appendBatchId;

  AppendItemsInput._();

  factory AppendItemsInput([void updates(AppendItemsInputBuilder b)]) =
      _$AppendItemsInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppendItemsInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppendItemsInput> get serializer =>
      _$AppendItemsInputSerializer();
}

class _$AppendItemsInputSerializer
    implements PrimitiveSerializer<AppendItemsInput> {
  @override
  final Iterable<Type> types = const [AppendItemsInput, _$AppendItemsInput];

  @override
  final String wireName = r'AppendItemsInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppendItemsInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(AppendItem)]),
    );
    if (object.appendBatchId != null) {
      yield r'append_batch_id';
      yield serializers.serialize(
        object.appendBatchId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AppendItemsInput object, {
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
    required AppendItemsInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AppendItem)]),
          ) as BuiltList<AppendItem>;
          result.items.replace(valueDes);
          break;
        case r'append_batch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appendBatchId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppendItemsInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppendItemsInputBuilder();
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
