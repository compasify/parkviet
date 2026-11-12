// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceSummary extends WorkspaceSummary {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final int revision;
  @override
  final String operationalStatus;
  @override
  final String serviceMode;
  @override
  final Date businessDate;
  @override
  final int? orderNumber;
  @override
  final String? guestName;
  @override
  final String? tabName;
  @override
  final String? vehicleVisitId;
  @override
  final ResourceRef? resource;
  @override
  final DateTime? openedAt;
  @override
  final String total;

  factory _$WorkspaceSummary(
          [void Function(WorkspaceSummaryBuilder)? updates]) =>
      (WorkspaceSummaryBuilder()..update(updates))._build();

  _$WorkspaceSummary._(
      {required this.id,
      required this.branchId,
      required this.revision,
      required this.operationalStatus,
      required this.serviceMode,
      required this.businessDate,
      this.orderNumber,
      this.guestName,
      this.tabName,
      this.vehicleVisitId,
      this.resource,
      this.openedAt,
      required this.total})
      : super._();
  @override
  WorkspaceSummary rebuild(void Function(WorkspaceSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceSummaryBuilder toBuilder() =>
      WorkspaceSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceSummary &&
        id == other.id &&
        branchId == other.branchId &&
        revision == other.revision &&
        operationalStatus == other.operationalStatus &&
        serviceMode == other.serviceMode &&
        businessDate == other.businessDate &&
        orderNumber == other.orderNumber &&
        guestName == other.guestName &&
        tabName == other.tabName &&
        vehicleVisitId == other.vehicleVisitId &&
        resource == other.resource &&
        openedAt == other.openedAt &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, operationalStatus.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, orderNumber.hashCode);
    _$hash = $jc(_$hash, guestName.hashCode);
    _$hash = $jc(_$hash, tabName.hashCode);
    _$hash = $jc(_$hash, vehicleVisitId.hashCode);
    _$hash = $jc(_$hash, resource.hashCode);
    _$hash = $jc(_$hash, openedAt.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceSummary')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('revision', revision)
          ..add('operationalStatus', operationalStatus)
          ..add('serviceMode', serviceMode)
          ..add('businessDate', businessDate)
          ..add('orderNumber', orderNumber)
          ..add('guestName', guestName)
          ..add('tabName', tabName)
          ..add('vehicleVisitId', vehicleVisitId)
          ..add('resource', resource)
          ..add('openedAt', openedAt)
          ..add('total', total))
        .toString();
  }
}

class WorkspaceSummaryBuilder
    implements Builder<WorkspaceSummary, WorkspaceSummaryBuilder> {
  _$WorkspaceSummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  String? _operationalStatus;
  String? get operationalStatus => _$this._operationalStatus;
  set operationalStatus(String? operationalStatus) =>
      _$this._operationalStatus = operationalStatus;

  String? _serviceMode;
  String? get serviceMode => _$this._serviceMode;
  set serviceMode(String? serviceMode) => _$this._serviceMode = serviceMode;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  int? _orderNumber;
  int? get orderNumber => _$this._orderNumber;
  set orderNumber(int? orderNumber) => _$this._orderNumber = orderNumber;

  String? _guestName;
  String? get guestName => _$this._guestName;
  set guestName(String? guestName) => _$this._guestName = guestName;

  String? _tabName;
  String? get tabName => _$this._tabName;
  set tabName(String? tabName) => _$this._tabName = tabName;

  String? _vehicleVisitId;
  String? get vehicleVisitId => _$this._vehicleVisitId;
  set vehicleVisitId(String? vehicleVisitId) =>
      _$this._vehicleVisitId = vehicleVisitId;

  ResourceRefBuilder? _resource;
  ResourceRefBuilder get resource => _$this._resource ??= ResourceRefBuilder();
  set resource(ResourceRefBuilder? resource) => _$this._resource = resource;

  DateTime? _openedAt;
  DateTime? get openedAt => _$this._openedAt;
  set openedAt(DateTime? openedAt) => _$this._openedAt = openedAt;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  WorkspaceSummaryBuilder() {
    WorkspaceSummary._defaults(this);
  }

  WorkspaceSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _revision = $v.revision;
      _operationalStatus = $v.operationalStatus;
      _serviceMode = $v.serviceMode;
      _businessDate = $v.businessDate;
      _orderNumber = $v.orderNumber;
      _guestName = $v.guestName;
      _tabName = $v.tabName;
      _vehicleVisitId = $v.vehicleVisitId;
      _resource = $v.resource?.toBuilder();
      _openedAt = $v.openedAt;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceSummary other) {
    _$v = other as _$WorkspaceSummary;
  }

  @override
  void update(void Function(WorkspaceSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceSummary build() => _build();

  _$WorkspaceSummary _build() {
    _$WorkspaceSummary _$result;
    try {
      _$result = _$v ??
          _$WorkspaceSummary._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'WorkspaceSummary', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'WorkspaceSummary', 'branchId'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'WorkspaceSummary', 'revision'),
            operationalStatus: BuiltValueNullFieldError.checkNotNull(
                operationalStatus, r'WorkspaceSummary', 'operationalStatus'),
            serviceMode: BuiltValueNullFieldError.checkNotNull(
                serviceMode, r'WorkspaceSummary', 'serviceMode'),
            businessDate: BuiltValueNullFieldError.checkNotNull(
                businessDate, r'WorkspaceSummary', 'businessDate'),
            orderNumber: orderNumber,
            guestName: guestName,
            tabName: tabName,
            vehicleVisitId: vehicleVisitId,
            resource: _resource?.build(),
            openedAt: openedAt,
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'WorkspaceSummary', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'resource';
        _resource?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkspaceSummary', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
