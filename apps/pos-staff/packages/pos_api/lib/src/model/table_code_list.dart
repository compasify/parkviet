//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/table_code_entry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_code_list.g.dart';

/// TableCodeList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class TableCodeList
    implements Built<TableCodeList, TableCodeListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<TableCodeEntry> get data;

  TableCodeList._();

  factory TableCodeList([void updates(TableCodeListBuilder b)]) =
      _$TableCodeList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableCodeListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableCodeList> get serializer =>
      _$TableCodeListSerializer();
}

class _$TableCodeListSerializer implements PrimitiveSerializer<TableCodeList> {
  @override
  final Iterable<Type> types = const [TableCodeList, _$TableCodeList];

  @override
  final String wireName = r'TableCodeList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableCodeList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(TableCodeEntry)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TableCodeList object, {
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
    required TableCodeListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(TableCodeEntry)]),
          ) as BuiltList<TableCodeEntry>;
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
  TableCodeList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableCodeListBuilder();
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
