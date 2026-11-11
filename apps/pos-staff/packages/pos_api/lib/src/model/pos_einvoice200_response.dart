//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/einvoice.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice200_response.g.dart';

/// PosEinvoice200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosEinvoice200Response
    implements Built<PosEinvoice200Response, PosEinvoice200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Einvoice get data;

  PosEinvoice200Response._();

  factory PosEinvoice200Response(
          [void updates(PosEinvoice200ResponseBuilder b)]) =
      _$PosEinvoice200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoice200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoice200Response> get serializer =>
      _$PosEinvoice200ResponseSerializer();
}

class _$PosEinvoice200ResponseSerializer
    implements PrimitiveSerializer<PosEinvoice200Response> {
  @override
  final Iterable<Type> types = const [
    PosEinvoice200Response,
    _$PosEinvoice200Response
  ];

  @override
  final String wireName = r'PosEinvoice200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoice200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Einvoice),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoice200Response object, {
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
    required PosEinvoice200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Einvoice),
          ) as Einvoice;
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
  PosEinvoice200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoice200ResponseBuilder();
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
