//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_order_served_result_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_order_served_result.g.dart';

/// KitchenOrderServedResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class KitchenOrderServedResult
    implements
        Built<KitchenOrderServedResult, KitchenOrderServedResultBuilder> {
  @BuiltValueField(wireName: r'data')
  KitchenOrderServedResultData get data;

  KitchenOrderServedResult._();

  factory KitchenOrderServedResult(
          [void updates(KitchenOrderServedResultBuilder b)]) =
      _$KitchenOrderServedResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenOrderServedResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenOrderServedResult> get serializer =>
      _$KitchenOrderServedResultSerializer();
}

class _$KitchenOrderServedResultSerializer
    implements PrimitiveSerializer<KitchenOrderServedResult> {
  @override
  final Iterable<Type> types = const [
    KitchenOrderServedResult,
    _$KitchenOrderServedResult
  ];

  @override
  final String wireName = r'KitchenOrderServedResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenOrderServedResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KitchenOrderServedResultData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenOrderServedResult object, {
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
    required KitchenOrderServedResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenOrderServedResultData),
          ) as KitchenOrderServedResultData;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenOrderServedResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenOrderServedResultBuilder();
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
