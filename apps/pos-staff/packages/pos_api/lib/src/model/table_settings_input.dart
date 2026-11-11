//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_settings_input.g.dart';

/// TableSettingsInput
///
/// Properties:
/// * [branchId]
/// * [tableRegisterId]
/// * [serviceChargeRate]
/// * [serviceChargeAppliesTo]
/// * [serviceChargeTaxCategoryId]
@BuiltValue()
abstract class TableSettingsInput
    implements Built<TableSettingsInput, TableSettingsInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'table_register_id')
  String? get tableRegisterId;

  @BuiltValueField(wireName: r'service_charge_rate')
  String? get serviceChargeRate;

  @BuiltValueField(wireName: r'service_charge_applies_to')
  BuiltList<TableSettingsInputServiceChargeAppliesToEnum>?
      get serviceChargeAppliesTo;
  // enum serviceChargeAppliesToEnum {  counter,  dine_in,  takeaway,  delivery,  tab,  timed,  };

  @BuiltValueField(wireName: r'service_charge_tax_category_id')
  String? get serviceChargeTaxCategoryId;

  TableSettingsInput._();

  factory TableSettingsInput([void updates(TableSettingsInputBuilder b)]) =
      _$TableSettingsInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableSettingsInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableSettingsInput> get serializer =>
      _$TableSettingsInputSerializer();
}

class _$TableSettingsInputSerializer
    implements PrimitiveSerializer<TableSettingsInput> {
  @override
  final Iterable<Type> types = const [TableSettingsInput, _$TableSettingsInput];

  @override
  final String wireName = r'TableSettingsInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableSettingsInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    if (object.tableRegisterId != null) {
      yield r'table_register_id';
      yield serializers.serialize(
        object.tableRegisterId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.serviceChargeRate != null) {
      yield r'service_charge_rate';
      yield serializers.serialize(
        object.serviceChargeRate,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.serviceChargeAppliesTo != null) {
      yield r'service_charge_applies_to';
      yield serializers.serialize(
        object.serviceChargeAppliesTo,
        specifiedType: const FullType(BuiltList,
            [FullType(TableSettingsInputServiceChargeAppliesToEnum)]),
      );
    }
    if (object.serviceChargeTaxCategoryId != null) {
      yield r'service_charge_tax_category_id';
      yield serializers.serialize(
        object.serviceChargeTaxCategoryId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TableSettingsInput object, {
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
    required TableSettingsInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'table_register_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tableRegisterId = valueDes;
          break;
        case r'service_charge_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.serviceChargeRate = valueDes;
          break;
        case r'service_charge_applies_to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList,
                [FullType(TableSettingsInputServiceChargeAppliesToEnum)]),
          ) as BuiltList<TableSettingsInputServiceChargeAppliesToEnum>?;
          if (valueDes == null) continue;
          result.serviceChargeAppliesTo.replace(valueDes);
          break;
        case r'service_charge_tax_category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.serviceChargeTaxCategoryId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableSettingsInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableSettingsInputBuilder();
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

class TableSettingsInputServiceChargeAppliesToEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'counter')
  static const TableSettingsInputServiceChargeAppliesToEnum counter =
      _$tableSettingsInputServiceChargeAppliesToEnum_counter;
  @BuiltValueEnumConst(wireName: r'dine_in')
  static const TableSettingsInputServiceChargeAppliesToEnum dineIn =
      _$tableSettingsInputServiceChargeAppliesToEnum_dineIn;
  @BuiltValueEnumConst(wireName: r'takeaway')
  static const TableSettingsInputServiceChargeAppliesToEnum takeaway =
      _$tableSettingsInputServiceChargeAppliesToEnum_takeaway;
  @BuiltValueEnumConst(wireName: r'delivery')
  static const TableSettingsInputServiceChargeAppliesToEnum delivery =
      _$tableSettingsInputServiceChargeAppliesToEnum_delivery;
  @BuiltValueEnumConst(wireName: r'tab')
  static const TableSettingsInputServiceChargeAppliesToEnum tab =
      _$tableSettingsInputServiceChargeAppliesToEnum_tab;
  @BuiltValueEnumConst(wireName: r'timed')
  static const TableSettingsInputServiceChargeAppliesToEnum timed =
      _$tableSettingsInputServiceChargeAppliesToEnum_timed;

  static Serializer<TableSettingsInputServiceChargeAppliesToEnum>
      get serializer =>
          _$tableSettingsInputServiceChargeAppliesToEnumSerializer;

  const TableSettingsInputServiceChargeAppliesToEnum._(String name)
      : super(name);

  static BuiltSet<TableSettingsInputServiceChargeAppliesToEnum> get values =>
      _$tableSettingsInputServiceChargeAppliesToEnumValues;
  static TableSettingsInputServiceChargeAppliesToEnum valueOf(String name) =>
      _$tableSettingsInputServiceChargeAppliesToEnumValueOf(name);
}
