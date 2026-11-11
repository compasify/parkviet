// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_settings_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TableSettingsInputServiceChargeAppliesToEnum
    _$tableSettingsInputServiceChargeAppliesToEnum_counter =
    const TableSettingsInputServiceChargeAppliesToEnum._('counter');
const TableSettingsInputServiceChargeAppliesToEnum
    _$tableSettingsInputServiceChargeAppliesToEnum_dineIn =
    const TableSettingsInputServiceChargeAppliesToEnum._('dineIn');
const TableSettingsInputServiceChargeAppliesToEnum
    _$tableSettingsInputServiceChargeAppliesToEnum_takeaway =
    const TableSettingsInputServiceChargeAppliesToEnum._('takeaway');
const TableSettingsInputServiceChargeAppliesToEnum
    _$tableSettingsInputServiceChargeAppliesToEnum_delivery =
    const TableSettingsInputServiceChargeAppliesToEnum._('delivery');
const TableSettingsInputServiceChargeAppliesToEnum
    _$tableSettingsInputServiceChargeAppliesToEnum_tab =
    const TableSettingsInputServiceChargeAppliesToEnum._('tab');
const TableSettingsInputServiceChargeAppliesToEnum
    _$tableSettingsInputServiceChargeAppliesToEnum_timed =
    const TableSettingsInputServiceChargeAppliesToEnum._('timed');

