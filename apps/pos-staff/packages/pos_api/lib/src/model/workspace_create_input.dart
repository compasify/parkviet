//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_create_input.g.dart';

/// WorkspaceCreateInput
///
/// Properties:
/// * [registerId]
/// * [branchId] - The branch of a tab opened without a register.
/// * [editorId]
/// * [serviceMode]
/// * [tabName]
@BuiltValue()
abstract class WorkspaceCreateInput
    implements Built<WorkspaceCreateInput, WorkspaceCreateInputBuilder> {
  @BuiltValueField(wireName: r'register_id')
  String? get registerId;

  /// The branch of a tab opened without a register.
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'editor_id')
  String? get editorId;

  @BuiltValueField(wireName: r'service_mode')
  WorkspaceCreateInputServiceModeEnum? get serviceMode;
  // enum serviceModeEnum {  counter,  tab,  };

  @BuiltValueField(wireName: r'tab_name')
  String? get tabName;

  WorkspaceCreateInput._();

  factory WorkspaceCreateInput([void updates(WorkspaceCreateInputBuilder b)]) =
      _$WorkspaceCreateInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceCreateInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceCreateInput> get serializer =>
      _$WorkspaceCreateInputSerializer();
}

class _$WorkspaceCreateInputSerializer
    implements PrimitiveSerializer<WorkspaceCreateInput> {
  @override
  final Iterable<Type> types = const [
    WorkspaceCreateInput,
    _$WorkspaceCreateInput
  ];

  @override
  final String wireName = r'WorkspaceCreateInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceCreateInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.registerId != null) {
      yield r'register_id';
      yield serializers.serialize(
        object.registerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.editorId != null) {
      yield r'editor_id';
      yield serializers.serialize(
        object.editorId,
        specifiedType: const FullType(String),
      );
    }
    if (object.serviceMode != null) {
      yield r'service_mode';
      yield serializers.serialize(
        object.serviceMode,
        specifiedType: const FullType(WorkspaceCreateInputServiceModeEnum),
      );
    }
    if (object.tabName != null) {
      yield r'tab_name';
      yield serializers.serialize(
        object.tabName,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceCreateInput object, {
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
    required WorkspaceCreateInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'register_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.registerId = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.editorId = valueDes;
          break;
        case r'service_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(WorkspaceCreateInputServiceModeEnum),
          ) as WorkspaceCreateInputServiceModeEnum?;
          if (valueDes == null) continue;
          result.serviceMode = valueDes;
          break;
        case r'tab_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tabName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceCreateInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceCreateInputBuilder();
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

class WorkspaceCreateInputServiceModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'counter')
  static const WorkspaceCreateInputServiceModeEnum counter =
      _$workspaceCreateInputServiceModeEnum_counter;
  @BuiltValueEnumConst(wireName: r'tab')
  static const WorkspaceCreateInputServiceModeEnum tab =
      _$workspaceCreateInputServiceModeEnum_tab;

  static Serializer<WorkspaceCreateInputServiceModeEnum> get serializer =>
      _$workspaceCreateInputServiceModeEnumSerializer;

  const WorkspaceCreateInputServiceModeEnum._(String name) : super(name);

  static BuiltSet<WorkspaceCreateInputServiceModeEnum> get values =>
      _$workspaceCreateInputServiceModeEnumValues;
  static WorkspaceCreateInputServiceModeEnum valueOf(String name) =>
      _$workspaceCreateInputServiceModeEnumValueOf(name);
}
