//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/menu.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_menu200_response.g.dart';

/// PosMenu200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosMenu200Response
    implements Built<PosMenu200Response, PosMenu200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Menu get data;

  PosMenu200Response._();

  factory PosMenu200Response([void updates(PosMenu200ResponseBuilder b)]) =
      _$PosMenu200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosMenu200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosMenu200Response> get serializer =>
      _$PosMenu200ResponseSerializer();
}

class _$PosMenu200ResponseSerializer
    implements PrimitiveSerializer<PosMenu200Response> {
  @override
  final Iterable<Type> types = const [PosMenu200Response, _$PosMenu200Response];

  @override
  final String wireName = r'PosMenu200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosMenu200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Menu),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosMenu200Response object, {
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
    required PosMenu200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Menu),
          ) as Menu;
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
  PosMenu200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosMenu200ResponseBuilder();
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
