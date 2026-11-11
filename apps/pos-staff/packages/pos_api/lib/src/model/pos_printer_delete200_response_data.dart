//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printer_delete200_response_data.g.dart';

/// PosPrinterDelete200ResponseData
///
/// Properties:
/// * [id]
@BuiltValue()
abstract class PosPrinterDelete200ResponseData
    implements
        Built<PosPrinterDelete200ResponseData,
            PosPrinterDelete200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  PosPrinterDelete200ResponseData._();

  factory PosPrinterDelete200ResponseData(
          [void updates(PosPrinterDelete200ResponseDataBuilder b)]) =
      _$PosPrinterDelete200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinterDelete200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinterDelete200ResponseData> get serializer =>
      _$PosPrinterDelete200ResponseDataSerializer();
}

class _$PosPrinterDelete200ResponseDataSerializer
    implements PrimitiveSerializer<PosPrinterDelete200ResponseData> {
  @override
  final Iterable<Type> types = const [
    PosPrinterDelete200ResponseData,
    _$PosPrinterDelete200ResponseData
  ];

  @override
  final String wireName = r'PosPrinterDelete200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinterDelete200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrinterDelete200ResponseData object, {
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
    required PosPrinterDelete200ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosPrinterDelete200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinterDelete200ResponseDataBuilder();
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
