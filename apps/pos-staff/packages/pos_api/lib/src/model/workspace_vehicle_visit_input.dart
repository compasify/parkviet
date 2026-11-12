//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_vehicle_visit_input.g.dart';

/// WorkspaceVehicleVisitInput
///
/// Properties:
/// * [expectedRevision]
/// * [leaseGeneration]
/// * [editorId]
/// * [visitId] - An open visit of the order's branch; empty takes the order off.
@BuiltValue()
abstract class WorkspaceVehicleVisitInput
    implements
        Built<WorkspaceVehicleVisitInput, WorkspaceVehicleVisitInputBuilder> {
  @BuiltValueField(wireName: r'expected_revision')
  int get expectedRevision;

  @BuiltValueField(wireName: r'lease_generation')
  int get leaseGeneration;

  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  /// An open visit of the order's branch; empty takes the order off.
  @BuiltValueField(wireName: r'visit_id')
  String? get visitId;

  WorkspaceVehicleVisitInput._();

  factory WorkspaceVehicleVisitInput(
          [void updates(WorkspaceVehicleVisitInputBuilder b)]) =
      _$WorkspaceVehicleVisitInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceVehicleVisitInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceVehicleVisitInput> get serializer =>
      _$WorkspaceVehicleVisitInputSerializer();
}

class _$WorkspaceVehicleVisitInputSerializer
    implements PrimitiveSerializer<WorkspaceVehicleVisitInput> {
  @override
  final Iterable<Type> types = const [
    WorkspaceVehicleVisitInput,
    _$WorkspaceVehicleVisitInput
  ];

  @override
  final String wireName = r'WorkspaceVehicleVisitInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceVehicleVisitInput object, {
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
    if (object.visitId != null) {
      yield r'visit_id';
      yield serializers.serialize(
        object.visitId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceVehicleVisitInput object, {
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
    required WorkspaceVehicleVisitInputBuilder result,
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
        case r'visit_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.visitId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceVehicleVisitInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceVehicleVisitInputBuilder();
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
