//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_pay_qr.g.dart';

/// PrintPayQr
///
/// Properties:
/// * [value]
/// * [caption]
/// * [lines]
@BuiltValue()
abstract class PrintPayQr implements Built<PrintPayQr, PrintPayQrBuilder> {
  @BuiltValueField(wireName: r'value')
  String get value;

  @BuiltValueField(wireName: r'caption')
  String get caption;

  @BuiltValueField(wireName: r'lines')
  BuiltList<String> get lines;

  PrintPayQr._();

  factory PrintPayQr([void updates(PrintPayQrBuilder b)]) = _$PrintPayQr;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintPayQrBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintPayQr> get serializer => _$PrintPayQrSerializer();
}

class _$PrintPayQrSerializer implements PrimitiveSerializer<PrintPayQr> {
  @override
  final Iterable<Type> types = const [PrintPayQr, _$PrintPayQr];

  @override
  final String wireName = r'PrintPayQr';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintPayQr object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'value';
    yield serializers.serialize(
      object.value,
      specifiedType: const FullType(String),
    );
    yield r'caption';
    yield serializers.serialize(
      object.caption,
      specifiedType: const FullType(String),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintPayQr object, {
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
    required PrintPayQrBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.value = valueDes;
          break;
        case r'caption':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.caption = valueDes;
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintPayQr deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintPayQrBuilder();
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
