// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RealtimeEventEventEnum _$realtimeEventEventEnum_workspacePeriodUpdated =
    const RealtimeEventEventEnum._('workspacePeriodUpdated');
const RealtimeEventEventEnum
    _$realtimeEventEventEnum_kitchenTicketPeriodUpdated =
    const RealtimeEventEventEnum._('kitchenTicketPeriodUpdated');
const RealtimeEventEventEnum _$realtimeEventEventEnum_menuPeriodSoldOut =
    const RealtimeEventEventEnum._('menuPeriodSoldOut');
const RealtimeEventEventEnum _$realtimeEventEventEnum_paymentPeriodRequested =
    const RealtimeEventEventEnum._('paymentPeriodRequested');
const RealtimeEventEventEnum _$realtimeEventEventEnum_printJobPeriodCreated =
    const RealtimeEventEventEnum._('printJobPeriodCreated');
const RealtimeEventEventEnum _$realtimeEventEventEnum_resourcePeriodUpdated =
    const RealtimeEventEventEnum._('resourcePeriodUpdated');
const RealtimeEventEventEnum _$realtimeEventEventEnum_approvalPeriodRequested =
    const RealtimeEventEventEnum._('approvalPeriodRequested');

RealtimeEventEventEnum _$realtimeEventEventEnumValueOf(String name) {
  switch (name) {
    case 'workspacePeriodUpdated':
      return _$realtimeEventEventEnum_workspacePeriodUpdated;
    case 'kitchenTicketPeriodUpdated':
      return _$realtimeEventEventEnum_kitchenTicketPeriodUpdated;
    case 'menuPeriodSoldOut':
      return _$realtimeEventEventEnum_menuPeriodSoldOut;
    case 'paymentPeriodRequested':
      return _$realtimeEventEventEnum_paymentPeriodRequested;
    case 'printJobPeriodCreated':
      return _$realtimeEventEventEnum_printJobPeriodCreated;
    case 'resourcePeriodUpdated':
      return _$realtimeEventEventEnum_resourcePeriodUpdated;
    case 'approvalPeriodRequested':
      return _$realtimeEventEventEnum_approvalPeriodRequested;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RealtimeEventEventEnum> _$realtimeEventEventEnumValues =
    BuiltSet<RealtimeEventEventEnum>(const <RealtimeEventEventEnum>[
  _$realtimeEventEventEnum_workspacePeriodUpdated,
  _$realtimeEventEventEnum_kitchenTicketPeriodUpdated,
  _$realtimeEventEventEnum_menuPeriodSoldOut,
  _$realtimeEventEventEnum_paymentPeriodRequested,
  _$realtimeEventEventEnum_printJobPeriodCreated,
  _$realtimeEventEventEnum_resourcePeriodUpdated,
  _$realtimeEventEventEnum_approvalPeriodRequested,
]);

const RealtimeEventAlertEnum _$realtimeEventAlertEnum_endingSoon =
    const RealtimeEventAlertEnum._('endingSoon');
const RealtimeEventAlertEnum _$realtimeEventAlertEnum_endedPackage =
    const RealtimeEventAlertEnum._('endedPackage');
const RealtimeEventAlertEnum _$realtimeEventAlertEnum_pauseTooLong =
    const RealtimeEventAlertEnum._('pauseTooLong');

RealtimeEventAlertEnum _$realtimeEventAlertEnumValueOf(String name) {
  switch (name) {
    case 'endingSoon':
      return _$realtimeEventAlertEnum_endingSoon;
    case 'endedPackage':
      return _$realtimeEventAlertEnum_endedPackage;
    case 'pauseTooLong':
      return _$realtimeEventAlertEnum_pauseTooLong;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RealtimeEventAlertEnum> _$realtimeEventAlertEnumValues =
    BuiltSet<RealtimeEventAlertEnum>(const <RealtimeEventAlertEnum>[
  _$realtimeEventAlertEnum_endingSoon,
  _$realtimeEventAlertEnum_endedPackage,
  _$realtimeEventAlertEnum_pauseTooLong,
]);

Serializer<RealtimeEventEventEnum> _$realtimeEventEventEnumSerializer =
    _$RealtimeEventEventEnumSerializer();
Serializer<RealtimeEventAlertEnum> _$realtimeEventAlertEnumSerializer =
    _$RealtimeEventAlertEnumSerializer();

class _$RealtimeEventEventEnumSerializer
    implements PrimitiveSerializer<RealtimeEventEventEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'workspacePeriodUpdated': 'workspace.updated',
    'kitchenTicketPeriodUpdated': 'kitchen_ticket.updated',
    'menuPeriodSoldOut': 'menu.sold_out',
    'paymentPeriodRequested': 'payment.requested',
    'printJobPeriodCreated': 'print_job.created',
    'resourcePeriodUpdated': 'resource.updated',
    'approvalPeriodRequested': 'approval.requested',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'workspace.updated': 'workspacePeriodUpdated',
    'kitchen_ticket.updated': 'kitchenTicketPeriodUpdated',
    'menu.sold_out': 'menuPeriodSoldOut',
    'payment.requested': 'paymentPeriodRequested',
    'print_job.created': 'printJobPeriodCreated',
    'resource.updated': 'resourcePeriodUpdated',
    'approval.requested': 'approvalPeriodRequested',
  };

  @override
  final Iterable<Type> types = const <Type>[RealtimeEventEventEnum];
  @override
  final String wireName = 'RealtimeEventEventEnum';

  @override
  Object serialize(Serializers serializers, RealtimeEventEventEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RealtimeEventEventEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RealtimeEventEventEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RealtimeEventAlertEnumSerializer
    implements PrimitiveSerializer<RealtimeEventAlertEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'endingSoon': 'ending_soon',
    'endedPackage': 'ended_package',
    'pauseTooLong': 'pause_too_long',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ending_soon': 'endingSoon',
    'ended_package': 'endedPackage',
    'pause_too_long': 'pauseTooLong',
  };

  @override
  final Iterable<Type> types = const <Type>[RealtimeEventAlertEnum];
  @override
  final String wireName = 'RealtimeEventAlertEnum';

  @override
  Object serialize(Serializers serializers, RealtimeEventAlertEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RealtimeEventAlertEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RealtimeEventAlertEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RealtimeEvent extends RealtimeEvent {
  @override
  final RealtimeEventEventEnum event;
  @override
  final String id;
  @override
  final String branchId;
  @override
  final int? revision;
  @override
  final int? leaseGeneration;
  @override
  final DateTime at;
  @override
  final RealtimeEventAlertEnum? alert;
  @override
  final BuiltMap<String, String> refs;

  factory _$RealtimeEvent([void Function(RealtimeEventBuilder)? updates]) =>
      (RealtimeEventBuilder()..update(updates))._build();

  _$RealtimeEvent._(
      {required this.event,
      required this.id,
      required this.branchId,
      this.revision,
      this.leaseGeneration,
      required this.at,
      this.alert,
      required this.refs})
      : super._();
  @override
  RealtimeEvent rebuild(void Function(RealtimeEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RealtimeEventBuilder toBuilder() => RealtimeEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RealtimeEvent &&
        event == other.event &&
        id == other.id &&
        branchId == other.branchId &&
        revision == other.revision &&
        leaseGeneration == other.leaseGeneration &&
        at == other.at &&
        alert == other.alert &&
        refs == other.refs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, event.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, at.hashCode);
    _$hash = $jc(_$hash, alert.hashCode);
    _$hash = $jc(_$hash, refs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RealtimeEvent')
          ..add('event', event)
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('revision', revision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('at', at)
          ..add('alert', alert)
          ..add('refs', refs))
        .toString();
  }
}

class RealtimeEventBuilder
    implements Builder<RealtimeEvent, RealtimeEventBuilder> {
  _$RealtimeEvent? _$v;

  RealtimeEventEventEnum? _event;
  RealtimeEventEventEnum? get event => _$this._event;
  set event(RealtimeEventEventEnum? event) => _$this._event = event;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  int? _leaseGeneration;
  int? get leaseGeneration => _$this._leaseGeneration;
  set leaseGeneration(int? leaseGeneration) =>
      _$this._leaseGeneration = leaseGeneration;

  DateTime? _at;
  DateTime? get at => _$this._at;
  set at(DateTime? at) => _$this._at = at;

  RealtimeEventAlertEnum? _alert;
  RealtimeEventAlertEnum? get alert => _$this._alert;
  set alert(RealtimeEventAlertEnum? alert) => _$this._alert = alert;

  MapBuilder<String, String>? _refs;
  MapBuilder<String, String> get refs =>
      _$this._refs ??= MapBuilder<String, String>();
  set refs(MapBuilder<String, String>? refs) => _$this._refs = refs;

  RealtimeEventBuilder() {
    RealtimeEvent._defaults(this);
  }

  RealtimeEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _event = $v.event;
      _id = $v.id;
      _branchId = $v.branchId;
      _revision = $v.revision;
      _leaseGeneration = $v.leaseGeneration;
      _at = $v.at;
      _alert = $v.alert;
      _refs = $v.refs.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RealtimeEvent other) {
    _$v = other as _$RealtimeEvent;
  }

  @override
  void update(void Function(RealtimeEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RealtimeEvent build() => _build();

  _$RealtimeEvent _build() {
    _$RealtimeEvent _$result;
    try {
      _$result = _$v ??
          _$RealtimeEvent._(
            event: BuiltValueNullFieldError.checkNotNull(
                event, r'RealtimeEvent', 'event'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'RealtimeEvent', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'RealtimeEvent', 'branchId'),
            revision: revision,
            leaseGeneration: leaseGeneration,
            at: BuiltValueNullFieldError.checkNotNull(
                at, r'RealtimeEvent', 'at'),
            alert: alert,
            refs: refs.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'refs';
        refs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RealtimeEvent', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
