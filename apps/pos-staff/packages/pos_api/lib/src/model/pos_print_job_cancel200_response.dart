//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_job.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_print_job_cancel200_response.g.dart';

/// PosPrintJobCancel200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosPrintJobCancel200Response
    implements
        Built<PosPrintJobCancel200Response,
            PosPrintJobCancel200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PrintJob get data;

  PosPrintJobCancel200Response._();

  factory PosPrintJobCancel200Response(
          [void updates(PosPrintJobCancel200ResponseBuilder b)]) =
      _$PosPrintJobCancel200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrintJobCancel200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrintJobCancel200Response> get serializer =>
      _$PosPrintJobCancel200ResponseSerializer();
}

class _$PosPrintJobCancel200ResponseSerializer
    implements PrimitiveSerializer<PosPrintJobCancel200Response> {
  @override
  final Iterable<Type> types = const [
    PosPrintJobCancel200Response,
    _$PosPrintJobCancel200Response
  ];

  @override
  final String wireName = r'PosPrintJobCancel200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrintJobCancel200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PrintJob),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrintJobCancel200Response object, {
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
    required PosPrintJobCancel200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintJob),
          ) as PrintJob;
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
  PosPrintJobCancel200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrintJobCancel200ResponseBuilder();
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
