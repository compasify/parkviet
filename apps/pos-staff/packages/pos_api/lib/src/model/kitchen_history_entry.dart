//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_history_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_history_entry.g.dart';

/// KitchenHistoryEntry
///
/// Properties:
/// * [kind]
/// * [id]
/// * [sequence]
/// * [at]
/// * [staffName]
/// * [deviceId]
/// * [reasonCode]
/// * [note]
/// * [wasted]
/// * [approverName]
/// * [items]
@BuiltValue()
abstract class KitchenHistoryEntry
    implements Built<KitchenHistoryEntry, KitchenHistoryEntryBuilder> {
  @BuiltValueField(wireName: r'kind')
  KitchenHistoryEntryKindEnum get kind;
  // enum kindEnum {  send,  void,  };

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'sequence')
  int? get sequence;

  @BuiltValueField(wireName: r'at')
  DateTime get at;

  @BuiltValueField(wireName: r'staff_name')
  String? get staffName;

  @BuiltValueField(wireName: r'device_id')
  String? get deviceId;

  @BuiltValueField(wireName: r'reason_code')
  String? get reasonCode;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'wasted')
  bool? get wasted;

  @BuiltValueField(wireName: r'approver_name')
  String? get approverName;

  @BuiltValueField(wireName: r'items')
  BuiltList<KitchenHistoryItem> get items;

  KitchenHistoryEntry._();

  factory KitchenHistoryEntry([void updates(KitchenHistoryEntryBuilder b)]) =
      _$KitchenHistoryEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenHistoryEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenHistoryEntry> get serializer =>
      _$KitchenHistoryEntrySerializer();
}

class _$KitchenHistoryEntrySerializer
    implements PrimitiveSerializer<KitchenHistoryEntry> {
  @override
  final Iterable<Type> types = const [
    KitchenHistoryEntry,
    _$KitchenHistoryEntry
  ];

  @override
  final String wireName = r'KitchenHistoryEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenHistoryEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(KitchenHistoryEntryKindEnum),
    );
    yield r'id';
    yield object.id == null
        ? null
        : serializers.serialize(
            object.id,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sequence';
    yield object.sequence == null
        ? null
        : serializers.serialize(
            object.sequence,
            specifiedType: const FullType.nullable(int),
          );
    yield r'at';
    yield serializers.serialize(
      object.at,
      specifiedType: const FullType(DateTime),
    );
    yield r'staff_name';
    yield object.staffName == null
        ? null
        : serializers.serialize(
            object.staffName,
            specifiedType: const FullType.nullable(String),
          );
    if (object.deviceId != null) {
      yield r'device_id';
      yield serializers.serialize(
        object.deviceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reasonCode != null) {
      yield r'reason_code';
      yield serializers.serialize(
        object.reasonCode,
        specifiedType: const FullType(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.wasted != null) {
      yield r'wasted';
      yield serializers.serialize(
        object.wasted,
        specifiedType: const FullType(bool),
      );
    }
    if (object.approverName != null) {
      yield r'approver_name';
      yield serializers.serialize(
        object.approverName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(KitchenHistoryItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenHistoryEntry object, {
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
    required KitchenHistoryEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenHistoryEntryKindEnum),
          ) as KitchenHistoryEntryKindEnum;
          result.kind = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sequence = valueDes;
          break;
        case r'at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.at = valueDes;
          break;
        case r'staff_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.staffName = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceId = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonCode = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'wasted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.wasted = valueDes;
          break;
        case r'approver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approverName = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenHistoryItem)]),
          ) as BuiltList<KitchenHistoryItem>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenHistoryEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenHistoryEntryBuilder();
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

class KitchenHistoryEntryKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'send')
  static const KitchenHistoryEntryKindEnum send =
      _$kitchenHistoryEntryKindEnum_send;
  @BuiltValueEnumConst(wireName: r'void')
  static const KitchenHistoryEntryKindEnum void_ =
      _$kitchenHistoryEntryKindEnum_void_;

  static Serializer<KitchenHistoryEntryKindEnum> get serializer =>
      _$kitchenHistoryEntryKindEnumSerializer;

  const KitchenHistoryEntryKindEnum._(String name) : super(name);

  static BuiltSet<KitchenHistoryEntryKindEnum> get values =>
      _$kitchenHistoryEntryKindEnumValues;
  static KitchenHistoryEntryKindEnum valueOf(String name) =>
      _$kitchenHistoryEntryKindEnumValueOf(name);
}
