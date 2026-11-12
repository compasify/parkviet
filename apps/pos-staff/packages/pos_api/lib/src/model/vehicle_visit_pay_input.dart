//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_visit_pay_input.g.dart';

/// VehicleVisitPayInput
///
/// Properties:
/// * [payoutMethod]
/// * [transferReference]
@BuiltValue()
abstract class VehicleVisitPayInput
    implements Built<VehicleVisitPayInput, VehicleVisitPayInputBuilder> {
  @BuiltValueField(wireName: r'payout_method')
  VehicleVisitPayInputPayoutMethodEnum get payoutMethod;
  // enum payoutMethodEnum {  cash,  transfer,  };

  @BuiltValueField(wireName: r'transfer_reference')
  String? get transferReference;

  VehicleVisitPayInput._();

  factory VehicleVisitPayInput([void updates(VehicleVisitPayInputBuilder b)]) =
      _$VehicleVisitPayInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleVisitPayInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleVisitPayInput> get serializer =>
      _$VehicleVisitPayInputSerializer();
}

class _$VehicleVisitPayInputSerializer
    implements PrimitiveSerializer<VehicleVisitPayInput> {
  @override
  final Iterable<Type> types = const [
    VehicleVisitPayInput,
    _$VehicleVisitPayInput
  ];

  @override
  final String wireName = r'VehicleVisitPayInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleVisitPayInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'payout_method';
    yield serializers.serialize(
      object.payoutMethod,
      specifiedType: const FullType(VehicleVisitPayInputPayoutMethodEnum),
    );
    if (object.transferReference != null) {
      yield r'transfer_reference';
      yield serializers.serialize(
        object.transferReference,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleVisitPayInput object, {
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
    required VehicleVisitPayInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'payout_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VehicleVisitPayInputPayoutMethodEnum),
          ) as VehicleVisitPayInputPayoutMethodEnum;
          result.payoutMethod = valueDes;
          break;
        case r'transfer_reference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.transferReference = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleVisitPayInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleVisitPayInputBuilder();
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

class VehicleVisitPayInputPayoutMethodEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cash')
  static const VehicleVisitPayInputPayoutMethodEnum cash =
      _$vehicleVisitPayInputPayoutMethodEnum_cash;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const VehicleVisitPayInputPayoutMethodEnum transfer =
      _$vehicleVisitPayInputPayoutMethodEnum_transfer;

  static Serializer<VehicleVisitPayInputPayoutMethodEnum> get serializer =>
      _$vehicleVisitPayInputPayoutMethodEnumSerializer;

  const VehicleVisitPayInputPayoutMethodEnum._(String name) : super(name);

  static BuiltSet<VehicleVisitPayInputPayoutMethodEnum> get values =>
      _$vehicleVisitPayInputPayoutMethodEnumValues;
  static VehicleVisitPayInputPayoutMethodEnum valueOf(String name) =>
      _$vehicleVisitPayInputPayoutMethodEnumValueOf(name);
}
