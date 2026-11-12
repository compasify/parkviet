// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TableSettingsQrOrderModeEnum
    _$tableSettingsQrOrderModeEnum_staffApproval =
    const TableSettingsQrOrderModeEnum._('staffApproval');
const TableSettingsQrOrderModeEnum
    _$tableSettingsQrOrderModeEnum_directToKitchen =
    const TableSettingsQrOrderModeEnum._('directToKitchen');

TableSettingsQrOrderModeEnum _$tableSettingsQrOrderModeEnumValueOf(
    String name) {
  switch (name) {
    case 'staffApproval':
      return _$tableSettingsQrOrderModeEnum_staffApproval;
    case 'directToKitchen':
      return _$tableSettingsQrOrderModeEnum_directToKitchen;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TableSettingsQrOrderModeEnum>
    _$tableSettingsQrOrderModeEnumValues =
    BuiltSet<TableSettingsQrOrderModeEnum>(const <TableSettingsQrOrderModeEnum>[
  _$tableSettingsQrOrderModeEnum_staffApproval,
  _$tableSettingsQrOrderModeEnum_directToKitchen,
]);

const TableSettingsServiceChargeAppliesToEnum
    _$tableSettingsServiceChargeAppliesToEnum_counter =
    const TableSettingsServiceChargeAppliesToEnum._('counter');
const TableSettingsServiceChargeAppliesToEnum
    _$tableSettingsServiceChargeAppliesToEnum_dineIn =
    const TableSettingsServiceChargeAppliesToEnum._('dineIn');
const TableSettingsServiceChargeAppliesToEnum
    _$tableSettingsServiceChargeAppliesToEnum_takeaway =
    const TableSettingsServiceChargeAppliesToEnum._('takeaway');
const TableSettingsServiceChargeAppliesToEnum
    _$tableSettingsServiceChargeAppliesToEnum_delivery =
    const TableSettingsServiceChargeAppliesToEnum._('delivery');
const TableSettingsServiceChargeAppliesToEnum
    _$tableSettingsServiceChargeAppliesToEnum_tab =
    const TableSettingsServiceChargeAppliesToEnum._('tab');
const TableSettingsServiceChargeAppliesToEnum
    _$tableSettingsServiceChargeAppliesToEnum_timed =
    const TableSettingsServiceChargeAppliesToEnum._('timed');

TableSettingsServiceChargeAppliesToEnum
    _$tableSettingsServiceChargeAppliesToEnumValueOf(String name) {
  switch (name) {
    case 'counter':
      return _$tableSettingsServiceChargeAppliesToEnum_counter;
    case 'dineIn':
      return _$tableSettingsServiceChargeAppliesToEnum_dineIn;
    case 'takeaway':
      return _$tableSettingsServiceChargeAppliesToEnum_takeaway;
    case 'delivery':
      return _$tableSettingsServiceChargeAppliesToEnum_delivery;
    case 'tab':
      return _$tableSettingsServiceChargeAppliesToEnum_tab;
    case 'timed':
      return _$tableSettingsServiceChargeAppliesToEnum_timed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TableSettingsServiceChargeAppliesToEnum>
    _$tableSettingsServiceChargeAppliesToEnumValues = BuiltSet<
        TableSettingsServiceChargeAppliesToEnum>(const <TableSettingsServiceChargeAppliesToEnum>[
  _$tableSettingsServiceChargeAppliesToEnum_counter,
  _$tableSettingsServiceChargeAppliesToEnum_dineIn,
  _$tableSettingsServiceChargeAppliesToEnum_takeaway,
  _$tableSettingsServiceChargeAppliesToEnum_delivery,
  _$tableSettingsServiceChargeAppliesToEnum_tab,
  _$tableSettingsServiceChargeAppliesToEnum_timed,
]);

Serializer<TableSettingsQrOrderModeEnum>
    _$tableSettingsQrOrderModeEnumSerializer =
    _$TableSettingsQrOrderModeEnumSerializer();
Serializer<TableSettingsServiceChargeAppliesToEnum>
    _$tableSettingsServiceChargeAppliesToEnumSerializer =
    _$TableSettingsServiceChargeAppliesToEnumSerializer();

class _$TableSettingsQrOrderModeEnumSerializer
    implements PrimitiveSerializer<TableSettingsQrOrderModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'staffApproval': 'staff_approval',
    'directToKitchen': 'direct_to_kitchen',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'staff_approval': 'staffApproval',
    'direct_to_kitchen': 'directToKitchen',
  };

  @override
  final Iterable<Type> types = const <Type>[TableSettingsQrOrderModeEnum];
  @override
  final String wireName = 'TableSettingsQrOrderModeEnum';

  @override
  Object serialize(Serializers serializers, TableSettingsQrOrderModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TableSettingsQrOrderModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TableSettingsQrOrderModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TableSettingsServiceChargeAppliesToEnumSerializer
    implements PrimitiveSerializer<TableSettingsServiceChargeAppliesToEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'counter': 'counter',
    'dineIn': 'dine_in',
    'takeaway': 'takeaway',
    'delivery': 'delivery',
    'tab': 'tab',
    'timed': 'timed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'counter': 'counter',
    'dine_in': 'dineIn',
    'takeaway': 'takeaway',
    'delivery': 'delivery',
    'tab': 'tab',
    'timed': 'timed',
  };

  @override
  final Iterable<Type> types = const <Type>[
    TableSettingsServiceChargeAppliesToEnum
  ];
  @override
  final String wireName = 'TableSettingsServiceChargeAppliesToEnum';

  @override
  Object serialize(Serializers serializers,
          TableSettingsServiceChargeAppliesToEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TableSettingsServiceChargeAppliesToEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TableSettingsServiceChargeAppliesToEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TableSettings extends TableSettings {
  @override
  final int reservationGraceMinutes;
  @override
  final int reservationDurationMinutes;
  @override
  final String? reservationFeeProductId;
  @override
  final BuiltList<CourseLabel> courseLabels;
  @override
  final int? bottleKeepDays;
  @override
  final bool? tipsAsRevenue;
  @override
  final TableSettingsQrOrderModeEnum? qrOrderMode;
  @override
  final String? qrOrderAutoLimit;
  @override
  final int? qrOrderAutoMaxItems;
  @override
  final TipSplitRule? tipSplit;
  @override
  final String branchId;
  @override
  final String? tableRegisterId;
  @override
  final String? serviceChargeRate;
  @override
  final BuiltList<TableSettingsServiceChargeAppliesToEnum>
      serviceChargeAppliesTo;
  @override
  final String? serviceChargeTaxCategoryId;
  @override
  final BuiltList<TableTaxCategory> taxCategories;

  factory _$TableSettings([void Function(TableSettingsBuilder)? updates]) =>
      (TableSettingsBuilder()..update(updates))._build();

  _$TableSettings._(
      {required this.reservationGraceMinutes,
      required this.reservationDurationMinutes,
      this.reservationFeeProductId,
      required this.courseLabels,
      this.bottleKeepDays,
      this.tipsAsRevenue,
      this.qrOrderMode,
      this.qrOrderAutoLimit,
      this.qrOrderAutoMaxItems,
      this.tipSplit,
      required this.branchId,
      this.tableRegisterId,
      this.serviceChargeRate,
      required this.serviceChargeAppliesTo,
      this.serviceChargeTaxCategoryId,
      required this.taxCategories})
      : super._();
  @override
  TableSettings rebuild(void Function(TableSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableSettingsBuilder toBuilder() => TableSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableSettings &&
        reservationGraceMinutes == other.reservationGraceMinutes &&
        reservationDurationMinutes == other.reservationDurationMinutes &&
        reservationFeeProductId == other.reservationFeeProductId &&
        courseLabels == other.courseLabels &&
        bottleKeepDays == other.bottleKeepDays &&
        tipsAsRevenue == other.tipsAsRevenue &&
        qrOrderMode == other.qrOrderMode &&
        qrOrderAutoLimit == other.qrOrderAutoLimit &&
        qrOrderAutoMaxItems == other.qrOrderAutoMaxItems &&
        tipSplit == other.tipSplit &&
        branchId == other.branchId &&
        tableRegisterId == other.tableRegisterId &&
        serviceChargeRate == other.serviceChargeRate &&
        serviceChargeAppliesTo == other.serviceChargeAppliesTo &&
        serviceChargeTaxCategoryId == other.serviceChargeTaxCategoryId &&
        taxCategories == other.taxCategories;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservationGraceMinutes.hashCode);
    _$hash = $jc(_$hash, reservationDurationMinutes.hashCode);
    _$hash = $jc(_$hash, reservationFeeProductId.hashCode);
    _$hash = $jc(_$hash, courseLabels.hashCode);
    _$hash = $jc(_$hash, bottleKeepDays.hashCode);
    _$hash = $jc(_$hash, tipsAsRevenue.hashCode);
    _$hash = $jc(_$hash, qrOrderMode.hashCode);
    _$hash = $jc(_$hash, qrOrderAutoLimit.hashCode);
    _$hash = $jc(_$hash, qrOrderAutoMaxItems.hashCode);
    _$hash = $jc(_$hash, tipSplit.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, tableRegisterId.hashCode);
    _$hash = $jc(_$hash, serviceChargeRate.hashCode);
    _$hash = $jc(_$hash, serviceChargeAppliesTo.hashCode);
    _$hash = $jc(_$hash, serviceChargeTaxCategoryId.hashCode);
    _$hash = $jc(_$hash, taxCategories.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableSettings')
          ..add('reservationGraceMinutes', reservationGraceMinutes)
          ..add('reservationDurationMinutes', reservationDurationMinutes)
          ..add('reservationFeeProductId', reservationFeeProductId)
          ..add('courseLabels', courseLabels)
          ..add('bottleKeepDays', bottleKeepDays)
          ..add('tipsAsRevenue', tipsAsRevenue)
          ..add('qrOrderMode', qrOrderMode)
          ..add('qrOrderAutoLimit', qrOrderAutoLimit)
          ..add('qrOrderAutoMaxItems', qrOrderAutoMaxItems)
          ..add('tipSplit', tipSplit)
          ..add('branchId', branchId)
          ..add('tableRegisterId', tableRegisterId)
          ..add('serviceChargeRate', serviceChargeRate)
          ..add('serviceChargeAppliesTo', serviceChargeAppliesTo)
          ..add('serviceChargeTaxCategoryId', serviceChargeTaxCategoryId)
          ..add('taxCategories', taxCategories))
        .toString();
  }
}

class TableSettingsBuilder
    implements Builder<TableSettings, TableSettingsBuilder> {
  _$TableSettings? _$v;

  int? _reservationGraceMinutes;
  int? get reservationGraceMinutes => _$this._reservationGraceMinutes;
  set reservationGraceMinutes(int? reservationGraceMinutes) =>
      _$this._reservationGraceMinutes = reservationGraceMinutes;

  int? _reservationDurationMinutes;
  int? get reservationDurationMinutes => _$this._reservationDurationMinutes;
  set reservationDurationMinutes(int? reservationDurationMinutes) =>
      _$this._reservationDurationMinutes = reservationDurationMinutes;

  String? _reservationFeeProductId;
  String? get reservationFeeProductId => _$this._reservationFeeProductId;
  set reservationFeeProductId(String? reservationFeeProductId) =>
      _$this._reservationFeeProductId = reservationFeeProductId;

  ListBuilder<CourseLabel>? _courseLabels;
  ListBuilder<CourseLabel> get courseLabels =>
      _$this._courseLabels ??= ListBuilder<CourseLabel>();
  set courseLabels(ListBuilder<CourseLabel>? courseLabels) =>
      _$this._courseLabels = courseLabels;

  int? _bottleKeepDays;
  int? get bottleKeepDays => _$this._bottleKeepDays;
  set bottleKeepDays(int? bottleKeepDays) =>
      _$this._bottleKeepDays = bottleKeepDays;

  bool? _tipsAsRevenue;
  bool? get tipsAsRevenue => _$this._tipsAsRevenue;
  set tipsAsRevenue(bool? tipsAsRevenue) =>
      _$this._tipsAsRevenue = tipsAsRevenue;

  TableSettingsQrOrderModeEnum? _qrOrderMode;
  TableSettingsQrOrderModeEnum? get qrOrderMode => _$this._qrOrderMode;
  set qrOrderMode(TableSettingsQrOrderModeEnum? qrOrderMode) =>
      _$this._qrOrderMode = qrOrderMode;

  String? _qrOrderAutoLimit;
  String? get qrOrderAutoLimit => _$this._qrOrderAutoLimit;
  set qrOrderAutoLimit(String? qrOrderAutoLimit) =>
      _$this._qrOrderAutoLimit = qrOrderAutoLimit;

  int? _qrOrderAutoMaxItems;
  int? get qrOrderAutoMaxItems => _$this._qrOrderAutoMaxItems;
  set qrOrderAutoMaxItems(int? qrOrderAutoMaxItems) =>
      _$this._qrOrderAutoMaxItems = qrOrderAutoMaxItems;

  TipSplitRuleBuilder? _tipSplit;
  TipSplitRuleBuilder get tipSplit =>
      _$this._tipSplit ??= TipSplitRuleBuilder();
  set tipSplit(TipSplitRuleBuilder? tipSplit) => _$this._tipSplit = tipSplit;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _tableRegisterId;
  String? get tableRegisterId => _$this._tableRegisterId;
  set tableRegisterId(String? tableRegisterId) =>
      _$this._tableRegisterId = tableRegisterId;

  String? _serviceChargeRate;
  String? get serviceChargeRate => _$this._serviceChargeRate;
  set serviceChargeRate(String? serviceChargeRate) =>
      _$this._serviceChargeRate = serviceChargeRate;

  ListBuilder<TableSettingsServiceChargeAppliesToEnum>? _serviceChargeAppliesTo;
  ListBuilder<TableSettingsServiceChargeAppliesToEnum>
      get serviceChargeAppliesTo => _$this._serviceChargeAppliesTo ??=
          ListBuilder<TableSettingsServiceChargeAppliesToEnum>();
  set serviceChargeAppliesTo(
          ListBuilder<TableSettingsServiceChargeAppliesToEnum>?
              serviceChargeAppliesTo) =>
      _$this._serviceChargeAppliesTo = serviceChargeAppliesTo;

  String? _serviceChargeTaxCategoryId;
  String? get serviceChargeTaxCategoryId => _$this._serviceChargeTaxCategoryId;
  set serviceChargeTaxCategoryId(String? serviceChargeTaxCategoryId) =>
      _$this._serviceChargeTaxCategoryId = serviceChargeTaxCategoryId;

  ListBuilder<TableTaxCategory>? _taxCategories;
  ListBuilder<TableTaxCategory> get taxCategories =>
      _$this._taxCategories ??= ListBuilder<TableTaxCategory>();
  set taxCategories(ListBuilder<TableTaxCategory>? taxCategories) =>
      _$this._taxCategories = taxCategories;

  TableSettingsBuilder() {
    TableSettings._defaults(this);
  }

  TableSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservationGraceMinutes = $v.reservationGraceMinutes;
      _reservationDurationMinutes = $v.reservationDurationMinutes;
      _reservationFeeProductId = $v.reservationFeeProductId;
      _courseLabels = $v.courseLabels.toBuilder();
      _bottleKeepDays = $v.bottleKeepDays;
      _tipsAsRevenue = $v.tipsAsRevenue;
      _qrOrderMode = $v.qrOrderMode;
      _qrOrderAutoLimit = $v.qrOrderAutoLimit;
      _qrOrderAutoMaxItems = $v.qrOrderAutoMaxItems;
      _tipSplit = $v.tipSplit?.toBuilder();
      _branchId = $v.branchId;
      _tableRegisterId = $v.tableRegisterId;
      _serviceChargeRate = $v.serviceChargeRate;
      _serviceChargeAppliesTo = $v.serviceChargeAppliesTo.toBuilder();
      _serviceChargeTaxCategoryId = $v.serviceChargeTaxCategoryId;
      _taxCategories = $v.taxCategories.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableSettings other) {
    _$v = other as _$TableSettings;
  }

  @override
  void update(void Function(TableSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableSettings build() => _build();

  _$TableSettings _build() {
    _$TableSettings _$result;
    try {
      _$result = _$v ??
          _$TableSettings._(
            reservationGraceMinutes: BuiltValueNullFieldError.checkNotNull(
                reservationGraceMinutes,
                r'TableSettings',
                'reservationGraceMinutes'),
            reservationDurationMinutes: BuiltValueNullFieldError.checkNotNull(
                reservationDurationMinutes,
                r'TableSettings',
                'reservationDurationMinutes'),
            reservationFeeProductId: reservationFeeProductId,
            courseLabels: courseLabels.build(),
            bottleKeepDays: bottleKeepDays,
            tipsAsRevenue: tipsAsRevenue,
            qrOrderMode: qrOrderMode,
            qrOrderAutoLimit: qrOrderAutoLimit,
            qrOrderAutoMaxItems: qrOrderAutoMaxItems,
            tipSplit: _tipSplit?.build(),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'TableSettings', 'branchId'),
            tableRegisterId: tableRegisterId,
            serviceChargeRate: serviceChargeRate,
            serviceChargeAppliesTo: serviceChargeAppliesTo.build(),
            serviceChargeTaxCategoryId: serviceChargeTaxCategoryId,
            taxCategories: taxCategories.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'courseLabels';
        courseLabels.build();

        _$failedField = 'tipSplit';
        _tipSplit?.build();

        _$failedField = 'serviceChargeAppliesTo';
        serviceChargeAppliesTo.build();

        _$failedField = 'taxCategories';
        taxCategories.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableSettings', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
