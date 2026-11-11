//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_workspace_create201_response.g.dart';

/// PosWorkspaceCreate201Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosWorkspaceCreate201Response
    implements
        Built<PosWorkspaceCreate201Response,
            PosWorkspaceCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Workspace get data;

  PosWorkspaceCreate201Response._();

  factory PosWorkspaceCreate201Response(
          [void updates(PosWorkspaceCreate201ResponseBuilder b)]) =
      _$PosWorkspaceCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosWorkspaceCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosWorkspaceCreate201Response> get serializer =>
      _$PosWorkspaceCreate201ResponseSerializer();
}

class _$PosWorkspaceCreate201ResponseSerializer
    implements PrimitiveSerializer<PosWorkspaceCreate201Response> {
  @override
  final Iterable<Type> types = const [
    PosWorkspaceCreate201Response,
    _$PosWorkspaceCreate201Response
  ];

  @override
  final String wireName = r'PosWorkspaceCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosWorkspaceCreate201Response object, {
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
    PosWorkspaceCreate201Response object, {
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
    required PosWorkspaceCreate201ResponseBuilder result,
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
  PosWorkspaceCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosWorkspaceCreate201ResponseBuilder();
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
