// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_segment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TimedSegmentEndedReasonEnum _$timedSegmentEndedReasonEnum_pause =
    const TimedSegmentEndedReasonEnum._('pause');
const TimedSegmentEndedReasonEnum _$timedSegmentEndedReasonEnum_resume =
    const TimedSegmentEndedReasonEnum._('resume');
const TimedSegmentEndedReasonEnum _$timedSegmentEndedReasonEnum_move =
    const TimedSegmentEndedReasonEnum._('move');
const TimedSegmentEndedReasonEnum _$timedSegmentEndedReasonEnum_stop =
    const TimedSegmentEndedReasonEnum._('stop');
const TimedSegmentEndedReasonEnum _$timedSegmentEndedReasonEnum_splitWindow =
    const TimedSegmentEndedReasonEnum._('splitWindow');

TimedSegmentEndedReasonEnum _$timedSegmentEndedReasonEnumValueOf(String name) {
  switch (name) {
    case 'pause':
      return _$timedSegmentEndedReasonEnum_pause;
    case 'resume':
      return _$timedSegmentEndedReasonEnum_resume;
    case 'move':
      return _$timedSegmentEndedReasonEnum_move;
    case 'stop':
      return _$timedSegmentEndedReasonEnum_stop;
    case 'splitWindow':
      return _$timedSegmentEndedReasonEnum_splitWindow;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TimedSegmentEndedReasonEnum>
    _$timedSegmentEndedReasonEnumValues =
    BuiltSet<TimedSegmentEndedReasonEnum>(const <TimedSegmentEndedReasonEnum>[
  _$timedSegmentEndedReasonEnum_pause,
  _$timedSegmentEndedReasonEnum_resume,
  _$timedSegmentEndedReasonEnum_move,
  _$timedSegmentEndedReasonEnum_stop,
  _$timedSegmentEndedReasonEnum_splitWindow,
]);

const TimedSegmentKindEnum _$timedSegmentKindEnum_play =
    const TimedSegmentKindEnum._('play');
const TimedSegmentKindEnum _$timedSegmentKindEnum_pause =
    const TimedSegmentKindEnum._('pause');

TimedSegmentKindEnum _$timedSegmentKindEnumValueOf(String name) {
  switch (name) {
    case 'play':
      return _$timedSegmentKindEnum_play;
    case 'pause':
      return _$timedSegmentKindEnum_pause;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TimedSegmentKindEnum> _$timedSegmentKindEnumValues =
    BuiltSet<TimedSegmentKindEnum>(const <TimedSegmentKindEnum>[
  _$timedSegmentKindEnum_play,
  _$timedSegmentKindEnum_pause,
]);

Serializer<TimedSegmentEndedReasonEnum>
    _$timedSegmentEndedReasonEnumSerializer =
    _$TimedSegmentEndedReasonEnumSerializer();
Serializer<TimedSegmentKindEnum> _$timedSegmentKindEnumSerializer =
    _$TimedSegmentKindEnumSerializer();

class _$TimedSegmentEndedReasonEnumSerializer
    implements PrimitiveSerializer<TimedSegmentEndedReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pause': 'pause',
    'resume': 'resume',
    'move': 'move',
    'stop': 'stop',
    'splitWindow': 'split_window',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pause': 'pause',
    'resume': 'resume',
    'move': 'move',
    'stop': 'stop',
    'split_window': 'splitWindow',
  };

  @override
  final Iterable<Type> types = const <Type>[TimedSegmentEndedReasonEnum];
  @override
  final String wireName = 'TimedSegmentEndedReasonEnum';

  @override
  Object serialize(Serializers serializers, TimedSegmentEndedReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TimedSegmentEndedReasonEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TimedSegmentEndedReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TimedSegmentKindEnumSerializer
    implements PrimitiveSerializer<TimedSegmentKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'play': 'play',
    'pause': 'pause',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'play': 'play',
    'pause': 'pause',
  };

  @override
  final Iterable<Type> types = const <Type>[TimedSegmentKindEnum];
  @override
  final String wireName = 'TimedSegmentKindEnum';

  @override
  Object serialize(Serializers serializers, TimedSegmentKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TimedSegmentKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TimedSegmentKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TimedSegment extends TimedSegment {
  @override
  final TimedSegmentEndedReasonEnum? endedReason;
  @override
  final String id;
  @override
  final TimedSegmentKindEnum kind;
  @override
  final String resourceId;
  @override
  final String resourceName;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final String? ratePlanId;
  @override
  final String? ratePlanName;
  @override
  final int? ratePlanVersion;
  @override
  final bool edited;

  factory _$TimedSegment([void Function(TimedSegmentBuilder)? updates]) =>
      (TimedSegmentBuilder()..update(updates))._build();

  _$TimedSegment._(
      {this.endedReason,
      required this.id,
      required this.kind,
      required this.resourceId,
      required this.resourceName,
      required this.startedAt,
      this.endedAt,
      this.ratePlanId,
      this.ratePlanName,
      this.ratePlanVersion,
      required this.edited})
      : super._();
  @override
  TimedSegment rebuild(void Function(TimedSegmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedSegmentBuilder toBuilder() => TimedSegmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedSegment &&
        endedReason == other.endedReason &&
        id == other.id &&
        kind == other.kind &&
        resourceId == other.resourceId &&
        resourceName == other.resourceName &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        ratePlanId == other.ratePlanId &&
        ratePlanName == other.ratePlanName &&
        ratePlanVersion == other.ratePlanVersion &&
        edited == other.edited;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, endedReason.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, resourceName.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, ratePlanId.hashCode);
    _$hash = $jc(_$hash, ratePlanName.hashCode);
    _$hash = $jc(_$hash, ratePlanVersion.hashCode);
    _$hash = $jc(_$hash, edited.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedSegment')
          ..add('endedReason', endedReason)
          ..add('id', id)
          ..add('kind', kind)
          ..add('resourceId', resourceId)
          ..add('resourceName', resourceName)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('ratePlanId', ratePlanId)
          ..add('ratePlanName', ratePlanName)
          ..add('ratePlanVersion', ratePlanVersion)
          ..add('edited', edited))
        .toString();
  }
}

class TimedSegmentBuilder
    implements Builder<TimedSegment, TimedSegmentBuilder> {
  _$TimedSegment? _$v;

  TimedSegmentEndedReasonEnum? _endedReason;
  TimedSegmentEndedReasonEnum? get endedReason => _$this._endedReason;
  set endedReason(TimedSegmentEndedReasonEnum? endedReason) =>
      _$this._endedReason = endedReason;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  TimedSegmentKindEnum? _kind;
  TimedSegmentKindEnum? get kind => _$this._kind;
  set kind(TimedSegmentKindEnum? kind) => _$this._kind = kind;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _resourceName;
  String? get resourceName => _$this._resourceName;
  set resourceName(String? resourceName) => _$this._resourceName = resourceName;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  String? _ratePlanId;
  String? get ratePlanId => _$this._ratePlanId;
  set ratePlanId(String? ratePlanId) => _$this._ratePlanId = ratePlanId;

  String? _ratePlanName;
  String? get ratePlanName => _$this._ratePlanName;
  set ratePlanName(String? ratePlanName) => _$this._ratePlanName = ratePlanName;

  int? _ratePlanVersion;
  int? get ratePlanVersion => _$this._ratePlanVersion;
  set ratePlanVersion(int? ratePlanVersion) =>
      _$this._ratePlanVersion = ratePlanVersion;

  bool? _edited;
  bool? get edited => _$this._edited;
  set edited(bool? edited) => _$this._edited = edited;

  TimedSegmentBuilder() {
    TimedSegment._defaults(this);
  }

  TimedSegmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _endedReason = $v.endedReason;
      _id = $v.id;
      _kind = $v.kind;
      _resourceId = $v.resourceId;
      _resourceName = $v.resourceName;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _ratePlanId = $v.ratePlanId;
      _ratePlanName = $v.ratePlanName;
      _ratePlanVersion = $v.ratePlanVersion;
      _edited = $v.edited;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedSegment other) {
    _$v = other as _$TimedSegment;
  }

  @override
  void update(void Function(TimedSegmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedSegment build() => _build();

  _$TimedSegment _build() {
    final _$result = _$v ??
        _$TimedSegment._(
          endedReason: endedReason,
          id: BuiltValueNullFieldError.checkNotNull(id, r'TimedSegment', 'id'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'TimedSegment', 'kind'),
          resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId, r'TimedSegment', 'resourceId'),
          resourceName: BuiltValueNullFieldError.checkNotNull(
              resourceName, r'TimedSegment', 'resourceName'),
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'TimedSegment', 'startedAt'),
          endedAt: endedAt,
          ratePlanId: ratePlanId,
          ratePlanName: ratePlanName,
          ratePlanVersion: ratePlanVersion,
          edited: BuiltValueNullFieldError.checkNotNull(
              edited, r'TimedSegment', 'edited'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
