// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TimedSessionStatusEnum _$timedSessionStatusEnum_running =
    const TimedSessionStatusEnum._('running');
const TimedSessionStatusEnum _$timedSessionStatusEnum_paused =
    const TimedSessionStatusEnum._('paused');
const TimedSessionStatusEnum _$timedSessionStatusEnum_stopped =
    const TimedSessionStatusEnum._('stopped');

TimedSessionStatusEnum _$timedSessionStatusEnumValueOf(String name) {
  switch (name) {
    case 'running':
      return _$timedSessionStatusEnum_running;
    case 'paused':
      return _$timedSessionStatusEnum_paused;
    case 'stopped':
      return _$timedSessionStatusEnum_stopped;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TimedSessionStatusEnum> _$timedSessionStatusEnumValues =
    BuiltSet<TimedSessionStatusEnum>(const <TimedSessionStatusEnum>[
  _$timedSessionStatusEnum_running,
  _$timedSessionStatusEnum_paused,
  _$timedSessionStatusEnum_stopped,
]);

Serializer<TimedSessionStatusEnum> _$timedSessionStatusEnumSerializer =
    _$TimedSessionStatusEnumSerializer();

class _$TimedSessionStatusEnumSerializer
    implements PrimitiveSerializer<TimedSessionStatusEnum> {
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
  final Iterable<Type> types = const <Type>[TimedSessionStatusEnum];
  @override
  final String wireName = 'TimedSessionStatusEnum';

  @override
  Object serialize(Serializers serializers, TimedSessionStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TimedSessionStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TimedSessionStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TimedSession extends TimedSession {
  @override
  final String id;
  @override
  final TimedSessionStatusEnum status;
  @override
  final String resourceId;
  @override
  final String resourceName;
  @override
  final DateTime startedAt;
  @override
  final DateTime? stoppedAt;
  @override
  final DateTime? plannedEndAt;
  @override
  final int playedMinutes;
  @override
  final int billedMinutes;
  @override
  final String amount;
  @override
  final String currency;
  @override
  final int quoteVersion;
  @override
  final BuiltList<TimedSegment> segments;
  @override
  final TimedQuote? quote;

  factory _$TimedSession([void Function(TimedSessionBuilder)? updates]) =>
      (TimedSessionBuilder()..update(updates))._build();

  _$TimedSession._(
      {required this.id,
      required this.status,
      required this.resourceId,
      required this.resourceName,
      required this.startedAt,
      this.stoppedAt,
      this.plannedEndAt,
      required this.playedMinutes,
      required this.billedMinutes,
      required this.amount,
      required this.currency,
      required this.quoteVersion,
      required this.segments,
      this.quote})
      : super._();
  @override
  TimedSession rebuild(void Function(TimedSessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedSessionBuilder toBuilder() => TimedSessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedSession &&
        id == other.id &&
        status == other.status &&
        resourceId == other.resourceId &&
        resourceName == other.resourceName &&
        startedAt == other.startedAt &&
        stoppedAt == other.stoppedAt &&
        plannedEndAt == other.plannedEndAt &&
        playedMinutes == other.playedMinutes &&
        billedMinutes == other.billedMinutes &&
        amount == other.amount &&
        currency == other.currency &&
        quoteVersion == other.quoteVersion &&
        segments == other.segments &&
        quote == other.quote;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, resourceName.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, stoppedAt.hashCode);
    _$hash = $jc(_$hash, plannedEndAt.hashCode);
    _$hash = $jc(_$hash, playedMinutes.hashCode);
    _$hash = $jc(_$hash, billedMinutes.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, quoteVersion.hashCode);
    _$hash = $jc(_$hash, segments.hashCode);
    _$hash = $jc(_$hash, quote.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedSession')
          ..add('id', id)
          ..add('status', status)
          ..add('resourceId', resourceId)
          ..add('resourceName', resourceName)
          ..add('startedAt', startedAt)
          ..add('stoppedAt', stoppedAt)
          ..add('plannedEndAt', plannedEndAt)
          ..add('playedMinutes', playedMinutes)
          ..add('billedMinutes', billedMinutes)
          ..add('amount', amount)
          ..add('currency', currency)
          ..add('quoteVersion', quoteVersion)
          ..add('segments', segments)
          ..add('quote', quote))
        .toString();
  }
}

class TimedSessionBuilder
    implements Builder<TimedSession, TimedSessionBuilder> {
  _$TimedSession? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  TimedSessionStatusEnum? _status;
  TimedSessionStatusEnum? get status => _$this._status;
  set status(TimedSessionStatusEnum? status) => _$this._status = status;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _resourceName;
  String? get resourceName => _$this._resourceName;
  set resourceName(String? resourceName) => _$this._resourceName = resourceName;

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

  int? _billedMinutes;
  int? get billedMinutes => _$this._billedMinutes;
  set billedMinutes(int? billedMinutes) =>
      _$this._billedMinutes = billedMinutes;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  int? _quoteVersion;
  int? get quoteVersion => _$this._quoteVersion;
  set quoteVersion(int? quoteVersion) => _$this._quoteVersion = quoteVersion;

  ListBuilder<TimedSegment>? _segments;
  ListBuilder<TimedSegment> get segments =>
      _$this._segments ??= ListBuilder<TimedSegment>();
  set segments(ListBuilder<TimedSegment>? segments) =>
      _$this._segments = segments;

  TimedQuoteBuilder? _quote;
  TimedQuoteBuilder get quote => _$this._quote ??= TimedQuoteBuilder();
  set quote(TimedQuoteBuilder? quote) => _$this._quote = quote;

  TimedSessionBuilder() {
    TimedSession._defaults(this);
  }

  TimedSessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _resourceId = $v.resourceId;
      _resourceName = $v.resourceName;
      _startedAt = $v.startedAt;
      _stoppedAt = $v.stoppedAt;
      _plannedEndAt = $v.plannedEndAt;
      _playedMinutes = $v.playedMinutes;
      _billedMinutes = $v.billedMinutes;
      _amount = $v.amount;
      _currency = $v.currency;
      _quoteVersion = $v.quoteVersion;
      _segments = $v.segments.toBuilder();
      _quote = $v.quote?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedSession other) {
    _$v = other as _$TimedSession;
  }

  @override
  void update(void Function(TimedSessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedSession build() => _build();

  _$TimedSession _build() {
    _$TimedSession _$result;
    try {
      _$result = _$v ??
          _$TimedSession._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'TimedSession', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'TimedSession', 'status'),
            resourceId: BuiltValueNullFieldError.checkNotNull(
                resourceId, r'TimedSession', 'resourceId'),
            resourceName: BuiltValueNullFieldError.checkNotNull(
                resourceName, r'TimedSession', 'resourceName'),
            startedAt: BuiltValueNullFieldError.checkNotNull(
                startedAt, r'TimedSession', 'startedAt'),
            stoppedAt: stoppedAt,
            plannedEndAt: plannedEndAt,
            playedMinutes: BuiltValueNullFieldError.checkNotNull(
                playedMinutes, r'TimedSession', 'playedMinutes'),
            billedMinutes: BuiltValueNullFieldError.checkNotNull(
                billedMinutes, r'TimedSession', 'billedMinutes'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'TimedSession', 'amount'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'TimedSession', 'currency'),
            quoteVersion: BuiltValueNullFieldError.checkNotNull(
                quoteVersion, r'TimedSession', 'quoteVersion'),
            segments: segments.build(),
            quote: _quote?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'segments';
        segments.build();
        _$failedField = 'quote';
        _quote?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TimedSession', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
