//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/call_board_ready_inner.dart';
import 'package:pos_api/src/model/call_board_preparing_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'call_board.g.dart';

/// Call numbers of the business day. A number is preparing while any item is new or being made, and ready once every item is ready or served with some still waiting; it leaves when served or `pickup_minutes` after it became ready.
///
/// Properties:
/// * [preparing]
/// * [ready]
@BuiltValue()
abstract class CallBoard implements Built<CallBoard, CallBoardBuilder> {
  @BuiltValueField(wireName: r'preparing')
  BuiltList<CallBoardPreparingInner> get preparing;

  @BuiltValueField(wireName: r'ready')
  BuiltList<CallBoardReadyInner> get ready;

  CallBoard._();

  factory CallBoard([void updates(CallBoardBuilder b)]) = _$CallBoard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CallBoardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CallBoard> get serializer => _$CallBoardSerializer();
}

class _$CallBoardSerializer implements PrimitiveSerializer<CallBoard> {
  @override
  final Iterable<Type> types = const [CallBoard, _$CallBoard];

  @override
  final String wireName = r'CallBoard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CallBoard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'preparing';
    yield serializers.serialize(
      object.preparing,
      specifiedType:
          const FullType(BuiltList, [FullType(CallBoardPreparingInner)]),
    );
    yield r'ready';
    yield serializers.serialize(
      object.ready,
      specifiedType: const FullType(BuiltList, [FullType(CallBoardReadyInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CallBoard object, {
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
    required CallBoardBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'preparing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(CallBoardPreparingInner)]),
          ) as BuiltList<CallBoardPreparingInner>;
          result.preparing.replace(valueDes);
          break;
        case r'ready':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(CallBoardReadyInner)]),
          ) as BuiltList<CallBoardReadyInner>;
          result.ready.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CallBoard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CallBoardBuilder();
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
