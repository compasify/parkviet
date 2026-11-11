//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_result.g.dart';

/// WorkspaceResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class WorkspaceResult
    implements Built<WorkspaceResult, WorkspaceResultBuilder> {
  @BuiltValueField(wireName: r'data')
  Workspace get data;

  WorkspaceResult._();

  factory WorkspaceResult([void updates(WorkspaceResultBuilder b)]) =
      _$WorkspaceResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceResult> get serializer =>
      _$WorkspaceResultSerializer();
}

class _$WorkspaceResultSerializer
    implements PrimitiveSerializer<WorkspaceResult> {
  @override
  final Iterable<Type> types = const [WorkspaceResult, _$WorkspaceResult];

  @override
  final String wireName = r'WorkspaceResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Workspace),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceResult object, {
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
    required WorkspaceResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Workspace),
          ) as Workspace;
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
  WorkspaceResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceResultBuilder();
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
