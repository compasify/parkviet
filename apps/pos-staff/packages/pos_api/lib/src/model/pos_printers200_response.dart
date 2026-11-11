//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/printer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printers200_response.g.dart';

/// PosPrinters200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosPrinters200Response
    implements Built<PosPrinters200Response, PosPrinters200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Printer> get data;

  PosPrinters200Response._();

  factory PosPrinters200Response(
          [void updates(PosPrinters200ResponseBuilder b)]) =
      _$PosPrinters200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinters200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinters200Response> get serializer =>
      _$PosPrinters200ResponseSerializer();
}

class _$PosPrinters200ResponseSerializer
    implements PrimitiveSerializer<PosPrinters200Response> {
  @override
  final Iterable<Type> types = const [
    PosPrinters200Response,
    _$PosPrinters200Response
  ];

  @override
  final String wireName = r'PosPrinters200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinters200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Printer)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrinters200Response object, {
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
    required PosPrinters200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Printer)]),
          ) as BuiltList<Printer>;
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
  PosPrinters200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinters200ResponseBuilder();
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
