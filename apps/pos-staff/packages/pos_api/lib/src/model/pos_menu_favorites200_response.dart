//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/pos_menu_favorites200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_menu_favorites200_response.g.dart';

/// PosMenuFavorites200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosMenuFavorites200Response
    implements
        Built<PosMenuFavorites200Response, PosMenuFavorites200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PosMenuFavorites200ResponseData get data;

  PosMenuFavorites200Response._();

  factory PosMenuFavorites200Response(
          [void updates(PosMenuFavorites200ResponseBuilder b)]) =
      _$PosMenuFavorites200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosMenuFavorites200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosMenuFavorites200Response> get serializer =>
      _$PosMenuFavorites200ResponseSerializer();
}

class _$PosMenuFavorites200ResponseSerializer
    implements PrimitiveSerializer<PosMenuFavorites200Response> {
  @override
  final Iterable<Type> types = const [
    PosMenuFavorites200Response,
    _$PosMenuFavorites200Response
  ];

  @override
  final String wireName = r'PosMenuFavorites200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosMenuFavorites200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PosMenuFavorites200ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosMenuFavorites200Response object, {
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
    required PosMenuFavorites200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PosMenuFavorites200ResponseData),
          ) as PosMenuFavorites200ResponseData;
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
  PosMenuFavorites200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosMenuFavorites200ResponseBuilder();
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
