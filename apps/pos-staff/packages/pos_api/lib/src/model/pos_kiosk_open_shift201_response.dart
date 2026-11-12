//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_shift.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kiosk_open_shift201_response.g.dart';

/// PosKioskOpenShift201Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosKioskOpenShift201Response
    implements
        Built<PosKioskOpenShift201Response,
            PosKioskOpenShift201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  KioskShift get data;

  PosKioskOpenShift201Response._();

  factory PosKioskOpenShift201Response(
          [void updates(PosKioskOpenShift201ResponseBuilder b)]) =
      _$PosKioskOpenShift201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKioskOpenShift201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKioskOpenShift201Response> get serializer =>
      _$PosKioskOpenShift201ResponseSerializer();
}

class _$PosKioskOpenShift201ResponseSerializer
    implements PrimitiveSerializer<PosKioskOpenShift201Response> {
  @override
  final Iterable<Type> types = const [
    PosKioskOpenShift201Response,
    _$PosKioskOpenShift201Response
  ];

  @override
  final String wireName = r'PosKioskOpenShift201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKioskOpenShift201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KioskShift),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKioskOpenShift201Response object, {
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
    required PosKioskOpenShift201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskShift),
          ) as KioskShift;
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
  PosKioskOpenShift201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKioskOpenShift201ResponseBuilder();
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
