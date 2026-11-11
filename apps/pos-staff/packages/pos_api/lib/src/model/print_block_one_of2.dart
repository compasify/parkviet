//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_block_one_of2.g.dart';

/// PrintBlockOneOf2
///
/// Properties:
/// * [kind]
/// * [value]
/// * [caption]
/// * [align]
@BuiltValue()
abstract class PrintBlockOneOf2
    implements Built<PrintBlockOneOf2, PrintBlockOneOf2Builder> {
  @BuiltValueField(wireName: r'kind')
  JsonObject? get kind;

  @BuiltValueField(wireName: r'value')
  String get value;

  @BuiltValueField(wireName: r'caption')
  String? get caption;

  @BuiltValueField(wireName: r'align')
  PrintBlockOneOf2AlignEnum get align;
  // enum alignEnum {  left,  center,  right,  };

  PrintBlockOneOf2._();

  factory PrintBlockOneOf2([void updates(PrintBlockOneOf2Builder b)]) =
      _$PrintBlockOneOf2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockOneOf2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlockOneOf2> get serializer =>
      _$PrintBlockOneOf2Serializer();
}

class _$PrintBlockOneOf2Serializer
    implements PrimitiveSerializer<PrintBlockOneOf2> {
  @override
  final Iterable<Type> types = const [PrintBlockOneOf2, _$PrintBlockOneOf2];

  @override
  final String wireName = r'PrintBlockOneOf2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlockOneOf2 object, {
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
    yield r'caption';
    yield object.caption == null
        ? null
        : serializers.serialize(
            object.caption,
            specifiedType: const FullType.nullable(String),
          );
    yield r'align';
    yield serializers.serialize(
      object.align,
      specifiedType: const FullType(PrintBlockOneOf2AlignEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintBlockOneOf2 object, {
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
    required PrintBlockOneOf2Builder result,
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
        case r'caption':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.caption = valueDes;
          break;
        case r'align':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintBlockOneOf2AlignEnum),
          ) as PrintBlockOneOf2AlignEnum;
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
  PrintBlockOneOf2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockOneOf2Builder();
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

class PrintBlockOneOf2AlignEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'left')
  static const PrintBlockOneOf2AlignEnum left =
      _$printBlockOneOf2AlignEnum_left;
  @BuiltValueEnumConst(wireName: r'center')
  static const PrintBlockOneOf2AlignEnum center =
      _$printBlockOneOf2AlignEnum_center;
  @BuiltValueEnumConst(wireName: r'right')
  static const PrintBlockOneOf2AlignEnum right =
      _$printBlockOneOf2AlignEnum_right;

  static Serializer<PrintBlockOneOf2AlignEnum> get serializer =>
      _$printBlockOneOf2AlignEnumSerializer;

  const PrintBlockOneOf2AlignEnum._(String name) : super(name);

  static BuiltSet<PrintBlockOneOf2AlignEnum> get values =>
      _$printBlockOneOf2AlignEnumValues;
  static PrintBlockOneOf2AlignEnum valueOf(String name) =>
      _$printBlockOneOf2AlignEnumValueOf(name);
}
