//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_block_one_of.g.dart';

/// PrintBlockOneOf
///
/// Properties:
/// * [kind]
/// * [lines]
/// * [align]
/// * [bold]
/// * [size]
/// * [invert] - White on black (a kitchen note). Absent means false.
@BuiltValue()
abstract class PrintBlockOneOf
    implements Built<PrintBlockOneOf, PrintBlockOneOfBuilder> {
  @BuiltValueField(wireName: r'kind')
  JsonObject? get kind;

  @BuiltValueField(wireName: r'lines')
  BuiltList<String> get lines;

  @BuiltValueField(wireName: r'align')
  PrintBlockOneOfAlignEnum get align;
  // enum alignEnum {  left,  center,  right,  };

  @BuiltValueField(wireName: r'bold')
  bool get bold;

  @BuiltValueField(wireName: r'size')
  PrintBlockOneOfSizeEnum get size;
  // enum sizeEnum {  s,  m,  l,  };

  /// White on black (a kitchen note). Absent means false.
  @BuiltValueField(wireName: r'invert')
  bool? get invert;

  PrintBlockOneOf._();

  factory PrintBlockOneOf([void updates(PrintBlockOneOfBuilder b)]) =
      _$PrintBlockOneOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockOneOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlockOneOf> get serializer =>
      _$PrintBlockOneOfSerializer();
}

class _$PrintBlockOneOfSerializer
    implements PrimitiveSerializer<PrintBlockOneOf> {
  @override
  final Iterable<Type> types = const [PrintBlockOneOf, _$PrintBlockOneOf];

  @override
  final String wireName = r'PrintBlockOneOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlockOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield object.kind == null
        ? null
        : serializers.serialize(
            object.kind,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'align';
    yield serializers.serialize(
      object.align,
      specifiedType: const FullType(PrintBlockOneOfAlignEnum),
    );
    yield r'bold';
    yield serializers.serialize(
      object.bold,
      specifiedType: const FullType(bool),
    );
    yield r'size';
    yield serializers.serialize(
      object.size,
      specifiedType: const FullType(PrintBlockOneOfSizeEnum),
    );
    if (object.invert != null) {
      yield r'invert';
      yield serializers.serialize(
        object.invert,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintBlockOneOf object, {
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
    required PrintBlockOneOfBuilder result,
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
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.lines.replace(valueDes);
          break;
        case r'align':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintBlockOneOfAlignEnum),
          ) as PrintBlockOneOfAlignEnum;
          result.align = valueDes;
          break;
        case r'bold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.bold = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintBlockOneOfSizeEnum),
          ) as PrintBlockOneOfSizeEnum;
          result.size = valueDes;
          break;
        case r'invert':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.invert = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintBlockOneOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockOneOfBuilder();
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

class PrintBlockOneOfAlignEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'left')
  static const PrintBlockOneOfAlignEnum left = _$printBlockOneOfAlignEnum_left;
  @BuiltValueEnumConst(wireName: r'center')
  static const PrintBlockOneOfAlignEnum center =
      _$printBlockOneOfAlignEnum_center;
  @BuiltValueEnumConst(wireName: r'right')
  static const PrintBlockOneOfAlignEnum right =
      _$printBlockOneOfAlignEnum_right;

  static Serializer<PrintBlockOneOfAlignEnum> get serializer =>
      _$printBlockOneOfAlignEnumSerializer;

  const PrintBlockOneOfAlignEnum._(String name) : super(name);

  static BuiltSet<PrintBlockOneOfAlignEnum> get values =>
      _$printBlockOneOfAlignEnumValues;
  static PrintBlockOneOfAlignEnum valueOf(String name) =>
      _$printBlockOneOfAlignEnumValueOf(name);
}

class PrintBlockOneOfSizeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r's')
  static const PrintBlockOneOfSizeEnum s = _$printBlockOneOfSizeEnum_s;
  @BuiltValueEnumConst(wireName: r'm')
  static const PrintBlockOneOfSizeEnum m = _$printBlockOneOfSizeEnum_m;
  @BuiltValueEnumConst(wireName: r'l')
  static const PrintBlockOneOfSizeEnum l = _$printBlockOneOfSizeEnum_l;

  static Serializer<PrintBlockOneOfSizeEnum> get serializer =>
      _$printBlockOneOfSizeEnumSerializer;

  const PrintBlockOneOfSizeEnum._(String name) : super(name);

  static BuiltSet<PrintBlockOneOfSizeEnum> get values =>
      _$printBlockOneOfSizeEnumValues;
  static PrintBlockOneOfSizeEnum valueOf(String name) =>
      _$printBlockOneOfSizeEnumValueOf(name);
}
