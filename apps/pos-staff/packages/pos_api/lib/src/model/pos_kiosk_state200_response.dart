//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_state.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kiosk_state200_response.g.dart';

/// PosKioskState200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosKioskState200Response
    implements
        Built<PosKioskState200Response, PosKioskState200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  KioskState get data;

  PosKioskState200Response._();

  factory PosKioskState200Response(
          [void updates(PosKioskState200ResponseBuilder b)]) =
      _$PosKioskState200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKioskState200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKioskState200Response> get serializer =>
      _$PosKioskState200ResponseSerializer();
}

class _$PosKioskState200ResponseSerializer
    implements PrimitiveSerializer<PosKioskState200Response> {
  @override
  final Iterable<Type> types = const [
    PosKioskState200Response,
    _$PosKioskState200Response
  ];

  @override
  final String wireName = r'PosKioskState200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKioskState200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KioskState),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKioskState200Response object, {
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
    required PosKioskState200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskState),
          ) as KioskState;
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
  PosKioskState200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKioskState200ResponseBuilder();
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
