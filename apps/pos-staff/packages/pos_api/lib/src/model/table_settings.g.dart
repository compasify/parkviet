// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

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

Serializer<TableSettingsServiceChargeAppliesToEnum>
    _$tableSettingsServiceChargeAppliesToEnumSerializer =
    _$TableSettingsServiceChargeAppliesToEnumSerializer();

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
      {required this.branchId,
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
