//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_split_input.g.dart';

/// The chosen `sale_line_ids` move to a new order, or with `by: seat` every seat of the order gets its own bill.
///
/// Properties:
/// * [by]
/// * [shared] - A dish without a seat, by sale line id, and the seat whose bill takes it; the first seat otherwise.
/// * [expectedRevision]
/// * [leaseGeneration]
/// * [editorId]
/// * [saleLineIds]
/// * [resourceId] - The table of the new order; this order's table by default.
/// * [guestCount]
@BuiltValue()
abstract class TableSplitInput
    implements Built<TableSplitInput, TableSplitInputBuilder> {
  @BuiltValueField(wireName: r'by')
  TableSplitInputByEnum? get by;
  // enum byEnum {  lines,  seat,  };

  /// A dish without a seat, by sale line id, and the seat whose bill takes it; the first seat otherwise.
  @BuiltValueField(wireName: r'shared')
  BuiltMap<String, int>? get shared;

  @BuiltValueField(wireName: r'expected_revision')
  int get expectedRevision;

  @BuiltValueField(wireName: r'lease_generation')
  int get leaseGeneration;

  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  @BuiltValueField(wireName: r'sale_line_ids')
  BuiltList<String>? get saleLineIds;

  /// The table of the new order; this order's table by default.
  @BuiltValueField(wireName: r'resource_id')
  String? get resourceId;

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  TableSplitInput._();

  factory TableSplitInput([void updates(TableSplitInputBuilder b)]) =
      _$TableSplitInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableSplitInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableSplitInput> get serializer =>
      _$TableSplitInputSerializer();
}

class _$TableSplitInputSerializer
    implements PrimitiveSerializer<TableSplitInput> {
  @override
  final Iterable<Type> types = const [TableSplitInput, _$TableSplitInput];

  @override
  final String wireName = r'TableSplitInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableSplitInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.by != null) {
      yield r'by';
      yield serializers.serialize(
        object.by,
        specifiedType: const FullType(TableSplitInputByEnum),
      );
    }
    if (object.shared != null) {
      yield r'shared';
      yield serializers.serialize(
        object.shared,
        specifiedType:
            const FullType(BuiltMap, [FullType(String), FullType(int)]),
      );
    }
    yield r'expected_revision';
    yield serializers.serialize(
      object.expectedRevision,
      specifiedType: const FullType(int),
    );
    yield r'lease_generation';
    yield serializers.serialize(
      object.leaseGeneration,
      specifiedType: const FullType(int),
    );
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
    if (object.saleLineIds != null) {
      yield r'sale_line_ids';
      yield serializers.serialize(
        object.saleLineIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.resourceId != null) {
      yield r'resource_id';
      yield serializers.serialize(
        object.resourceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.guestCount != null) {
      yield r'guest_count';
      yield serializers.serialize(
        object.guestCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TableSplitInput object, {
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
    required TableSplitInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TableSplitInputByEnum),
          ) as TableSplitInputByEnum?;
          if (valueDes == null) continue;
          result.by = valueDes;
          break;
        case r'shared':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType(int)]),
          ) as BuiltMap<String, int>?;
          if (valueDes == null) continue;
          result.shared.replace(valueDes);
          break;
        case r'expected_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedRevision = valueDes;
          break;
        case r'lease_generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.leaseGeneration = valueDes;
          break;
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorId = valueDes;
          break;
        case r'sale_line_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.saleLineIds.replace(valueDes);
          break;
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resourceId = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableSplitInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableSplitInputBuilder();
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

class TableSplitInputByEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'lines')
  static const TableSplitInputByEnum lines = _$tableSplitInputByEnum_lines;
  @BuiltValueEnumConst(wireName: r'seat')
  static const TableSplitInputByEnum seat = _$tableSplitInputByEnum_seat;

  static Serializer<TableSplitInputByEnum> get serializer =>
      _$tableSplitInputByEnumSerializer;

  const TableSplitInputByEnum._(String name) : super(name);

  static BuiltSet<TableSplitInputByEnum> get values =>
      _$tableSplitInputByEnumValues;
  static TableSplitInputByEnum valueOf(String name) =>
      _$tableSplitInputByEnumValueOf(name);
}
