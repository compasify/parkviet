//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'call_board_preparing_inner.g.dart';

/// CallBoardPreparingInner
///
/// Properties:
/// * [number]
/// * [workspaceId]
@BuiltValue()
abstract class CallBoardPreparingInner
    implements Built<CallBoardPreparingInner, CallBoardPreparingInnerBuilder> {
  @BuiltValueField(wireName: r'number')
  int get number;

  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  CallBoardPreparingInner._();

  factory CallBoardPreparingInner(
          [void updates(CallBoardPreparingInnerBuilder b)]) =
      _$CallBoardPreparingInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CallBoardPreparingInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CallBoardPreparingInner> get serializer =>
      _$CallBoardPreparingInnerSerializer();
}

class _$CallBoardPreparingInnerSerializer
    implements PrimitiveSerializer<CallBoardPreparingInner> {
  @override
  final Iterable<Type> types = const [
    CallBoardPreparingInner,
    _$CallBoardPreparingInner
  ];

  @override
  final String wireName = r'CallBoardPreparingInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CallBoardPreparingInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'number';
    yield serializers.serialize(
      object.number,
      specifiedType: const FullType(int),
    );
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CallBoardPreparingInner object, {
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
    required CallBoardPreparingInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.number = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CallBoardPreparingInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CallBoardPreparingInnerBuilder();
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
