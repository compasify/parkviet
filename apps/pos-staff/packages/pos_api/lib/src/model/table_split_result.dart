//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/table_split_orders.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_split_result.g.dart';

/// TableSplitResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class TableSplitResult
    implements Built<TableSplitResult, TableSplitResultBuilder> {
  @BuiltValueField(wireName: r'data')
  TableSplitOrders get data;

  TableSplitResult._();

  factory TableSplitResult([void updates(TableSplitResultBuilder b)]) =
      _$TableSplitResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableSplitResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableSplitResult> get serializer =>
      _$TableSplitResultSerializer();
}

class _$TableSplitResultSerializer
    implements PrimitiveSerializer<TableSplitResult> {
  @override
  final Iterable<Type> types = const [TableSplitResult, _$TableSplitResult];

  @override
  final String wireName = r'TableSplitResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableSplitResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TableSplitOrders),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TableSplitResult object, {
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
    required TableSplitResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TableSplitOrders),
          ) as TableSplitOrders;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableSplitResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableSplitResultBuilder();
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
