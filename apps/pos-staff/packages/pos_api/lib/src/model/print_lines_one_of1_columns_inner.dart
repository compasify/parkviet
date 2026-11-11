//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_lines_one_of1_columns_inner.g.dart';

/// PrintLinesOneOf1ColumnsInner
///
/// Properties:
/// * [key]
/// * [label]
@BuiltValue()
abstract class PrintLinesOneOf1ColumnsInner
    implements
        Built<PrintLinesOneOf1ColumnsInner,
            PrintLinesOneOf1ColumnsInnerBuilder> {
  @BuiltValueField(wireName: r'key')
  PrintLinesOneOf1ColumnsInnerKeyEnum get key;
  // enum keyEnum {  qty,  price,  discount,  amount,  };

  @BuiltValueField(wireName: r'label')
  String get label;

  PrintLinesOneOf1ColumnsInner._();

  factory PrintLinesOneOf1ColumnsInner(
          [void updates(PrintLinesOneOf1ColumnsInnerBuilder b)]) =
      _$PrintLinesOneOf1ColumnsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintLinesOneOf1ColumnsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintLinesOneOf1ColumnsInner> get serializer =>
      _$PrintLinesOneOf1ColumnsInnerSerializer();
}

class _$PrintLinesOneOf1ColumnsInnerSerializer
    implements PrimitiveSerializer<PrintLinesOneOf1ColumnsInner> {
  @override
  final Iterable<Type> types = const [
    PrintLinesOneOf1ColumnsInner,
    _$PrintLinesOneOf1ColumnsInner
  ];

  @override
  final String wireName = r'PrintLinesOneOf1ColumnsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintLinesOneOf1ColumnsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(PrintLinesOneOf1ColumnsInnerKeyEnum),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintLinesOneOf1ColumnsInner object, {
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
    required PrintLinesOneOf1ColumnsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintLinesOneOf1ColumnsInnerKeyEnum),
          ) as PrintLinesOneOf1ColumnsInnerKeyEnum;
          result.key = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintLinesOneOf1ColumnsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintLinesOneOf1ColumnsInnerBuilder();
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

class PrintLinesOneOf1ColumnsInnerKeyEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'qty')
  static const PrintLinesOneOf1ColumnsInnerKeyEnum qty =
      _$printLinesOneOf1ColumnsInnerKeyEnum_qty;
  @BuiltValueEnumConst(wireName: r'price')
  static const PrintLinesOneOf1ColumnsInnerKeyEnum price =
      _$printLinesOneOf1ColumnsInnerKeyEnum_price;
  @BuiltValueEnumConst(wireName: r'discount')
  static const PrintLinesOneOf1ColumnsInnerKeyEnum discount =
      _$printLinesOneOf1ColumnsInnerKeyEnum_discount;
  @BuiltValueEnumConst(wireName: r'amount')
  static const PrintLinesOneOf1ColumnsInnerKeyEnum amount =
      _$printLinesOneOf1ColumnsInnerKeyEnum_amount;

  static Serializer<PrintLinesOneOf1ColumnsInnerKeyEnum> get serializer =>
      _$printLinesOneOf1ColumnsInnerKeyEnumSerializer;

  const PrintLinesOneOf1ColumnsInnerKeyEnum._(String name) : super(name);

  static BuiltSet<PrintLinesOneOf1ColumnsInnerKeyEnum> get values =>
      _$printLinesOneOf1ColumnsInnerKeyEnumValues;
  static PrintLinesOneOf1ColumnsInnerKeyEnum valueOf(String name) =>
      _$printLinesOneOf1ColumnsInnerKeyEnumValueOf(name);
}
