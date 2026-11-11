//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_lines_one_of1_headings.g.dart';

/// PrintLinesOneOf1Headings
///
/// Properties:
/// * [index]
/// * [name]
@BuiltValue()
abstract class PrintLinesOneOf1Headings
    implements
        Built<PrintLinesOneOf1Headings, PrintLinesOneOf1HeadingsBuilder> {
  @BuiltValueField(wireName: r'index')
  String? get index;

  @BuiltValueField(wireName: r'name')
  String get name;

  PrintLinesOneOf1Headings._();

  factory PrintLinesOneOf1Headings(
          [void updates(PrintLinesOneOf1HeadingsBuilder b)]) =
      _$PrintLinesOneOf1Headings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintLinesOneOf1HeadingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintLinesOneOf1Headings> get serializer =>
      _$PrintLinesOneOf1HeadingsSerializer();
}

class _$PrintLinesOneOf1HeadingsSerializer
    implements PrimitiveSerializer<PrintLinesOneOf1Headings> {
  @override
  final Iterable<Type> types = const [
    PrintLinesOneOf1Headings,
    _$PrintLinesOneOf1Headings
  ];

  @override
  final String wireName = r'PrintLinesOneOf1Headings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintLinesOneOf1Headings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'index';
    yield object.index == null
        ? null
        : serializers.serialize(
            object.index,
            specifiedType: const FullType.nullable(String),
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
    PrintLinesOneOf1Headings object, {
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
    required PrintLinesOneOf1HeadingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.index = valueDes;
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
  PrintLinesOneOf1Headings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintLinesOneOf1HeadingsBuilder();
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
