//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kitchen_send_request.g.dart';

/// PosKitchenSendRequest
///
/// Properties:
/// * [expectedRevision]
/// * [leaseGeneration]
/// * [editorId]
@BuiltValue()
abstract class PosKitchenSendRequest
    implements Built<PosKitchenSendRequest, PosKitchenSendRequestBuilder> {
  @BuiltValueField(wireName: r'expected_revision')
  int get expectedRevision;

  @BuiltValueField(wireName: r'lease_generation')
  int get leaseGeneration;

  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  PosKitchenSendRequest._();

  factory PosKitchenSendRequest(
      [void updates(PosKitchenSendRequestBuilder b)]) = _$PosKitchenSendRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKitchenSendRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKitchenSendRequest> get serializer =>
      _$PosKitchenSendRequestSerializer();
}

class _$PosKitchenSendRequestSerializer
    implements PrimitiveSerializer<PosKitchenSendRequest> {
  @override
  final Iterable<Type> types = const [
    PosKitchenSendRequest,
    _$PosKitchenSendRequest
  ];

  @override
  final String wireName = r'PosKitchenSendRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKitchenSendRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expected_revision';
    yield serializers.serialize(
      object.expectedRevision,
      specifiedType: const FullType(int),
    );
    yield r'lease_generation';
    yield serializers.serialize(
      object.leaseGeneration,
      specifiedType: const FullType(int),
    );
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKitchenSendRequest object, {
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
    required PosKitchenSendRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expected_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedRevision = valueDes;
          break;
        case r'lease_generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.leaseGeneration = valueDes;
          break;
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosKitchenSendRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKitchenSendRequestBuilder();
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
