// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkspaceServiceModeEnum _$workspaceServiceModeEnum_counter =
    const WorkspaceServiceModeEnum._('counter');
const WorkspaceServiceModeEnum _$workspaceServiceModeEnum_dineIn =
    const WorkspaceServiceModeEnum._('dineIn');
const WorkspaceServiceModeEnum _$workspaceServiceModeEnum_takeaway =
    const WorkspaceServiceModeEnum._('takeaway');
const WorkspaceServiceModeEnum _$workspaceServiceModeEnum_delivery =
    const WorkspaceServiceModeEnum._('delivery');
const WorkspaceServiceModeEnum _$workspaceServiceModeEnum_tab =
    const WorkspaceServiceModeEnum._('tab');
const WorkspaceServiceModeEnum _$workspaceServiceModeEnum_timed =
    const WorkspaceServiceModeEnum._('timed');

WorkspaceServiceModeEnum _$workspaceServiceModeEnumValueOf(String name) {
  switch (name) {
    case 'counter':
      return _$workspaceServiceModeEnum_counter;
    case 'dineIn':
      return _$workspaceServiceModeEnum_dineIn;
    case 'takeaway':
      return _$workspaceServiceModeEnum_takeaway;
    case 'delivery':
      return _$workspaceServiceModeEnum_delivery;
    case 'tab':
      return _$workspaceServiceModeEnum_tab;
    case 'timed':
      return _$workspaceServiceModeEnum_timed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkspaceServiceModeEnum> _$workspaceServiceModeEnumValues =
    BuiltSet<WorkspaceServiceModeEnum>(const <WorkspaceServiceModeEnum>[
  _$workspaceServiceModeEnum_counter,
  _$workspaceServiceModeEnum_dineIn,
  _$workspaceServiceModeEnum_takeaway,
  _$workspaceServiceModeEnum_delivery,
  _$workspaceServiceModeEnum_tab,
  _$workspaceServiceModeEnum_timed,
]);

Serializer<WorkspaceServiceModeEnum> _$workspaceServiceModeEnumSerializer =
    _$WorkspaceServiceModeEnumSerializer();

class _$WorkspaceServiceModeEnumSerializer
    implements PrimitiveSerializer<WorkspaceServiceModeEnum> {
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
  final Iterable<Type> types = const <Type>[WorkspaceServiceModeEnum];
  @override
  final String wireName = 'WorkspaceServiceModeEnum';

  @override
  Object serialize(Serializers serializers, WorkspaceServiceModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkspaceServiceModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkspaceServiceModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Workspace extends Workspace {
  @override
  final String id;
  @override
  final int revision;
  @override
  final String operationalStatus;
  @override
  final WorkspaceServiceModeEnum serviceMode;
  @override
  final Date businessDate;
  @override
  final int? orderNumber;
  @override
  final String? guestName;
  @override
  final BuiltList<WorkspaceLine>? lineItems;
  @override
  final WorkspaceTotals totals;

  factory _$Workspace([void Function(WorkspaceBuilder)? updates]) =>
      (WorkspaceBuilder()..update(updates))._build();

  _$Workspace._(
      {required this.id,
      required this.revision,
      required this.operationalStatus,
      required this.serviceMode,
      required this.businessDate,
      this.orderNumber,
      this.guestName,
      this.lineItems,
      required this.totals})
      : super._();
  @override
  Workspace rebuild(void Function(WorkspaceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceBuilder toBuilder() => WorkspaceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Workspace &&
        id == other.id &&
        revision == other.revision &&
        operationalStatus == other.operationalStatus &&
        serviceMode == other.serviceMode &&
        businessDate == other.businessDate &&
        orderNumber == other.orderNumber &&
        guestName == other.guestName &&
        lineItems == other.lineItems &&
        totals == other.totals;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, operationalStatus.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, orderNumber.hashCode);
    _$hash = $jc(_$hash, guestName.hashCode);
    _$hash = $jc(_$hash, lineItems.hashCode);
    _$hash = $jc(_$hash, totals.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Workspace')
          ..add('id', id)
          ..add('revision', revision)
          ..add('operationalStatus', operationalStatus)
          ..add('serviceMode', serviceMode)
          ..add('businessDate', businessDate)
          ..add('orderNumber', orderNumber)
          ..add('guestName', guestName)
          ..add('lineItems', lineItems)
          ..add('totals', totals))
        .toString();
  }
}

class WorkspaceBuilder implements Builder<Workspace, WorkspaceBuilder> {
  _$Workspace? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  String? _operationalStatus;
  String? get operationalStatus => _$this._operationalStatus;
  set operationalStatus(String? operationalStatus) =>
      _$this._operationalStatus = operationalStatus;

  WorkspaceServiceModeEnum? _serviceMode;
  WorkspaceServiceModeEnum? get serviceMode => _$this._serviceMode;
  set serviceMode(WorkspaceServiceModeEnum? serviceMode) =>
      _$this._serviceMode = serviceMode;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  int? _orderNumber;
  int? get orderNumber => _$this._orderNumber;
  set orderNumber(int? orderNumber) => _$this._orderNumber = orderNumber;

  String? _guestName;
  String? get guestName => _$this._guestName;
  set guestName(String? guestName) => _$this._guestName = guestName;

  ListBuilder<WorkspaceLine>? _lineItems;
  ListBuilder<WorkspaceLine> get lineItems =>
      _$this._lineItems ??= ListBuilder<WorkspaceLine>();
  set lineItems(ListBuilder<WorkspaceLine>? lineItems) =>
      _$this._lineItems = lineItems;

  WorkspaceTotalsBuilder? _totals;
  WorkspaceTotalsBuilder get totals =>
      _$this._totals ??= WorkspaceTotalsBuilder();
  set totals(WorkspaceTotalsBuilder? totals) => _$this._totals = totals;

  WorkspaceBuilder() {
    Workspace._defaults(this);
  }

  WorkspaceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _revision = $v.revision;
      _operationalStatus = $v.operationalStatus;
      _serviceMode = $v.serviceMode;
      _businessDate = $v.businessDate;
      _orderNumber = $v.orderNumber;
      _guestName = $v.guestName;
      _lineItems = $v.lineItems?.toBuilder();
      _totals = $v.totals.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Workspace other) {
    _$v = other as _$Workspace;
  }

  @override
  void update(void Function(WorkspaceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Workspace build() => _build();

  _$Workspace _build() {
    _$Workspace _$result;
    try {
      _$result = _$v ??
          _$Workspace._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Workspace', 'id'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'Workspace', 'revision'),
            operationalStatus: BuiltValueNullFieldError.checkNotNull(
                operationalStatus, r'Workspace', 'operationalStatus'),
            serviceMode: BuiltValueNullFieldError.checkNotNull(
                serviceMode, r'Workspace', 'serviceMode'),
            businessDate: BuiltValueNullFieldError.checkNotNull(
                businessDate, r'Workspace', 'businessDate'),
            orderNumber: orderNumber,
            guestName: guestName,
            lineItems: _lineItems?.build(),
            totals: totals.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lineItems';
        _lineItems?.build();
        _$failedField = 'totals';
        totals.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Workspace', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
