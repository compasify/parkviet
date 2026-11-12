//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kiosk_settings200_response.g.dart';

/// PosKioskSettings200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosKioskSettings200Response
    implements
        Built<PosKioskSettings200Response, PosKioskSettings200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  KioskSettings get data;

  PosKioskSettings200Response._();

  factory PosKioskSettings200Response(
          [void updates(PosKioskSettings200ResponseBuilder b)]) =
      _$PosKioskSettings200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKioskSettings200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKioskSettings200Response> get serializer =>
      _$PosKioskSettings200ResponseSerializer();
}

class _$PosKioskSettings200ResponseSerializer
    implements PrimitiveSerializer<PosKioskSettings200Response> {
  @override
  final Iterable<Type> types = const [
    PosKioskSettings200Response,
    _$PosKioskSettings200Response
  ];

  @override
  final String wireName = r'PosKioskSettings200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKioskSettings200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KioskSettings),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKioskSettings200Response object, {
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
    required PosKioskSettings200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskSettings),
          ) as KioskSettings;
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
  PosKioskSettings200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKioskSettings200ResponseBuilder();
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
