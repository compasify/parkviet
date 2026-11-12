//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_order_item_input.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_order_input.g.dart';

/// KioskOrderInput
///
/// Properties:
/// * [payment]
/// * [items]
@BuiltValue()
abstract class KioskOrderInput
    implements Built<KioskOrderInput, KioskOrderInputBuilder> {
  @BuiltValueField(wireName: r'payment')
  KioskOrderInputPaymentEnum get payment;
  // enum paymentEnum {  vietqr,  counter,  };

  @BuiltValueField(wireName: r'items')
  BuiltList<KioskOrderItemInput> get items;

  KioskOrderInput._();

  factory KioskOrderInput([void updates(KioskOrderInputBuilder b)]) =
      _$KioskOrderInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskOrderInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskOrderInput> get serializer =>
      _$KioskOrderInputSerializer();
}

class _$KioskOrderInputSerializer
    implements PrimitiveSerializer<KioskOrderInput> {
  @override
  final Iterable<Type> types = const [KioskOrderInput, _$KioskOrderInput];

  @override
  final String wireName = r'KioskOrderInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskOrderInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'payment';
    yield serializers.serialize(
      object.payment,
      specifiedType: const FullType(KioskOrderInputPaymentEnum),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(KioskOrderItemInput)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskOrderInput object, {
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
    required KioskOrderInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'payment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskOrderInputPaymentEnum),
          ) as KioskOrderInputPaymentEnum;
          result.payment = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KioskOrderItemInput)]),
          ) as BuiltList<KioskOrderItemInput>;
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
  KioskOrderInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskOrderInputBuilder();
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

class KioskOrderInputPaymentEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'vietqr')
  static const KioskOrderInputPaymentEnum vietqr =
      _$kioskOrderInputPaymentEnum_vietqr;
  @BuiltValueEnumConst(wireName: r'counter')
  static const KioskOrderInputPaymentEnum counter =
      _$kioskOrderInputPaymentEnum_counter;

  static Serializer<KioskOrderInputPaymentEnum> get serializer =>
      _$kioskOrderInputPaymentEnumSerializer;

  const KioskOrderInputPaymentEnum._(String name) : super(name);

  static BuiltSet<KioskOrderInputPaymentEnum> get values =>
      _$kioskOrderInputPaymentEnumValues;
  static KioskOrderInputPaymentEnum valueOf(String name) =>
      _$kioskOrderInputPaymentEnumValueOf(name);
}
