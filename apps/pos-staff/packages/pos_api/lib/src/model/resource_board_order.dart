//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_board_order.g.dart';

/// ResourceBoardOrder
///
/// Properties:
/// * [id]
/// * [tableLabel]
/// * [guestCount]
/// * [total]
/// * [revision]
/// * [operationalStatus]
/// * [paymentRequested]
/// * [prebilled] - Its current pre-bill matches the order.
/// * [editedAfterPrebill]
/// * [pendingKitchenItems]
@BuiltValue()
abstract class ResourceBoardOrder
    implements Built<ResourceBoardOrder, ResourceBoardOrderBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'table_label')
  String? get tableLabel;

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'operational_status')
  ResourceBoardOrderOperationalStatusEnum get operationalStatus;
  // enum operationalStatusEnum {  editing,  parked,  };

  @BuiltValueField(wireName: r'payment_requested')
  bool get paymentRequested;

  /// Its current pre-bill matches the order.
  @BuiltValueField(wireName: r'prebilled')
  bool get prebilled;

  @BuiltValueField(wireName: r'edited_after_prebill')
  bool get editedAfterPrebill;

  @BuiltValueField(wireName: r'pending_kitchen_items')
  int get pendingKitchenItems;

  ResourceBoardOrder._();

  factory ResourceBoardOrder([void updates(ResourceBoardOrderBuilder b)]) =
      _$ResourceBoardOrder;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceBoardOrderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceBoardOrder> get serializer =>
      _$ResourceBoardOrderSerializer();
}

class _$ResourceBoardOrderSerializer
    implements PrimitiveSerializer<ResourceBoardOrder> {
  @override
  final Iterable<Type> types = const [ResourceBoardOrder, _$ResourceBoardOrder];

  @override
  final String wireName = r'ResourceBoardOrder';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceBoardOrder object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'table_label';
    yield object.tableLabel == null
        ? null
        : serializers.serialize(
            object.tableLabel,
            specifiedType: const FullType.nullable(String),
          );
    yield r'guest_count';
    yield object.guestCount == null
        ? null
        : serializers.serialize(
            object.guestCount,
            specifiedType: const FullType.nullable(int),
          );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'operational_status';
    yield serializers.serialize(
      object.operationalStatus,
      specifiedType: const FullType(ResourceBoardOrderOperationalStatusEnum),
    );
    yield r'payment_requested';
    yield serializers.serialize(
      object.paymentRequested,
      specifiedType: const FullType(bool),
    );
    yield r'prebilled';
    yield serializers.serialize(
      object.prebilled,
      specifiedType: const FullType(bool),
    );
    yield r'edited_after_prebill';
    yield serializers.serialize(
      object.editedAfterPrebill,
      specifiedType: const FullType(bool),
    );
    yield r'pending_kitchen_items';
    yield serializers.serialize(
      object.pendingKitchenItems,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceBoardOrder object, {
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
    required ResourceBoardOrderBuilder result,
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
        case r'table_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tableLabel = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'operational_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(ResourceBoardOrderOperationalStatusEnum),
          ) as ResourceBoardOrderOperationalStatusEnum;
          result.operationalStatus = valueDes;
          break;
        case r'payment_requested':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.paymentRequested = valueDes;
          break;
        case r'prebilled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.prebilled = valueDes;
          break;
        case r'edited_after_prebill':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.editedAfterPrebill = valueDes;
          break;
        case r'pending_kitchen_items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pendingKitchenItems = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResourceBoardOrder deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceBoardOrderBuilder();
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

class ResourceBoardOrderOperationalStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'editing')
  static const ResourceBoardOrderOperationalStatusEnum editing =
      _$resourceBoardOrderOperationalStatusEnum_editing;
  @BuiltValueEnumConst(wireName: r'parked')
  static const ResourceBoardOrderOperationalStatusEnum parked =
      _$resourceBoardOrderOperationalStatusEnum_parked;

  static Serializer<ResourceBoardOrderOperationalStatusEnum> get serializer =>
      _$resourceBoardOrderOperationalStatusEnumSerializer;

  const ResourceBoardOrderOperationalStatusEnum._(String name) : super(name);

  static BuiltSet<ResourceBoardOrderOperationalStatusEnum> get values =>
      _$resourceBoardOrderOperationalStatusEnumValues;
  static ResourceBoardOrderOperationalStatusEnum valueOf(String name) =>
      _$resourceBoardOrderOperationalStatusEnumValueOf(name);
}
