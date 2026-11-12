// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_board_timed.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ResourceBoardTimedStatusEnum _$resourceBoardTimedStatusEnum_running =
    const ResourceBoardTimedStatusEnum._('running');
const ResourceBoardTimedStatusEnum _$resourceBoardTimedStatusEnum_paused =
    const ResourceBoardTimedStatusEnum._('paused');
const ResourceBoardTimedStatusEnum _$resourceBoardTimedStatusEnum_stopped =
    const ResourceBoardTimedStatusEnum._('stopped');

ResourceBoardTimedStatusEnum _$resourceBoardTimedStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'running':
      return _$resourceBoardTimedStatusEnum_running;
    case 'paused':
      return _$resourceBoardTimedStatusEnum_paused;
    case 'stopped':
      return _$resourceBoardTimedStatusEnum_stopped;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceBoardTimedStatusEnum>
    _$resourceBoardTimedStatusEnumValues =
    BuiltSet<ResourceBoardTimedStatusEnum>(const <ResourceBoardTimedStatusEnum>[
  _$resourceBoardTimedStatusEnum_running,
  _$resourceBoardTimedStatusEnum_paused,
  _$resourceBoardTimedStatusEnum_stopped,
]);

Serializer<ResourceBoardTimedStatusEnum>
    _$resourceBoardTimedStatusEnumSerializer =
    _$ResourceBoardTimedStatusEnumSerializer();

class _$ResourceBoardTimedStatusEnumSerializer
    implements PrimitiveSerializer<ResourceBoardTimedStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'running': 'running',
    'paused': 'paused',
    'stopped': 'stopped',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'running': 'running',
    'paused': 'paused',
    'stopped': 'stopped',
  };

  @override
  final Iterable<Type> types = const <Type>[ResourceBoardTimedStatusEnum];
  @override
  final String wireName = 'ResourceBoardTimedStatusEnum';

  @override
  Object serialize(Serializers serializers, ResourceBoardTimedStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceBoardTimedStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceBoardTimedStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResourceBoardTimed extends ResourceBoardTimed {
  @override
  final String id;
  @override
  final String? workspaceId;
  @override
  final ResourceBoardTimedStatusEnum status;
  @override
  final DateTime startedAt;
  @override
  final DateTime? stoppedAt;
  @override
  final DateTime? plannedEndAt;
  @override
  final int playedMinutes;
  @override
  final String quoteAmount;
  @override
  final bool endingSoon;

  factory _$ResourceBoardTimed(
          [void Function(ResourceBoardTimedBuilder)? updates]) =>
      (ResourceBoardTimedBuilder()..update(updates))._build();

  _$ResourceBoardTimed._(
      {required this.id,
      this.workspaceId,
      required this.status,
      required this.startedAt,
      this.stoppedAt,
      this.plannedEndAt,
      required this.playedMinutes,
      required this.quoteAmount,
      required this.endingSoon})
      : super._();
  @override
  ResourceBoardTimed rebuild(
          void Function(ResourceBoardTimedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceBoardTimedBuilder toBuilder() =>
      ResourceBoardTimedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceBoardTimed &&
        id == other.id &&
        workspaceId == other.workspaceId &&
        status == other.status &&
        startedAt == other.startedAt &&
        stoppedAt == other.stoppedAt &&
        plannedEndAt == other.plannedEndAt &&
        playedMinutes == other.playedMinutes &&
        quoteAmount == other.quoteAmount &&
        endingSoon == other.endingSoon;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, stoppedAt.hashCode);
    _$hash = $jc(_$hash, plannedEndAt.hashCode);
    _$hash = $jc(_$hash, playedMinutes.hashCode);
    _$hash = $jc(_$hash, quoteAmount.hashCode);
    _$hash = $jc(_$hash, endingSoon.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResourceBoardTimed')
          ..add('id', id)
          ..add('workspaceId', workspaceId)
          ..add('status', status)
          ..add('startedAt', startedAt)
          ..add('stoppedAt', stoppedAt)
          ..add('plannedEndAt', plannedEndAt)
          ..add('playedMinutes', playedMinutes)
          ..add('quoteAmount', quoteAmount)
          ..add('endingSoon', endingSoon))
        .toString();
  }
}

class ResourceBoardTimedBuilder
    implements Builder<ResourceBoardTimed, ResourceBoardTimedBuilder> {
  _$ResourceBoardTimed? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  ResourceBoardTimedStatusEnum? _status;
  ResourceBoardTimedStatusEnum? get status => _$this._status;
  set status(ResourceBoardTimedStatusEnum? status) => _$this._status = status;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _stoppedAt;
  DateTime? get stoppedAt => _$this._stoppedAt;
  set stoppedAt(DateTime? stoppedAt) => _$this._stoppedAt = stoppedAt;

  DateTime? _plannedEndAt;
  DateTime? get plannedEndAt => _$this._plannedEndAt;
  set plannedEndAt(DateTime? plannedEndAt) =>
      _$this._plannedEndAt = plannedEndAt;

  int? _playedMinutes;
  int? get playedMinutes => _$this._playedMinutes;
  set playedMinutes(int? playedMinutes) =>
      _$this._playedMinutes = playedMinutes;

  String? _quoteAmount;
  String? get quoteAmount => _$this._quoteAmount;
  set quoteAmount(String? quoteAmount) => _$this._quoteAmount = quoteAmount;

  bool? _endingSoon;
  bool? get endingSoon => _$this._endingSoon;
  set endingSoon(bool? endingSoon) => _$this._endingSoon = endingSoon;

  ResourceBoardTimedBuilder() {
    ResourceBoardTimed._defaults(this);
  }

  ResourceBoardTimedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _workspaceId = $v.workspaceId;
      _status = $v.status;
      _startedAt = $v.startedAt;
      _stoppedAt = $v.stoppedAt;
      _plannedEndAt = $v.plannedEndAt;
      _playedMinutes = $v.playedMinutes;
      _quoteAmount = $v.quoteAmount;
      _endingSoon = $v.endingSoon;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceBoardTimed other) {
    _$v = other as _$ResourceBoardTimed;
  }

  @override
  void update(void Function(ResourceBoardTimedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceBoardTimed build() => _build();

  _$ResourceBoardTimed _build() {
    final _$result = _$v ??
        _$ResourceBoardTimed._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ResourceBoardTimed', 'id'),
          workspaceId: workspaceId,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ResourceBoardTimed', 'status'),
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'ResourceBoardTimed', 'startedAt'),
          stoppedAt: stoppedAt,
          plannedEndAt: plannedEndAt,
          playedMinutes: BuiltValueNullFieldError.checkNotNull(
              playedMinutes, r'ResourceBoardTimed', 'playedMinutes'),
          quoteAmount: BuiltValueNullFieldError.checkNotNull(
              quoteAmount, r'ResourceBoardTimed', 'quoteAmount'),
          endingSoon: BuiltValueNullFieldError.checkNotNull(
              endingSoon, r'ResourceBoardTimed', 'endingSoon'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
