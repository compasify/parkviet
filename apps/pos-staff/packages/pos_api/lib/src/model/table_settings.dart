//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_settings.g.dart';

/// TableSettings
///
/// Properties:
/// * [branchId]
/// * [tableRegisterId] - The register whose open shift table orders are booked on.
/// * [serviceChargeRate] - Percent of the items after discounts; none when null.
/// * [serviceChargeAppliesTo]
/// * [serviceChargeTaxCategoryId]
@BuiltValue()
abstract class TableSettings
    implements Built<TableSettings, TableSettingsBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  /// The register whose open shift table orders are booked on.
  @BuiltValueField(wireName: r'table_register_id')
  String? get tableRegisterId;

  /// Percent of the items after discounts; none when null.
  @BuiltValueField(wireName: r'service_charge_rate')
  String? get serviceChargeRate;

  @BuiltValueField(wireName: r'service_charge_applies_to')
  BuiltList<TableSettingsServiceChargeAppliesToEnum> get serviceChargeAppliesTo;
  // enum serviceChargeAppliesToEnum {  counter,  dine_in,  takeaway,  delivery,  tab,  timed,  };

  @BuiltValueField(wireName: r'service_charge_tax_category_id')
  String? get serviceChargeTaxCategoryId;

  TableSettings._();

  factory TableSettings([void updates(TableSettingsBuilder b)]) =
      _$TableSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableSettings> get serializer =>
      _$TableSettingsSerializer();
}

class _$TableSettingsSerializer implements PrimitiveSerializer<TableSettings> {
  @override
  final Iterable<Type> types = const [TableSettings, _$TableSettings];

  @override
  final String wireName = r'TableSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'table_register_id';
    yield object.tableRegisterId == null
        ? null
        : serializers.serialize(
            object.tableRegisterId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'service_charge_rate';
    yield object.serviceChargeRate == null
        ? null
        : serializers.serialize(
            object.serviceChargeRate,
            specifiedType: const FullType.nullable(String),
          );
    yield r'service_charge_applies_to';
    yield serializers.serialize(
      object.serviceChargeAppliesTo,
      specifiedType: const FullType(
          BuiltList, [FullType(TableSettingsServiceChargeAppliesToEnum)]),
    );
    yield r'service_charge_tax_category_id';
    yield object.serviceChargeTaxCategoryId == null
        ? null
        : serializers.serialize(
            object.serviceChargeTaxCategoryId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    TableSettings object, {
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
    required TableSettingsBuilder result,
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
            specifiedType: const FullType(
                BuiltList, [FullType(TableSettingsServiceChargeAppliesToEnum)]),
          ) as BuiltList<TableSettingsServiceChargeAppliesToEnum>;
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
  TableSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableSettingsBuilder();
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

class TableSettingsServiceChargeAppliesToEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'counter')
  static const TableSettingsServiceChargeAppliesToEnum counter =
      _$tableSettingsServiceChargeAppliesToEnum_counter;
  @BuiltValueEnumConst(wireName: r'dine_in')
  static const TableSettingsServiceChargeAppliesToEnum dineIn =
      _$tableSettingsServiceChargeAppliesToEnum_dineIn;
  @BuiltValueEnumConst(wireName: r'takeaway')
  static const TableSettingsServiceChargeAppliesToEnum takeaway =
      _$tableSettingsServiceChargeAppliesToEnum_takeaway;
  @BuiltValueEnumConst(wireName: r'delivery')
  static const TableSettingsServiceChargeAppliesToEnum delivery =
      _$tableSettingsServiceChargeAppliesToEnum_delivery;
  @BuiltValueEnumConst(wireName: r'tab')
  static const TableSettingsServiceChargeAppliesToEnum tab =
      _$tableSettingsServiceChargeAppliesToEnum_tab;
  @BuiltValueEnumConst(wireName: r'timed')
  static const TableSettingsServiceChargeAppliesToEnum timed =
      _$tableSettingsServiceChargeAppliesToEnum_timed;

  static Serializer<TableSettingsServiceChargeAppliesToEnum> get serializer =>
      _$tableSettingsServiceChargeAppliesToEnumSerializer;

  const TableSettingsServiceChargeAppliesToEnum._(String name) : super(name);

  static BuiltSet<TableSettingsServiceChargeAppliesToEnum> get values =>
      _$tableSettingsServiceChargeAppliesToEnumValues;
  static TableSettingsServiceChargeAppliesToEnum valueOf(String name) =>
      _$tableSettingsServiceChargeAppliesToEnumValueOf(name);
}
