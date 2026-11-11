//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/pos_workspace_cup_labels_reprint201_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_workspace_cup_labels_reprint201_response.g.dart';

/// PosWorkspaceCupLabelsReprint201Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosWorkspaceCupLabelsReprint201Response
    implements
        Built<PosWorkspaceCupLabelsReprint201Response,
            PosWorkspaceCupLabelsReprint201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PosWorkspaceCupLabelsReprint201ResponseData get data;

  PosWorkspaceCupLabelsReprint201Response._();

  factory PosWorkspaceCupLabelsReprint201Response(
          [void updates(PosWorkspaceCupLabelsReprint201ResponseBuilder b)]) =
      _$PosWorkspaceCupLabelsReprint201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosWorkspaceCupLabelsReprint201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosWorkspaceCupLabelsReprint201Response> get serializer =>
      _$PosWorkspaceCupLabelsReprint201ResponseSerializer();
}

class _$PosWorkspaceCupLabelsReprint201ResponseSerializer
    implements PrimitiveSerializer<PosWorkspaceCupLabelsReprint201Response> {
  @override
  final Iterable<Type> types = const [
    PosWorkspaceCupLabelsReprint201Response,
    _$PosWorkspaceCupLabelsReprint201Response
  ];

  @override
  final String wireName = r'PosWorkspaceCupLabelsReprint201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosWorkspaceCupLabelsReprint201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType:
          const FullType(PosWorkspaceCupLabelsReprint201ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosWorkspaceCupLabelsReprint201Response object, {
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
    required PosWorkspaceCupLabelsReprint201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PosWorkspaceCupLabelsReprint201ResponseData),
          ) as PosWorkspaceCupLabelsReprint201ResponseData;
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
  PosWorkspaceCupLabelsReprint201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosWorkspaceCupLabelsReprint201ResponseBuilder();
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
