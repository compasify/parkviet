//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_workspace_guest_name_request.g.dart';

/// PosWorkspaceGuestNameRequest
///
/// Properties:
/// * [expectedRevision]
/// * [leaseGeneration]
/// * [editorId]
/// * [guestName]
@BuiltValue()
abstract class PosWorkspaceGuestNameRequest
    implements
        Built<PosWorkspaceGuestNameRequest,
            PosWorkspaceGuestNameRequestBuilder> {
  @BuiltValueField(wireName: r'expected_revision')
  int get expectedRevision;

  @BuiltValueField(wireName: r'lease_generation')
  int get leaseGeneration;

  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  @BuiltValueField(wireName: r'guest_name')
  String? get guestName;

  PosWorkspaceGuestNameRequest._();

  factory PosWorkspaceGuestNameRequest(
          [void updates(PosWorkspaceGuestNameRequestBuilder b)]) =
      _$PosWorkspaceGuestNameRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosWorkspaceGuestNameRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosWorkspaceGuestNameRequest> get serializer =>
      _$PosWorkspaceGuestNameRequestSerializer();
}

class _$PosWorkspaceGuestNameRequestSerializer
    implements PrimitiveSerializer<PosWorkspaceGuestNameRequest> {
  @override
  final Iterable<Type> types = const [
    PosWorkspaceGuestNameRequest,
    _$PosWorkspaceGuestNameRequest
  ];

  @override
  final String wireName = r'PosWorkspaceGuestNameRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosWorkspaceGuestNameRequest object, {
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
    yield r'guest_name';
    yield object.guestName == null
        ? null
        : serializers.serialize(
            object.guestName,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosWorkspaceGuestNameRequest object, {
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
    required PosWorkspaceGuestNameRequestBuilder result,
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
        case r'guest_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.guestName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosWorkspaceGuestNameRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosWorkspaceGuestNameRequestBuilder();
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
