//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_printer_stations200_response_data_inner.g.dart';

/// PosPrinterStations200ResponseDataInner
///
/// Properties:
/// * [id]
/// * [name]
@BuiltValue()
abstract class PosPrinterStations200ResponseDataInner
    implements
        Built<PosPrinterStations200ResponseDataInner,
            PosPrinterStations200ResponseDataInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  PosPrinterStations200ResponseDataInner._();

  factory PosPrinterStations200ResponseDataInner(
          [void updates(PosPrinterStations200ResponseDataInnerBuilder b)]) =
      _$PosPrinterStations200ResponseDataInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrinterStations200ResponseDataInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrinterStations200ResponseDataInner> get serializer =>
      _$PosPrinterStations200ResponseDataInnerSerializer();
}

class _$PosPrinterStations200ResponseDataInnerSerializer
    implements PrimitiveSerializer<PosPrinterStations200ResponseDataInner> {
  @override
  final Iterable<Type> types = const [
    PosPrinterStations200ResponseDataInner,
    _$PosPrinterStations200ResponseDataInner
  ];

  @override
  final String wireName = r'PosPrinterStations200ResponseDataInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrinterStations200ResponseDataInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrinterStations200ResponseDataInner object, {
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
    required PosPrinterStations200ResponseDataInnerBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosPrinterStations200ResponseDataInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrinterStations200ResponseDataInnerBuilder();
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
