//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_block_one_of7.g.dart';

/// PrintBlockOneOf7
///
/// Properties:
/// * [kind]
/// * [mm]
@BuiltValue()
abstract class PrintBlockOneOf7
    implements Built<PrintBlockOneOf7, PrintBlockOneOf7Builder> {
  @BuiltValueField(wireName: r'kind')
  JsonObject? get kind;

  @BuiltValueField(wireName: r'mm')
  num get mm;

  PrintBlockOneOf7._();

  factory PrintBlockOneOf7([void updates(PrintBlockOneOf7Builder b)]) =
      _$PrintBlockOneOf7;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockOneOf7Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlockOneOf7> get serializer =>
      _$PrintBlockOneOf7Serializer();
}

class _$PrintBlockOneOf7Serializer
    implements PrimitiveSerializer<PrintBlockOneOf7> {
  @override
  final Iterable<Type> types = const [PrintBlockOneOf7, _$PrintBlockOneOf7];

  @override
  final String wireName = r'PrintBlockOneOf7';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlockOneOf7 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield object.kind == null
        ? null
        : serializers.serialize(
            object.kind,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'mm';
    yield serializers.serialize(
      object.mm,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintBlockOneOf7 object, {
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
    required PrintBlockOneOf7Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'mm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.mm = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintBlockOneOf7 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockOneOf7Builder();
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
