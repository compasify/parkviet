//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/tip_split_rule.dart';
import 'package:pos_api/src/model/table_tax_category.dart';
import 'package:pos_api/src/model/course_label.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_settings.g.dart';

/// TableSettings
///
/// Properties:
/// * [reservationGraceMinutes] - How long a booking waits past its time before it is a no-show.
/// * [reservationDurationMinutes] - The length of a booking when none is given.
/// * [reservationFeeProductId] - The service sold when a deposit is kept (priced with its tax included).
/// * [courseLabels]
/// * [bottleKeepDays] - How many days a guest's bottle is kept.
/// * [tipsAsRevenue] - Whether the reports count tips as revenue.
/// * [qrOrderMode] - How guests' orders from the table QR are taken.
/// * [qrOrderAutoLimit] - The largest guest order that goes straight to the kitchen.
/// * [qrOrderAutoMaxItems] - The most items a guest order may have to go straight to the kitchen.
/// * [tipSplit]
/// * [branchId]
/// * [tableRegisterId] - The register whose open shift table orders are booked on.
/// * [serviceChargeRate] - Percent of the items after discounts; none when null.
/// * [serviceChargeAppliesTo]
/// * [serviceChargeTaxCategoryId]
/// * [taxCategories] - The store's tax categories, to choose the service charge's.
@BuiltValue()
abstract class TableSettings
    implements Built<TableSettings, TableSettingsBuilder> {
  /// How long a booking waits past its time before it is a no-show.
  @BuiltValueField(wireName: r'reservation_grace_minutes')
  int get reservationGraceMinutes;

  /// The length of a booking when none is given.
  @BuiltValueField(wireName: r'reservation_duration_minutes')
  int get reservationDurationMinutes;

  /// The service sold when a deposit is kept (priced with its tax included).
  @BuiltValueField(wireName: r'reservation_fee_product_id')
  String? get reservationFeeProductId;

  @BuiltValueField(wireName: r'course_labels')
  BuiltList<CourseLabel> get courseLabels;

  /// How many days a guest's bottle is kept.
  @BuiltValueField(wireName: r'bottle_keep_days')
  int? get bottleKeepDays;

  /// Whether the reports count tips as revenue.
  @BuiltValueField(wireName: r'tips_as_revenue')
  bool? get tipsAsRevenue;

  /// How guests' orders from the table QR are taken.
  @BuiltValueField(wireName: r'qr_order_mode')
  TableSettingsQrOrderModeEnum? get qrOrderMode;
  // enum qrOrderModeEnum {  staff_approval,  direct_to_kitchen,  };

  /// The largest guest order that goes straight to the kitchen.
  @BuiltValueField(wireName: r'qr_order_auto_limit')
  String? get qrOrderAutoLimit;

  /// The most items a guest order may have to go straight to the kitchen.
  @BuiltValueField(wireName: r'qr_order_auto_max_items')
  int? get qrOrderAutoMaxItems;

  @BuiltValueField(wireName: r'tip_split')
  TipSplitRule? get tipSplit;

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

  /// The store's tax categories, to choose the service charge's.
  @BuiltValueField(wireName: r'tax_categories')
  BuiltList<TableTaxCategory> get taxCategories;

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
    yield r'reservation_grace_minutes';
    yield serializers.serialize(
      object.reservationGraceMinutes,
      specifiedType: const FullType(int),
    );
    yield r'reservation_duration_minutes';
    yield serializers.serialize(
      object.reservationDurationMinutes,
      specifiedType: const FullType(int),
    );
    yield r'reservation_fee_product_id';
    yield object.reservationFeeProductId == null
        ? null
        : serializers.serialize(
            object.reservationFeeProductId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'course_labels';
    yield serializers.serialize(
      object.courseLabels,
      specifiedType: const FullType(BuiltList, [FullType(CourseLabel)]),
    );
    if (object.bottleKeepDays != null) {
      yield r'bottle_keep_days';
      yield serializers.serialize(
        object.bottleKeepDays,
        specifiedType: const FullType(int),
      );
    }
    if (object.tipsAsRevenue != null) {
      yield r'tips_as_revenue';
      yield serializers.serialize(
        object.tipsAsRevenue,
        specifiedType: const FullType(bool),
      );
    }
    if (object.qrOrderMode != null) {
      yield r'qr_order_mode';
      yield serializers.serialize(
        object.qrOrderMode,
        specifiedType: const FullType(TableSettingsQrOrderModeEnum),
      );
    }
    if (object.qrOrderAutoLimit != null) {
      yield r'qr_order_auto_limit';
      yield serializers.serialize(
        object.qrOrderAutoLimit,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.qrOrderAutoMaxItems != null) {
      yield r'qr_order_auto_max_items';
      yield serializers.serialize(
        object.qrOrderAutoMaxItems,
        specifiedType: const FullType(int),
      );
    }
    if (object.tipSplit != null) {
      yield r'tip_split';
      yield serializers.serialize(
        object.tipSplit,
        specifiedType: const FullType(TipSplitRule),
      );
    }
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
    yield r'tax_categories';
    yield serializers.serialize(
      object.taxCategories,
      specifiedType: const FullType(BuiltList, [FullType(TableTaxCategory)]),
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
        case r'reservation_grace_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.reservationGraceMinutes = valueDes;
          break;
        case r'reservation_duration_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.reservationDurationMinutes = valueDes;
          break;
        case r'reservation_fee_product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reservationFeeProductId = valueDes;
          break;
        case r'course_labels':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CourseLabel)]),
          ) as BuiltList<CourseLabel>;
          result.courseLabels.replace(valueDes);
          break;
        case r'bottle_keep_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.bottleKeepDays = valueDes;
          break;
        case r'tips_as_revenue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.tipsAsRevenue = valueDes;
          break;
        case r'qr_order_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(TableSettingsQrOrderModeEnum),
          ) as TableSettingsQrOrderModeEnum?;
          if (valueDes == null) continue;
          result.qrOrderMode = valueDes;
          break;
        case r'qr_order_auto_limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.qrOrderAutoLimit = valueDes;
          break;
        case r'qr_order_auto_max_items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.qrOrderAutoMaxItems = valueDes;
          break;
        case r'tip_split':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TipSplitRule),
          ) as TipSplitRule?;
          if (valueDes == null) continue;
          result.tipSplit.replace(valueDes);
          break;
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
        case r'tax_categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(TableTaxCategory)]),
          ) as BuiltList<TableTaxCategory>;
          result.taxCategories.replace(valueDes);
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

/// How guests' orders from the table QR are taken.
class TableSettingsQrOrderModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'staff_approval')
  static const TableSettingsQrOrderModeEnum staffApproval =
      _$tableSettingsQrOrderModeEnum_staffApproval;
  @BuiltValueEnumConst(wireName: r'direct_to_kitchen')
  static const TableSettingsQrOrderModeEnum directToKitchen =
      _$tableSettingsQrOrderModeEnum_directToKitchen;

  static Serializer<TableSettingsQrOrderModeEnum> get serializer =>
      _$tableSettingsQrOrderModeEnumSerializer;

  const TableSettingsQrOrderModeEnum._(String name) : super(name);

  static BuiltSet<TableSettingsQrOrderModeEnum> get values =>
      _$tableSettingsQrOrderModeEnumValues;
  static TableSettingsQrOrderModeEnum valueOf(String name) =>
      _$tableSettingsQrOrderModeEnumValueOf(name);
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
