//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_block_one_of5.g.dart';

/// PrintBlockOneOf5
///
/// Properties:
/// * [kind]
/// * [title]
/// * [number]
@BuiltValue()
abstract class PrintBlockOneOf5
    implements Built<PrintBlockOneOf5, PrintBlockOneOf5Builder> {
  @BuiltValueField(wireName: r'kind')
  JsonObject? get kind;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'number')
  String? get number;

  PrintBlockOneOf5._();

  factory PrintBlockOneOf5([void updates(PrintBlockOneOf5Builder b)]) =
      _$PrintBlockOneOf5;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockOneOf5Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlockOneOf5> get serializer =>
      _$PrintBlockOneOf5Serializer();
}

class _$PrintBlockOneOf5Serializer
    implements PrimitiveSerializer<PrintBlockOneOf5> {
  @override
  final Iterable<Type> types = const [PrintBlockOneOf5, _$PrintBlockOneOf5];

  @override
  final String wireName = r'PrintBlockOneOf5';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlockOneOf5 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield object.kind == null
        ? null
        : serializers.serialize(
            object.kind,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'number';
    yield object.number == null
        ? null
        : serializers.serialize(
            object.number,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintBlockOneOf5 object, {
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
    required PrintBlockOneOf5Builder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.number = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintBlockOneOf5 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockOneOf5Builder();
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
