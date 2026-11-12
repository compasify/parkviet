//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/owner_open_order_line.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_open_order.g.dart';

/// OwnerOpenOrder
///
/// Properties:
/// * [workspaceId]
/// * [label]
/// * [orderNumber]
/// * [orderSource]
/// * [serviceMode]
/// * [status]
/// * [guestCount]
/// * [openedAt]
/// * [minutesOpen]
/// * [total]
/// * [currency]
/// * [lines]
@BuiltValue()
abstract class OwnerOpenOrder
    implements Built<OwnerOpenOrder, OwnerOpenOrderBuilder> {
  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'order_number')
  String? get orderNumber;

  @BuiltValueField(wireName: r'order_source')
  String get orderSource;

  @BuiltValueField(wireName: r'service_mode')
  String? get serviceMode;

  @BuiltValueField(wireName: r'status')
  OwnerOpenOrderStatusEnum get status;
  // enum statusEnum {  editing,  parked,  };

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  @BuiltValueField(wireName: r'opened_at')
  DateTime get openedAt;

  @BuiltValueField(wireName: r'minutes_open')
  int get minutesOpen;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'lines')
  BuiltList<OwnerOpenOrderLine> get lines;

  OwnerOpenOrder._();

  factory OwnerOpenOrder([void updates(OwnerOpenOrderBuilder b)]) =
      _$OwnerOpenOrder;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerOpenOrderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerOpenOrder> get serializer =>
      _$OwnerOpenOrderSerializer();
}

class _$OwnerOpenOrderSerializer
    implements PrimitiveSerializer<OwnerOpenOrder> {
  @override
  final Iterable<Type> types = const [OwnerOpenOrder, _$OwnerOpenOrder];

  @override
  final String wireName = r'OwnerOpenOrder';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerOpenOrder object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield object.label == null
        ? null
        : serializers.serialize(
            object.label,
            specifiedType: const FullType.nullable(String),
          );
    yield r'order_number';
    yield object.orderNumber == null
        ? null
        : serializers.serialize(
            object.orderNumber,
            specifiedType: const FullType.nullable(String),
          );
    yield r'order_source';
    yield serializers.serialize(
      object.orderSource,
      specifiedType: const FullType(String),
    );
    yield r'service_mode';
    yield object.serviceMode == null
        ? null
        : serializers.serialize(
            object.serviceMode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OwnerOpenOrderStatusEnum),
    );
    yield r'guest_count';
    yield object.guestCount == null
        ? null
        : serializers.serialize(
            object.guestCount,
            specifiedType: const FullType.nullable(int),
          );
    yield r'opened_at';
    yield serializers.serialize(
      object.openedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'minutes_open';
    yield serializers.serialize(
      object.minutesOpen,
      specifiedType: const FullType(int),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(OwnerOpenOrderLine)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerOpenOrder object, {
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
    required OwnerOpenOrderBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'order_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.orderNumber = valueDes;
          break;
        case r'order_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderSource = valueDes;
          break;
        case r'service_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.serviceMode = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnerOpenOrderStatusEnum),
          ) as OwnerOpenOrderStatusEnum;
          result.status = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'opened_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.openedAt = valueDes;
          break;
        case r'minutes_open':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minutesOpen = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(OwnerOpenOrderLine)]),
          ) as BuiltList<OwnerOpenOrderLine>;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnerOpenOrder deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerOpenOrderBuilder();
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

class OwnerOpenOrderStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'editing')
  static const OwnerOpenOrderStatusEnum editing =
      _$ownerOpenOrderStatusEnum_editing;
  @BuiltValueEnumConst(wireName: r'parked')
  static const OwnerOpenOrderStatusEnum parked =
      _$ownerOpenOrderStatusEnum_parked;

  static Serializer<OwnerOpenOrderStatusEnum> get serializer =>
      _$ownerOpenOrderStatusEnumSerializer;

  const OwnerOpenOrderStatusEnum._(String name) : super(name);

  static BuiltSet<OwnerOpenOrderStatusEnum> get values =>
      _$ownerOpenOrderStatusEnumValues;
  static OwnerOpenOrderStatusEnum valueOf(String name) =>
      _$ownerOpenOrderStatusEnumValueOf(name);
}
