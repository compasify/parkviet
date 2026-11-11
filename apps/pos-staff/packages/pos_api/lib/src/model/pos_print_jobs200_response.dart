//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/print_job.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_print_jobs200_response.g.dart';

/// PosPrintJobs200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosPrintJobs200Response
    implements Built<PosPrintJobs200Response, PosPrintJobs200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PrintJob> get data;

  PosPrintJobs200Response._();

  factory PosPrintJobs200Response(
          [void updates(PosPrintJobs200ResponseBuilder b)]) =
      _$PosPrintJobs200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrintJobs200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrintJobs200Response> get serializer =>
      _$PosPrintJobs200ResponseSerializer();
}

class _$PosPrintJobs200ResponseSerializer
    implements PrimitiveSerializer<PosPrintJobs200Response> {
  @override
  final Iterable<Type> types = const [
    PosPrintJobs200Response,
    _$PosPrintJobs200Response
  ];

  @override
  final String wireName = r'PosPrintJobs200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrintJobs200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PrintJob)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrintJobs200Response object, {
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
    required PosPrintJobs200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PrintJob)]),
          ) as BuiltList<PrintJob>;
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
  PosPrintJobs200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrintJobs200ResponseBuilder();
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
