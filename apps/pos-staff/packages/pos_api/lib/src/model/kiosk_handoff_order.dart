//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kiosk_ref.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_handoff_order.g.dart';

/// KioskHandoffOrder
///
/// Properties:
/// * [id]
/// * [orderId]
/// * [orderNumber]
/// * [callNumber]
/// * [status]
/// * [register]
/// * [total]
/// * [currency]
/// * [itemCount]
/// * [openedAt]
/// * [waitingSince]
/// * [abandoned] - Waiting longer than half an hour; a cashier may cancel it.
@BuiltValue()
abstract class KioskHandoffOrder
    implements Built<KioskHandoffOrder, KioskHandoffOrderBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'order_id')
  String get orderId;

  @BuiltValueField(wireName: r'order_number')
  String get orderNumber;

  @BuiltValueField(wireName: r'call_number')
  int? get callNumber;

  @BuiltValueField(wireName: r'status')
  KioskHandoffOrderStatusEnum get status;
  // enum statusEnum {  draft,  editing,  parked,  };

  @BuiltValueField(wireName: r'register')
  KioskRef? get register;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'item_count')
  int get itemCount;

  @BuiltValueField(wireName: r'opened_at')
  String get openedAt;

  @BuiltValueField(wireName: r'waiting_since')
  String get waitingSince;

  /// Waiting longer than half an hour; a cashier may cancel it.
  @BuiltValueField(wireName: r'abandoned')
  bool get abandoned;

  KioskHandoffOrder._();

  factory KioskHandoffOrder([void updates(KioskHandoffOrderBuilder b)]) =
      _$KioskHandoffOrder;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskHandoffOrderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskHandoffOrder> get serializer =>
      _$KioskHandoffOrderSerializer();
}

class _$KioskHandoffOrderSerializer
    implements PrimitiveSerializer<KioskHandoffOrder> {
  @override
  final Iterable<Type> types = const [KioskHandoffOrder, _$KioskHandoffOrder];

  @override
  final String wireName = r'KioskHandoffOrder';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskHandoffOrder object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'order_id';
    yield serializers.serialize(
      object.orderId,
      specifiedType: const FullType(String),
    );
    yield r'order_number';
    yield serializers.serialize(
      object.orderNumber,
      specifiedType: const FullType(String),
    );
    yield r'call_number';
    yield object.callNumber == null
        ? null
        : serializers.serialize(
            object.callNumber,
            specifiedType: const FullType.nullable(int),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(KioskHandoffOrderStatusEnum),
    );
    yield r'register';
    yield object.register == null
        ? null
        : serializers.serialize(
            object.register,
            specifiedType: const FullType.nullable(KioskRef),
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
    yield r'item_count';
    yield serializers.serialize(
      object.itemCount,
      specifiedType: const FullType(int),
    );
    yield r'opened_at';
    yield serializers.serialize(
      object.openedAt,
      specifiedType: const FullType(String),
    );
    yield r'waiting_since';
    yield serializers.serialize(
      object.waitingSince,
      specifiedType: const FullType(String),
    );
    yield r'abandoned';
    yield serializers.serialize(
      object.abandoned,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskHandoffOrder object, {
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
    required KioskHandoffOrderBuilder result,
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
        case r'order_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderId = valueDes;
          break;
        case r'order_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderNumber = valueDes;
          break;
        case r'call_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.callNumber = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskHandoffOrderStatusEnum),
          ) as KioskHandoffOrderStatusEnum;
          result.status = valueDes;
          break;
        case r'register':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KioskRef),
          ) as KioskRef?;
          if (valueDes == null) continue;
          result.register.replace(valueDes);
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
        case r'item_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.itemCount = valueDes;
          break;
        case r'opened_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.openedAt = valueDes;
          break;
        case r'waiting_since':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.waitingSince = valueDes;
          break;
        case r'abandoned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.abandoned = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskHandoffOrder deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskHandoffOrderBuilder();
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

class KioskHandoffOrderStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const KioskHandoffOrderStatusEnum draft =
      _$kioskHandoffOrderStatusEnum_draft;
  @BuiltValueEnumConst(wireName: r'editing')
  static const KioskHandoffOrderStatusEnum editing =
      _$kioskHandoffOrderStatusEnum_editing;
  @BuiltValueEnumConst(wireName: r'parked')
  static const KioskHandoffOrderStatusEnum parked =
      _$kioskHandoffOrderStatusEnum_parked;

  static Serializer<KioskHandoffOrderStatusEnum> get serializer =>
      _$kioskHandoffOrderStatusEnumSerializer;

  const KioskHandoffOrderStatusEnum._(String name) : super(name);

  static BuiltSet<KioskHandoffOrderStatusEnum> get values =>
      _$kioskHandoffOrderStatusEnumValues;
  static KioskHandoffOrderStatusEnum valueOf(String name) =>
      _$kioskHandoffOrderStatusEnumValueOf(name);
}
