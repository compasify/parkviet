//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/pos_kitchen_send201_response_meta.dart';
import 'package:pos_api/src/model/workspace.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kitchen_send201_response.g.dart';

/// PosKitchenSend201Response
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class PosKitchenSend201Response
    implements
        Built<PosKitchenSend201Response, PosKitchenSend201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Workspace get data;

  @BuiltValueField(wireName: r'meta')
  PosKitchenSend201ResponseMeta get meta;

  PosKitchenSend201Response._();

  factory PosKitchenSend201Response(
          [void updates(PosKitchenSend201ResponseBuilder b)]) =
      _$PosKitchenSend201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKitchenSend201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKitchenSend201Response> get serializer =>
      _$PosKitchenSend201ResponseSerializer();
}

class _$PosKitchenSend201ResponseSerializer
    implements PrimitiveSerializer<PosKitchenSend201Response> {
  @override
  final Iterable<Type> types = const [
    PosKitchenSend201Response,
    _$PosKitchenSend201Response
  ];

  @override
  final String wireName = r'PosKitchenSend201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKitchenSend201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Workspace),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(PosKitchenSend201ResponseMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKitchenSend201Response object, {
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
    required PosKitchenSend201ResponseBuilder result,
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
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PosKitchenSend201ResponseMeta),
          ) as PosKitchenSend201ResponseMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosKitchenSend201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKitchenSend201ResponseBuilder();
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
