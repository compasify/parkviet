//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_menu.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kiosk_menu200_response.g.dart';

/// PosKioskMenu200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosKioskMenu200Response
    implements Built<PosKioskMenu200Response, PosKioskMenu200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  KioskMenu get data;

  PosKioskMenu200Response._();

  factory PosKioskMenu200Response(
          [void updates(PosKioskMenu200ResponseBuilder b)]) =
      _$PosKioskMenu200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKioskMenu200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKioskMenu200Response> get serializer =>
      _$PosKioskMenu200ResponseSerializer();
}

class _$PosKioskMenu200ResponseSerializer
    implements PrimitiveSerializer<PosKioskMenu200Response> {
  @override
  final Iterable<Type> types = const [
    PosKioskMenu200Response,
    _$PosKioskMenu200Response
  ];

  @override
  final String wireName = r'PosKioskMenu200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKioskMenu200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KioskMenu),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKioskMenu200Response object, {
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
    required PosKioskMenu200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskMenu),
          ) as KioskMenu;
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
  PosKioskMenu200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKioskMenu200ResponseBuilder();
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
