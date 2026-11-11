//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_block_one_of3.g.dart';

/// PrintBlockOneOf3
///
/// Properties:
/// * [kind]
/// * [value]
/// * [align]
@BuiltValue()
abstract class PrintBlockOneOf3
    implements Built<PrintBlockOneOf3, PrintBlockOneOf3Builder> {
  @BuiltValueField(wireName: r'kind')
  JsonObject? get kind;

  @BuiltValueField(wireName: r'value')
  String get value;

  @BuiltValueField(wireName: r'align')
  PrintBlockOneOf3AlignEnum get align;
  // enum alignEnum {  left,  center,  right,  };

  PrintBlockOneOf3._();

  factory PrintBlockOneOf3([void updates(PrintBlockOneOf3Builder b)]) =
      _$PrintBlockOneOf3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockOneOf3Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlockOneOf3> get serializer =>
      _$PrintBlockOneOf3Serializer();
}

class _$PrintBlockOneOf3Serializer
    implements PrimitiveSerializer<PrintBlockOneOf3> {
  @override
  final Iterable<Type> types = const [PrintBlockOneOf3, _$PrintBlockOneOf3];

  @override
  final String wireName = r'PrintBlockOneOf3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlockOneOf3 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield object.kind == null
        ? null
        : serializers.serialize(
            object.kind,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'value';
    yield serializers.serialize(
      object.value,
      specifiedType: const FullType(String),
    );
    yield r'align';
    yield serializers.serialize(
      object.align,
      specifiedType: const FullType(PrintBlockOneOf3AlignEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintBlockOneOf3 object, {
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
    required PrintBlockOneOf3Builder result,
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
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.value = valueDes;
          break;
        case r'align':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintBlockOneOf3AlignEnum),
          ) as PrintBlockOneOf3AlignEnum;
          result.align = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintBlockOneOf3 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockOneOf3Builder();
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

class PrintBlockOneOf3AlignEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'left')
  static const PrintBlockOneOf3AlignEnum left =
      _$printBlockOneOf3AlignEnum_left;
  @BuiltValueEnumConst(wireName: r'center')
  static const PrintBlockOneOf3AlignEnum center =
      _$printBlockOneOf3AlignEnum_center;
  @BuiltValueEnumConst(wireName: r'right')
  static const PrintBlockOneOf3AlignEnum right =
      _$printBlockOneOf3AlignEnum_right;

  static Serializer<PrintBlockOneOf3AlignEnum> get serializer =>
      _$printBlockOneOf3AlignEnumSerializer;

  const PrintBlockOneOf3AlignEnum._(String name) : super(name);

  static BuiltSet<PrintBlockOneOf3AlignEnum> get values =>
      _$printBlockOneOf3AlignEnumValues;
  static PrintBlockOneOf3AlignEnum valueOf(String name) =>
      _$printBlockOneOf3AlignEnumValueOf(name);
}
