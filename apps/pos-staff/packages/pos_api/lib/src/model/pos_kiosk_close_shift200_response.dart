//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_shift_closure.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kiosk_close_shift200_response.g.dart';

/// PosKioskCloseShift200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosKioskCloseShift200Response
    implements
        Built<PosKioskCloseShift200Response,
            PosKioskCloseShift200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  KioskShiftClosure get data;

  PosKioskCloseShift200Response._();

  factory PosKioskCloseShift200Response(
          [void updates(PosKioskCloseShift200ResponseBuilder b)]) =
      _$PosKioskCloseShift200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKioskCloseShift200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKioskCloseShift200Response> get serializer =>
      _$PosKioskCloseShift200ResponseSerializer();
}

class _$PosKioskCloseShift200ResponseSerializer
    implements PrimitiveSerializer<PosKioskCloseShift200Response> {
  @override
  final Iterable<Type> types = const [
    PosKioskCloseShift200Response,
    _$PosKioskCloseShift200Response
  ];

  @override
  final String wireName = r'PosKioskCloseShift200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKioskCloseShift200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KioskShiftClosure),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKioskCloseShift200Response object, {
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
    required PosKioskCloseShift200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskShiftClosure),
          ) as KioskShiftClosure;
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
  PosKioskCloseShift200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKioskCloseShift200ResponseBuilder();
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
