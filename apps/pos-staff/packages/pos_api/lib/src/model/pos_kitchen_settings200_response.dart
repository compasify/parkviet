//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kitchen_settings200_response.g.dart';

/// PosKitchenSettings200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosKitchenSettings200Response
    implements
        Built<PosKitchenSettings200Response,
            PosKitchenSettings200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  KitchenSettings get data;

  PosKitchenSettings200Response._();

  factory PosKitchenSettings200Response(
          [void updates(PosKitchenSettings200ResponseBuilder b)]) =
      _$PosKitchenSettings200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKitchenSettings200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKitchenSettings200Response> get serializer =>
      _$PosKitchenSettings200ResponseSerializer();
}

class _$PosKitchenSettings200ResponseSerializer
    implements PrimitiveSerializer<PosKitchenSettings200Response> {
  @override
  final Iterable<Type> types = const [
    PosKitchenSettings200Response,
    _$PosKitchenSettings200Response
  ];

  @override
  final String wireName = r'PosKitchenSettings200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKitchenSettings200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KitchenSettings),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKitchenSettings200Response object, {
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
    required PosKitchenSettings200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenSettings),
          ) as KitchenSettings;
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
  PosKitchenSettings200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKitchenSettings200ResponseBuilder();
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
