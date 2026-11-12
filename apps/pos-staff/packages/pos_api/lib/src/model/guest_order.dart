//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/guest_order_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_order.g.dart';

/// GuestOrder
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [workspaceId]
/// * [resourceId]
/// * [tableName] - The table and the letter of its order.
/// * [areaId]
/// * [status]
/// * [automatic] - Accepted by the branch's straight-to-kitchen mode.
/// * [items]
/// * [quotedTotal]
/// * [currency]
/// * [itemCount]
/// * [rejectReason]
/// * [decidedById]
/// * [decidedByName]
/// * [decidedAt]
/// * [createdAt]
@BuiltValue()
abstract class GuestOrder implements Built<GuestOrder, GuestOrderBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  /// The table and the letter of its order.
  @BuiltValueField(wireName: r'table_name')
  String get tableName;

  @BuiltValueField(wireName: r'area_id')
  String? get areaId;

  @BuiltValueField(wireName: r'status')
  GuestOrderStatusEnum get status;
  // enum statusEnum {  pending,  accepted,  rejected,  expired,  };

  /// Accepted by the branch's straight-to-kitchen mode.
  @BuiltValueField(wireName: r'automatic')
  bool get automatic;

  @BuiltValueField(wireName: r'items')
  BuiltList<GuestOrderItem> get items;

  @BuiltValueField(wireName: r'quoted_total')
  String get quotedTotal;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'item_count')
  int get itemCount;

  @BuiltValueField(wireName: r'reject_reason')
  String? get rejectReason;

  @BuiltValueField(wireName: r'decided_by_id')
  String? get decidedById;

  @BuiltValueField(wireName: r'decided_by_name')
  String? get decidedByName;

  @BuiltValueField(wireName: r'decided_at')
  DateTime? get decidedAt;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  GuestOrder._();

  factory GuestOrder([void updates(GuestOrderBuilder b)]) = _$GuestOrder;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestOrderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestOrder> get serializer => _$GuestOrderSerializer();
}

class _$GuestOrderSerializer implements PrimitiveSerializer<GuestOrder> {
  @override
  final Iterable<Type> types = const [GuestOrder, _$GuestOrder];

  @override
  final String wireName = r'GuestOrder';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestOrder object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    yield r'table_name';
    yield serializers.serialize(
      object.tableName,
      specifiedType: const FullType(String),
    );
    yield r'area_id';
    yield object.areaId == null
        ? null
        : serializers.serialize(
            object.areaId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(GuestOrderStatusEnum),
    );
    yield r'automatic';
    yield serializers.serialize(
      object.automatic,
      specifiedType: const FullType(bool),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(GuestOrderItem)]),
    );
    yield r'quoted_total';
    yield serializers.serialize(
      object.quotedTotal,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'item_count';
    yield serializers.serialize(
      object.itemCount,
      specifiedType: const FullType(int),
    );
    yield r'reject_reason';
    yield object.rejectReason == null
        ? null
        : serializers.serialize(
            object.rejectReason,
            specifiedType: const FullType.nullable(String),
          );
    yield r'decided_by_id';
    yield object.decidedById == null
        ? null
        : serializers.serialize(
            object.decidedById,
            specifiedType: const FullType.nullable(String),
          );
    yield r'decided_by_name';
    yield object.decidedByName == null
        ? null
        : serializers.serialize(
            object.decidedByName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'decided_at';
    yield object.decidedAt == null
        ? null
        : serializers.serialize(
            object.decidedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestOrder object, {
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
    required GuestOrderBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'table_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tableName = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.areaId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GuestOrderStatusEnum),
          ) as GuestOrderStatusEnum;
          result.status = valueDes;
          break;
        case r'automatic':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.automatic = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(GuestOrderItem)]),
          ) as BuiltList<GuestOrderItem>;
          result.items.replace(valueDes);
          break;
        case r'quoted_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quotedTotal = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'item_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.itemCount = valueDes;
          break;
        case r'reject_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.rejectReason = valueDes;
          break;
        case r'decided_by_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decidedById = valueDes;
          break;
        case r'decided_by_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decidedByName = valueDes;
          break;
        case r'decided_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.decidedAt = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GuestOrder deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestOrderBuilder();
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

class GuestOrderStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const GuestOrderStatusEnum pending = _$guestOrderStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'accepted')
  static const GuestOrderStatusEnum accepted = _$guestOrderStatusEnum_accepted;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const GuestOrderStatusEnum rejected = _$guestOrderStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'expired')
  static const GuestOrderStatusEnum expired = _$guestOrderStatusEnum_expired;

  static Serializer<GuestOrderStatusEnum> get serializer =>
      _$guestOrderStatusEnumSerializer;

  const GuestOrderStatusEnum._(String name) : super(name);

  static BuiltSet<GuestOrderStatusEnum> get values =>
      _$guestOrderStatusEnumValues;
  static GuestOrderStatusEnum valueOf(String name) =>
      _$guestOrderStatusEnumValueOf(name);
}
