//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/cup_label_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_cup_label_settings200_response.g.dart';

/// PosCupLabelSettings200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosCupLabelSettings200Response
    implements
        Built<PosCupLabelSettings200Response,
            PosCupLabelSettings200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  CupLabelSettings get data;

  PosCupLabelSettings200Response._();

  factory PosCupLabelSettings200Response(
          [void updates(PosCupLabelSettings200ResponseBuilder b)]) =
      _$PosCupLabelSettings200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosCupLabelSettings200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosCupLabelSettings200Response> get serializer =>
      _$PosCupLabelSettings200ResponseSerializer();
}

class _$PosCupLabelSettings200ResponseSerializer
    implements PrimitiveSerializer<PosCupLabelSettings200Response> {
  @override
  final Iterable<Type> types = const [
    PosCupLabelSettings200Response,
    _$PosCupLabelSettings200Response
  ];

  @override
  final String wireName = r'PosCupLabelSettings200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosCupLabelSettings200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(CupLabelSettings),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosCupLabelSettings200Response object, {
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
    required PosCupLabelSettings200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CupLabelSettings),
          ) as CupLabelSettings;
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
  PosCupLabelSettings200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosCupLabelSettings200ResponseBuilder();
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
