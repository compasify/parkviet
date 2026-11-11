//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_history.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_history_result.g.dart';

/// KitchenHistoryResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class KitchenHistoryResult
    implements Built<KitchenHistoryResult, KitchenHistoryResultBuilder> {
  @BuiltValueField(wireName: r'data')
  KitchenHistory get data;

  KitchenHistoryResult._();

  factory KitchenHistoryResult([void updates(KitchenHistoryResultBuilder b)]) =
      _$KitchenHistoryResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenHistoryResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenHistoryResult> get serializer =>
      _$KitchenHistoryResultSerializer();
}

class _$KitchenHistoryResultSerializer
    implements PrimitiveSerializer<KitchenHistoryResult> {
  @override
  final Iterable<Type> types = const [
    KitchenHistoryResult,
    _$KitchenHistoryResult
  ];

  @override
  final String wireName = r'KitchenHistoryResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenHistoryResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KitchenHistory),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenHistoryResult object, {
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
    required KitchenHistoryResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenHistory),
          ) as KitchenHistory;
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
  KitchenHistoryResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenHistoryResultBuilder();
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
