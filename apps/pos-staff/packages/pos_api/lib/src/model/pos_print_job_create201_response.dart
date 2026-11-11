//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_job_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_print_job_create201_response.g.dart';

/// PosPrintJobCreate201Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosPrintJobCreate201Response
    implements
        Built<PosPrintJobCreate201Response,
            PosPrintJobCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PrintJobResult get data;

  PosPrintJobCreate201Response._();

  factory PosPrintJobCreate201Response(
          [void updates(PosPrintJobCreate201ResponseBuilder b)]) =
      _$PosPrintJobCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrintJobCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrintJobCreate201Response> get serializer =>
      _$PosPrintJobCreate201ResponseSerializer();
}

class _$PosPrintJobCreate201ResponseSerializer
    implements PrimitiveSerializer<PosPrintJobCreate201Response> {
  @override
  final Iterable<Type> types = const [
    PosPrintJobCreate201Response,
    _$PosPrintJobCreate201Response
  ];

  @override
  final String wireName = r'PosPrintJobCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrintJobCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PrintJobResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrintJobCreate201Response object, {
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
    required PosPrintJobCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintJobResult),
          ) as PrintJobResult;
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
  PosPrintJobCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrintJobCreate201ResponseBuilder();
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
