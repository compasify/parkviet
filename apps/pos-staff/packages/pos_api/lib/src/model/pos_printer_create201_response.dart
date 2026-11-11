//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/printer.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printer_create201_response.g.dart';

/// PosPrinterCreate201Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosPrinterCreate201Response
    implements
        Built<PosPrinterCreate201Response, PosPrinterCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Printer get data;

  PosPrinterCreate201Response._();

  factory PosPrinterCreate201Response(
          [void updates(PosPrinterCreate201ResponseBuilder b)]) =
      _$PosPrinterCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinterCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinterCreate201Response> get serializer =>
      _$PosPrinterCreate201ResponseSerializer();
}

class _$PosPrinterCreate201ResponseSerializer
    implements PrimitiveSerializer<PosPrinterCreate201Response> {
  @override
  final Iterable<Type> types = const [
    PosPrinterCreate201Response,
    _$PosPrinterCreate201Response
  ];

  @override
  final String wireName = r'PosPrinterCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinterCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Printer),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrinterCreate201Response object, {
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
    required PosPrinterCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Printer),
          ) as Printer;
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
  PosPrinterCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinterCreate201ResponseBuilder();
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