TableSettingsInputServiceChargeAppliesToEnum
    _$tableSettingsInputServiceChargeAppliesToEnumValueOf(String name) {
  switch (name) {
    case 'counter':
      return _$tableSettingsInputServiceChargeAppliesToEnum_counter;
    case 'dineIn':
      return _$tableSettingsInputServiceChargeAppliesToEnum_dineIn;
    case 'takeaway':
      return _$tableSettingsInputServiceChargeAppliesToEnum_takeaway;
    case 'delivery':
      return _$tableSettingsInputServiceChargeAppliesToEnum_delivery;
    case 'tab':
      return _$tableSettingsInputServiceChargeAppliesToEnum_tab;
    case 'timed':
      return _$tableSettingsInputServiceChargeAppliesToEnum_timed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TableSettingsInputServiceChargeAppliesToEnum>
    _$tableSettingsInputServiceChargeAppliesToEnumValues = BuiltSet<
        TableSettingsInputServiceChargeAppliesToEnum>(const <TableSettingsInputServiceChargeAppliesToEnum>[
  _$tableSettingsInputServiceChargeAppliesToEnum_counter,
  _$tableSettingsInputServiceChargeAppliesToEnum_dineIn,
  _$tableSettingsInputServiceChargeAppliesToEnum_takeaway,
  _$tableSettingsInputServiceChargeAppliesToEnum_delivery,
  _$tableSettingsInputServiceChargeAppliesToEnum_tab,
  _$tableSettingsInputServiceChargeAppliesToEnum_timed,
]);

Serializer<TableSettingsInputServiceChargeAppliesToEnum>
    _$tableSettingsInputServiceChargeAppliesToEnumSerializer =
    _$TableSettingsInputServiceChargeAppliesToEnumSerializer();

class _$TableSettingsInputServiceChargeAppliesToEnumSerializer
    implements
        PrimitiveSerializer<TableSettingsInputServiceChargeAppliesToEnum> {
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
    TableSettingsInputServiceChargeAppliesToEnum
  ];
  @override
  final String wireName = 'TableSettingsInputServiceChargeAppliesToEnum';

  @override
  Object serialize(Serializers serializers,
          TableSettingsInputServiceChargeAppliesToEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TableSettingsInputServiceChargeAppliesToEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TableSettingsInputServiceChargeAppliesToEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TableSettingsInput extends TableSettingsInput {
  @override
  final String branchId;
  @override
  final String? tableRegisterId;
  @override
  final String? serviceChargeRate;
  @override
  final BuiltList<TableSettingsInputServiceChargeAppliesToEnum>?
      serviceChargeAppliesTo;
  @override
  final String? serviceChargeTaxCategoryId;
  @override
  final int? reservationGraceMinutes;
  @override
  final int? reservationDurationMinutes;
  @override
  final String? reservationFeeProductId;
  @override
  final BuiltList<TableSettingsInputCourseLabelsInner>? courseLabels;

  factory _$TableSettingsInput(
          [void Function(TableSettingsInputBuilder)? updates]) =>
      (TableSettingsInputBuilder()..update(updates))._build();

  _$TableSettingsInput._(
      {required this.branchId,
      this.tableRegisterId,
      this.serviceChargeRate,
      this.serviceChargeAppliesTo,
      this.serviceChargeTaxCategoryId,
      this.reservationGraceMinutes,
      this.reservationDurationMinutes,
      this.reservationFeeProductId,
      this.courseLabels})
      : super._();
  @override
  TableSettingsInput rebuild(
          void Function(TableSettingsInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableSettingsInputBuilder toBuilder() =>
      TableSettingsInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableSettingsInput &&
        branchId == other.branchId &&
        tableRegisterId == other.tableRegisterId &&
        serviceChargeRate == other.serviceChargeRate &&
        serviceChargeAppliesTo == other.serviceChargeAppliesTo &&
        serviceChargeTaxCategoryId == other.serviceChargeTaxCategoryId &&
        reservationGraceMinutes == other.reservationGraceMinutes &&
        reservationDurationMinutes == other.reservationDurationMinutes &&
        reservationFeeProductId == other.reservationFeeProductId &&
        courseLabels == other.courseLabels;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, tableRegisterId.hashCode);
    _$hash = $jc(_$hash, serviceChargeRate.hashCode);
    _$hash = $jc(_$hash, serviceChargeAppliesTo.hashCode);
    _$hash = $jc(_$hash, serviceChargeTaxCategoryId.hashCode);
    _$hash = $jc(_$hash, reservationGraceMinutes.hashCode);
    _$hash = $jc(_$hash, reservationDurationMinutes.hashCode);
    _$hash = $jc(_$hash, reservationFeeProductId.hashCode);
    _$hash = $jc(_$hash, courseLabels.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableSettingsInput')
          ..add('branchId', branchId)
          ..add('tableRegisterId', tableRegisterId)
          ..add('serviceChargeRate', serviceChargeRate)
          ..add('serviceChargeAppliesTo', serviceChargeAppliesTo)
          ..add('serviceChargeTaxCategoryId', serviceChargeTaxCategoryId)
          ..add('reservationGraceMinutes', reservationGraceMinutes)
          ..add('reservationDurationMinutes', reservationDurationMinutes)
          ..add('reservationFeeProductId', reservationFeeProductId)
          ..add('courseLabels', courseLabels))
        .toString();
  }
}

class TableSettingsInputBuilder
    implements Builder<TableSettingsInput, TableSettingsInputBuilder> {
  _$TableSettingsInput? _$v;

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

  ListBuilder<TableSettingsInputServiceChargeAppliesToEnum>?
      _serviceChargeAppliesTo;
  ListBuilder<TableSettingsInputServiceChargeAppliesToEnum>
      get serviceChargeAppliesTo => _$this._serviceChargeAppliesTo ??=
          ListBuilder<TableSettingsInputServiceChargeAppliesToEnum>();
  set serviceChargeAppliesTo(
          ListBuilder<TableSettingsInputServiceChargeAppliesToEnum>?
              serviceChargeAppliesTo) =>
      _$this._serviceChargeAppliesTo = serviceChargeAppliesTo;

  String? _serviceChargeTaxCategoryId;
  String? get serviceChargeTaxCategoryId => _$this._serviceChargeTaxCategoryId;
  set serviceChargeTaxCategoryId(String? serviceChargeTaxCategoryId) =>
      _$this._serviceChargeTaxCategoryId = serviceChargeTaxCategoryId;

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

  ListBuilder<TableSettingsInputCourseLabelsInner>? _courseLabels;
  ListBuilder<TableSettingsInputCourseLabelsInner> get courseLabels =>
      _$this._courseLabels ??=
          ListBuilder<TableSettingsInputCourseLabelsInner>();
  set courseLabels(
          ListBuilder<TableSettingsInputCourseLabelsInner>? courseLabels) =>
      _$this._courseLabels = courseLabels;

  TableSettingsInputBuilder() {
    TableSettingsInput._defaults(this);
  }

  TableSettingsInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _tableRegisterId = $v.tableRegisterId;
      _serviceChargeRate = $v.serviceChargeRate;
      _serviceChargeAppliesTo = $v.serviceChargeAppliesTo?.toBuilder();
      _serviceChargeTaxCategoryId = $v.serviceChargeTaxCategoryId;
      _reservationGraceMinutes = $v.reservationGraceMinutes;
      _reservationDurationMinutes = $v.reservationDurationMinutes;
      _reservationFeeProductId = $v.reservationFeeProductId;
      _courseLabels = $v.courseLabels?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableSettingsInput other) {
    _$v = other as _$TableSettingsInput;
  }

  @override
  void update(void Function(TableSettingsInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableSettingsInput build() => _build();

  _$TableSettingsInput _build() {
    _$TableSettingsInput _$result;
    try {
      _$result = _$v ??
          _$TableSettingsInput._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'TableSettingsInput', 'branchId'),
            tableRegisterId: tableRegisterId,
            serviceChargeRate: serviceChargeRate,
            serviceChargeAppliesTo: _serviceChargeAppliesTo?.build(),
            serviceChargeTaxCategoryId: serviceChargeTaxCategoryId,
            reservationGraceMinutes: reservationGraceMinutes,
            reservationDurationMinutes: reservationDurationMinutes,
            reservationFeeProductId: reservationFeeProductId,
            courseLabels: _courseLabels?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'serviceChargeAppliesTo';
        _serviceChargeAppliesTo?.build();

        _$failedField = 'courseLabels';
        _courseLabels?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableSettingsInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
