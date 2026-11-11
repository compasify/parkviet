//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/modifier_selection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_workspace_line_modifiers_request.g.dart';

/// PosWorkspaceLineModifiersRequest
///
/// Properties:
/// * [expectedRevision]
/// * [leaseGeneration]
/// * [editorId]
/// * [modifiers]
/// * [note]
@BuiltValue()
abstract class PosWorkspaceLineModifiersRequest
    implements
        Built<PosWorkspaceLineModifiersRequest,
            PosWorkspaceLineModifiersRequestBuilder> {
  @BuiltValueField(wireName: r'expected_revision')
  int get expectedRevision;

  @BuiltValueField(wireName: r'lease_generation')
  int get leaseGeneration;

  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<ModifierSelection> get modifiers;

  @BuiltValueField(wireName: r'note')
  String? get note;

  PosWorkspaceLineModifiersRequest._();

  factory PosWorkspaceLineModifiersRequest(
          [void updates(PosWorkspaceLineModifiersRequestBuilder b)]) =
      _$PosWorkspaceLineModifiersRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosWorkspaceLineModifiersRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosWorkspaceLineModifiersRequest> get serializer =>
      _$PosWorkspaceLineModifiersRequestSerializer();
}

class _$PosWorkspaceLineModifiersRequestSerializer
    implements PrimitiveSerializer<PosWorkspaceLineModifiersRequest> {
  @override
  final Iterable<Type> types = const [
    PosWorkspaceLineModifiersRequest,
    _$PosWorkspaceLineModifiersRequest
  ];

  @override
  final String wireName = r'PosWorkspaceLineModifiersRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosWorkspaceLineModifiersRequest object, {
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
    yield r'modifiers';
    yield serializers.serialize(
      object.modifiers,
      specifiedType: const FullType(BuiltList, [FullType(ModifierSelection)]),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosWorkspaceLineModifiersRequest object, {
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
    required PosWorkspaceLineModifiersRequestBuilder result,
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
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ModifierSelection)]),
          ) as BuiltList<ModifierSelection>;
          result.modifiers.replace(valueDes);
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosWorkspaceLineModifiersRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosWorkspaceLineModifiersRequestBuilder();
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
