//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_board.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_board_result.g.dart';

/// KitchenBoardResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class KitchenBoardResult
    implements Built<KitchenBoardResult, KitchenBoardResultBuilder> {
  @BuiltValueField(wireName: r'data')
  KitchenBoard get data;

  KitchenBoardResult._();

  factory KitchenBoardResult([void updates(KitchenBoardResultBuilder b)]) =
      _$KitchenBoardResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenBoardResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenBoardResult> get serializer =>
      _$KitchenBoardResultSerializer();
}

class _$KitchenBoardResultSerializer
    implements PrimitiveSerializer<KitchenBoardResult> {
  @override
  final Iterable<Type> types = const [KitchenBoardResult, _$KitchenBoardResult];

  @override
  final String wireName = r'KitchenBoardResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenBoardResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KitchenBoard),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenBoardResult object, {
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
    required KitchenBoardResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenBoard),
          ) as KitchenBoard;
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
  KitchenBoardResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenBoardResultBuilder();
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
