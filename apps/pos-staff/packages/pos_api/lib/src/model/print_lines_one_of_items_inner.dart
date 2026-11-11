//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_lines_one_of_items_inner.g.dart';

/// PrintLinesOneOfItemsInner
///
/// Properties:
/// * [index]
/// * [name]
/// * [amount]
/// * [details]
@BuiltValue()
abstract class PrintLinesOneOfItemsInner
    implements
        Built<PrintLinesOneOfItemsInner, PrintLinesOneOfItemsInnerBuilder> {
  @BuiltValueField(wireName: r'index')
  int? get index;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'details')
  BuiltList<String> get details;

  PrintLinesOneOfItemsInner._();

  factory PrintLinesOneOfItemsInner(
          [void updates(PrintLinesOneOfItemsInnerBuilder b)]) =
      _$PrintLinesOneOfItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintLinesOneOfItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintLinesOneOfItemsInner> get serializer =>
      _$PrintLinesOneOfItemsInnerSerializer();
}

class _$PrintLinesOneOfItemsInnerSerializer
    implements PrimitiveSerializer<PrintLinesOneOfItemsInner> {
  @override
  final Iterable<Type> types = const [
    PrintLinesOneOfItemsInner,
    _$PrintLinesOneOfItemsInner
  ];

  @override
  final String wireName = r'PrintLinesOneOfItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintLinesOneOfItemsInner object, {
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
    yield r'amount';
    yield object.amount == null
        ? null
        : serializers.serialize(
            object.amount,
            specifiedType: const FullType.nullable(String),
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
    PrintLinesOneOfItemsInner object, {
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
    required PrintLinesOneOfItemsInnerBuilder result,
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
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.amount = valueDes;
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
  PrintLinesOneOfItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintLinesOneOfItemsInnerBuilder();
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
