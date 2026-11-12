//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/table_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_code_entry.g.dart';

/// TableCodeEntry
///
/// Properties:
/// * [resourceId]
/// * [name]
/// * [areaId]
/// * [tableCode]
@BuiltValue()
abstract class TableCodeEntry
    implements Built<TableCodeEntry, TableCodeEntryBuilder> {
  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'area_id')
  String get areaId;

  @BuiltValueField(wireName: r'table_code')
  TableCode? get tableCode;

  TableCodeEntry._();

  factory TableCodeEntry([void updates(TableCodeEntryBuilder b)]) =
      _$TableCodeEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableCodeEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableCodeEntry> get serializer =>
      _$TableCodeEntrySerializer();
}

class _$TableCodeEntrySerializer
    implements PrimitiveSerializer<TableCodeEntry> {
  @override
  final Iterable<Type> types = const [TableCodeEntry, _$TableCodeEntry];

  @override
  final String wireName = r'TableCodeEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableCodeEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'area_id';
    yield serializers.serialize(
      object.areaId,
      specifiedType: const FullType(String),
    );
    yield r'table_code';
    yield object.tableCode == null
        ? null
        : serializers.serialize(
            object.tableCode,
            specifiedType: const FullType.nullable(TableCode),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    TableCodeEntry object, {
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
    required TableCodeEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.areaId = valueDes;
          break;
        case r'table_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TableCode),
          ) as TableCode?;
          if (valueDes == null) continue;
          result.tableCode.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableCodeEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableCodeEntryBuilder();
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
