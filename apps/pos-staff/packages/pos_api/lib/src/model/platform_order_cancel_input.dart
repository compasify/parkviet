//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_order_cancel_input.g.dart';

/// PlatformOrderCancelInput
///
/// Properties:
/// * [editorId]
/// * [reason]
/// * [approvalId]
@BuiltValue()
abstract class PlatformOrderCancelInput
    implements
        Built<PlatformOrderCancelInput, PlatformOrderCancelInputBuilder> {
  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  PlatformOrderCancelInput._();

  factory PlatformOrderCancelInput(
          [void updates(PlatformOrderCancelInputBuilder b)]) =
      _$PlatformOrderCancelInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformOrderCancelInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformOrderCancelInput> get serializer =>
      _$PlatformOrderCancelInputSerializer();
}

class _$PlatformOrderCancelInputSerializer
    implements PrimitiveSerializer<PlatformOrderCancelInput> {
  @override
  final Iterable<Type> types = const [
    PlatformOrderCancelInput,
    _$PlatformOrderCancelInput
  ];

  @override
  final String wireName = r'PlatformOrderCancelInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformOrderCancelInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.approvalId != null) {
      yield r'approval_id';
      yield serializers.serialize(
        object.approvalId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformOrderCancelInput object, {
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
    required PlatformOrderCancelInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorId = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformOrderCancelInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformOrderCancelInputBuilder();
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
