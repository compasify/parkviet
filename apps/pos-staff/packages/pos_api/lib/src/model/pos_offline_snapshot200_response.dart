//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/offline_snapshot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_offline_snapshot200_response.g.dart';

/// PosOfflineSnapshot200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosOfflineSnapshot200Response
    implements
        Built<PosOfflineSnapshot200Response,
            PosOfflineSnapshot200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OfflineSnapshot get data;

  PosOfflineSnapshot200Response._();

  factory PosOfflineSnapshot200Response(
          [void updates(PosOfflineSnapshot200ResponseBuilder b)]) =
      _$PosOfflineSnapshot200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosOfflineSnapshot200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosOfflineSnapshot200Response> get serializer =>
      _$PosOfflineSnapshot200ResponseSerializer();
}

class _$PosOfflineSnapshot200ResponseSerializer
    implements PrimitiveSerializer<PosOfflineSnapshot200Response> {
  @override
  final Iterable<Type> types = const [
    PosOfflineSnapshot200Response,
    _$PosOfflineSnapshot200Response
  ];

  @override
  final String wireName = r'PosOfflineSnapshot200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosOfflineSnapshot200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OfflineSnapshot),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosOfflineSnapshot200Response object, {
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
    required PosOfflineSnapshot200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSnapshot),
          ) as OfflineSnapshot;
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
  PosOfflineSnapshot200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosOfflineSnapshot200ResponseBuilder();
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
