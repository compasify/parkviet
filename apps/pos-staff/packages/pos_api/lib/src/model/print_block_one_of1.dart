//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_block_one_of1.g.dart';

/// PrintBlockOneOf1
///
/// Properties:
/// * [kind]
/// * [src]
/// * [alt]
/// * [widthPct]
/// * [align]
/// * [monochrome]
@BuiltValue()
abstract class PrintBlockOneOf1
    implements Built<PrintBlockOneOf1, PrintBlockOneOf1Builder> {
  @BuiltValueField(wireName: r'kind')
  JsonObject? get kind;

  @BuiltValueField(wireName: r'src')
  String get src;

  @BuiltValueField(wireName: r'alt')
  String get alt;

  @BuiltValueField(wireName: r'widthPct')
  num get widthPct;

  @BuiltValueField(wireName: r'align')
  PrintBlockOneOf1AlignEnum get align;
  // enum alignEnum {  left,  center,  right,  };

  @BuiltValueField(wireName: r'monochrome')
  bool get monochrome;

  PrintBlockOneOf1._();

  factory PrintBlockOneOf1([void updates(PrintBlockOneOf1Builder b)]) =
      _$PrintBlockOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockOneOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlockOneOf1> get serializer =>
      _$PrintBlockOneOf1Serializer();
}

class _$PrintBlockOneOf1Serializer
    implements PrimitiveSerializer<PrintBlockOneOf1> {
  @override
  final Iterable<Type> types = const [PrintBlockOneOf1, _$PrintBlockOneOf1];

  @override
  final String wireName = r'PrintBlockOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlockOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield object.kind == null
        ? null
        : serializers.serialize(
            object.kind,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'src';
    yield serializers.serialize(
      object.src,
      specifiedType: const FullType(String),
    );
    yield r'alt';
    yield serializers.serialize(
      object.alt,
      specifiedType: const FullType(String),
    );
    yield r'widthPct';
    yield serializers.serialize(
      object.widthPct,
      specifiedType: const FullType(num),
    );
    yield r'align';
    yield serializers.serialize(
      object.align,
      specifiedType: const FullType(PrintBlockOneOf1AlignEnum),
    );
    yield r'monochrome';
    yield serializers.serialize(
      object.monochrome,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintBlockOneOf1 object, {
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
    required PrintBlockOneOf1Builder result,
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
        case r'src':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.src = valueDes;
          break;
        case r'alt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.alt = valueDes;
          break;
        case r'widthPct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.widthPct = valueDes;
          break;
        case r'align':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintBlockOneOf1AlignEnum),
          ) as PrintBlockOneOf1AlignEnum;
          result.align = valueDes;
          break;
        case r'monochrome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.monochrome = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintBlockOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockOneOf1Builder();
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

class PrintBlockOneOf1AlignEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'left')
  static const PrintBlockOneOf1AlignEnum left =
      _$printBlockOneOf1AlignEnum_left;
  @BuiltValueEnumConst(wireName: r'center')
  static const PrintBlockOneOf1AlignEnum center =
      _$printBlockOneOf1AlignEnum_center;
  @BuiltValueEnumConst(wireName: r'right')
  static const PrintBlockOneOf1AlignEnum right =
      _$printBlockOneOf1AlignEnum_right;

  static Serializer<PrintBlockOneOf1AlignEnum> get serializer =>
      _$printBlockOneOf1AlignEnumSerializer;

  const PrintBlockOneOf1AlignEnum._(String name) : super(name);

  static BuiltSet<PrintBlockOneOf1AlignEnum> get values =>
      _$printBlockOneOf1AlignEnumValues;
  static PrintBlockOneOf1AlignEnum valueOf(String name) =>
      _$printBlockOneOf1AlignEnumValueOf(name);
}
