//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_lines_one_of1_rows_inner.g.dart';

/// PrintLinesOneOf1RowsInner
///
/// Properties:
/// * [index]
/// * [name]
/// * [cells]
/// * [details]
@BuiltValue()
abstract class PrintLinesOneOf1RowsInner
    implements
        Built<PrintLinesOneOf1RowsInner, PrintLinesOneOf1RowsInnerBuilder> {
  @BuiltValueField(wireName: r'index')
  int? get index;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'cells')
  BuiltList<String> get cells;

  @BuiltValueField(wireName: r'details')
  BuiltList<String> get details;

  PrintLinesOneOf1RowsInner._();

  factory PrintLinesOneOf1RowsInner(
          [void updates(PrintLinesOneOf1RowsInnerBuilder b)]) =
      _$PrintLinesOneOf1RowsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintLinesOneOf1RowsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintLinesOneOf1RowsInner> get serializer =>
      _$PrintLinesOneOf1RowsInnerSerializer();
}

class _$PrintLinesOneOf1RowsInnerSerializer
    implements PrimitiveSerializer<PrintLinesOneOf1RowsInner> {
  @override
  final Iterable<Type> types = const [
    PrintLinesOneOf1RowsInner,
    _$PrintLinesOneOf1RowsInner
  ];

  @override
  final String wireName = r'PrintLinesOneOf1RowsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintLinesOneOf1RowsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'index';
    yield object.index == null
        ? null
        : serializers.serialize(
            object.index,
            specifiedType: const FullType.nullable(int),
          );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'cells';
    yield serializers.serialize(
      object.cells,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'details';
    yield serializers.serialize(
      object.details,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintLinesOneOf1RowsInner object, {
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
    required PrintLinesOneOf1RowsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
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
        case r'cells':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.cells.replace(valueDes);
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.details.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintLinesOneOf1RowsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintLinesOneOf1RowsInnerBuilder();
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
