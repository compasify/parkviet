//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'call_board_ready_inner.g.dart';

/// CallBoardReadyInner
///
/// Properties:
/// * [number]
/// * [workspaceId]
/// * [guestName]
/// * [readyAt]
@BuiltValue()
abstract class CallBoardReadyInner
    implements Built<CallBoardReadyInner, CallBoardReadyInnerBuilder> {
  @BuiltValueField(wireName: r'number')
  int get number;

  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'guest_name')
  String? get guestName;

  @BuiltValueField(wireName: r'ready_at')
  DateTime get readyAt;

  CallBoardReadyInner._();

  factory CallBoardReadyInner([void updates(CallBoardReadyInnerBuilder b)]) =
      _$CallBoardReadyInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CallBoardReadyInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CallBoardReadyInner> get serializer =>
      _$CallBoardReadyInnerSerializer();
}

class _$CallBoardReadyInnerSerializer
    implements PrimitiveSerializer<CallBoardReadyInner> {
  @override
  final Iterable<Type> types = const [
    CallBoardReadyInner,
    _$CallBoardReadyInner
  ];

  @override
  final String wireName = r'CallBoardReadyInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CallBoardReadyInner object, {
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
    yield r'guest_name';
    yield object.guestName == null
        ? null
        : serializers.serialize(
            object.guestName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'ready_at';
    yield serializers.serialize(
      object.readyAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CallBoardReadyInner object, {
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
    required CallBoardReadyInnerBuilder result,
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
        case r'guest_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.guestName = valueDes;
          break;
        case r'ready_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.readyAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CallBoardReadyInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CallBoardReadyInnerBuilder();
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
