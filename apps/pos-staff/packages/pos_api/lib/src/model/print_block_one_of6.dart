//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_block_one_of6.g.dart';

/// PrintBlockOneOf6
///
/// Properties:
/// * [kind]
/// * [style]
@BuiltValue()
abstract class PrintBlockOneOf6
    implements Built<PrintBlockOneOf6, PrintBlockOneOf6Builder> {
  @BuiltValueField(wireName: r'kind')
  JsonObject? get kind;

  @BuiltValueField(wireName: r'style')
  PrintBlockOneOf6StyleEnum get style;
  // enum styleEnum {  solid,  dashed,  };

  PrintBlockOneOf6._();

  factory PrintBlockOneOf6([void updates(PrintBlockOneOf6Builder b)]) =
      _$PrintBlockOneOf6;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockOneOf6Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlockOneOf6> get serializer =>
      _$PrintBlockOneOf6Serializer();
}

class _$PrintBlockOneOf6Serializer
    implements PrimitiveSerializer<PrintBlockOneOf6> {
  @override
  final Iterable<Type> types = const [PrintBlockOneOf6, _$PrintBlockOneOf6];

  @override
  final String wireName = r'PrintBlockOneOf6';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlockOneOf6 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield object.kind == null
        ? null
        : serializers.serialize(
            object.kind,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'style';
    yield serializers.serialize(
      object.style,
      specifiedType: const FullType(PrintBlockOneOf6StyleEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintBlockOneOf6 object, {
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
    required PrintBlockOneOf6Builder result,
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
        case r'style':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintBlockOneOf6StyleEnum),
          ) as PrintBlockOneOf6StyleEnum;
          result.style = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintBlockOneOf6 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockOneOf6Builder();
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

class PrintBlockOneOf6StyleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'solid')
  static const PrintBlockOneOf6StyleEnum solid =
      _$printBlockOneOf6StyleEnum_solid;
  @BuiltValueEnumConst(wireName: r'dashed')
  static const PrintBlockOneOf6StyleEnum dashed =
      _$printBlockOneOf6StyleEnum_dashed;

  static Serializer<PrintBlockOneOf6StyleEnum> get serializer =>
      _$printBlockOneOf6StyleEnumSerializer;

  const PrintBlockOneOf6StyleEnum._(String name) : super(name);

  static BuiltSet<PrintBlockOneOf6StyleEnum> get values =>
      _$printBlockOneOf6StyleEnumValues;
  static PrintBlockOneOf6StyleEnum valueOf(String name) =>
      _$printBlockOneOf6StyleEnumValueOf(name);
}
