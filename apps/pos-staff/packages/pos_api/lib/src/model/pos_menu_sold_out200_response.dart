//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/menu_availability.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_menu_sold_out200_response.g.dart';

/// PosMenuSoldOut200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosMenuSoldOut200Response
    implements
        Built<PosMenuSoldOut200Response, PosMenuSoldOut200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MenuAvailability get data;

  PosMenuSoldOut200Response._();

  factory PosMenuSoldOut200Response(
          [void updates(PosMenuSoldOut200ResponseBuilder b)]) =
      _$PosMenuSoldOut200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosMenuSoldOut200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosMenuSoldOut200Response> get serializer =>
      _$PosMenuSoldOut200ResponseSerializer();
}

class _$PosMenuSoldOut200ResponseSerializer
    implements PrimitiveSerializer<PosMenuSoldOut200Response> {
  @override
  final Iterable<Type> types = const [
    PosMenuSoldOut200Response,
    _$PosMenuSoldOut200Response
  ];

  @override
  final String wireName = r'PosMenuSoldOut200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosMenuSoldOut200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MenuAvailability),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosMenuSoldOut200Response object, {
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
    required PosMenuSoldOut200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MenuAvailability),
          ) as MenuAvailability;
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
  PosMenuSoldOut200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosMenuSoldOut200ResponseBuilder();
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
