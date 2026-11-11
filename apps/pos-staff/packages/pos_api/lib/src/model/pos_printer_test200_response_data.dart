//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_job.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printer_test200_response_data.g.dart';

/// PosPrinterTest200ResponseData
///
/// Properties:
/// * [printJob]
/// * [document]
@BuiltValue()
abstract class PosPrinterTest200ResponseData
    implements
        Built<PosPrinterTest200ResponseData,
            PosPrinterTest200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'print_job')
  PrintJob? get printJob;

  @BuiltValueField(wireName: r'document')
  JsonObject? get document;

  PosPrinterTest200ResponseData._();

  factory PosPrinterTest200ResponseData(
          [void updates(PosPrinterTest200ResponseDataBuilder b)]) =
      _$PosPrinterTest200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinterTest200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinterTest200ResponseData> get serializer =>
      _$PosPrinterTest200ResponseDataSerializer();
}

class _$PosPrinterTest200ResponseDataSerializer
    implements PrimitiveSerializer<PosPrinterTest200ResponseData> {
  @override
  final Iterable<Type> types = const [
    PosPrinterTest200ResponseData,
    _$PosPrinterTest200ResponseData
  ];

  @override
  final String wireName = r'PosPrinterTest200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinterTest200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'print_job';
    yield object.printJob == null
        ? null
        : serializers.serialize(
            object.printJob,
            specifiedType: const FullType.nullable(PrintJob),
          );
    yield r'document';
    yield object.document == null
        ? null
        : serializers.serialize(
            object.document,
            specifiedType: const FullType.nullable(JsonObject),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrinterTest200ResponseData object, {
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
    required PosPrinterTest200ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'print_job':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PrintJob),
          ) as PrintJob?;
          if (valueDes == null) continue;
          result.printJob.replace(valueDes);
          break;
        case r'document':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.document = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosPrinterTest200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinterTest200ResponseDataBuilder();
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
