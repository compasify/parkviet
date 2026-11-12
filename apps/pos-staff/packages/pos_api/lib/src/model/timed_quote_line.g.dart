// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_quote_line.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TimedQuoteLineKindEnum _$timedQuoteLineKindEnum_rate =
    const TimedQuoteLineKindEnum._('rate');
const TimedQuoteLineKindEnum _$timedQuoteLineKindEnum_package =
    const TimedQuoteLineKindEnum._('package');
const TimedQuoteLineKindEnum _$timedQuoteLineKindEnum_card =
    const TimedQuoteLineKindEnum._('card');
const TimedQuoteLineKindEnum _$timedQuoteLineKindEnum_bonus =
    const TimedQuoteLineKindEnum._('bonus');

TimedQuoteLineKindEnum _$timedQuoteLineKindEnumValueOf(String name) {
  switch (name) {
    case 'rate':
      return _$timedQuoteLineKindEnum_rate;
    case 'package':
      return _$timedQuoteLineKindEnum_package;
    case 'card':
      return _$timedQuoteLineKindEnum_card;
    case 'bonus':
      return _$timedQuoteLineKindEnum_bonus;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TimedQuoteLineKindEnum> _$timedQuoteLineKindEnumValues =
    BuiltSet<TimedQuoteLineKindEnum>(const <TimedQuoteLineKindEnum>[
  _$timedQuoteLineKindEnum_rate,
  _$timedQuoteLineKindEnum_package,
  _$timedQuoteLineKindEnum_card,
  _$timedQuoteLineKindEnum_bonus,
]);

Serializer<TimedQuoteLineKindEnum> _$timedQuoteLineKindEnumSerializer =
    _$TimedQuoteLineKindEnumSerializer();

class _$TimedQuoteLineKindEnumSerializer
    implements PrimitiveSerializer<TimedQuoteLineKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'rate': 'rate',
    'package': 'package',
    'card': 'card',
    'bonus': 'bonus',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'rate': 'rate',
    'package': 'package',
    'card': 'card',
    'bonus': 'bonus',
  };

  @override
  final Iterable<Type> types = const <Type>[TimedQuoteLineKindEnum];
  @override
  final String wireName = 'TimedQuoteLineKindEnum';

  @override
  Object serialize(Serializers serializers, TimedQuoteLineKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TimedQuoteLineKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TimedQuoteLineKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TimedQuoteLine extends TimedQuoteLine {
  @override
  final TimedQuoteLineKindEnum kind;
  @override
  final String? promotionId;
  @override
  final String? segmentId;
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final String? dayType;
  @override
  final String? label;
  @override
  final String pricePerHour;
  @override
  final String surchargePercent;
  @override
  final int minutes;
  @override
  final String amount;

  factory _$TimedQuoteLine([void Function(TimedQuoteLineBuilder)? updates]) =>
      (TimedQuoteLineBuilder()..update(updates))._build();

  _$TimedQuoteLine._(
      {required this.kind,
      this.promotionId,
      this.segmentId,
      required this.startsAt,
      required this.endsAt,
      this.dayType,
      this.label,
      required this.pricePerHour,
      required this.surchargePercent,
      required this.minutes,
      required this.amount})
      : super._();
  @override
  TimedQuoteLine rebuild(void Function(TimedQuoteLineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedQuoteLineBuilder toBuilder() => TimedQuoteLineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedQuoteLine &&
        kind == other.kind &&
        promotionId == other.promotionId &&
        segmentId == other.segmentId &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        dayType == other.dayType &&
        label == other.label &&
        pricePerHour == other.pricePerHour &&
        surchargePercent == other.surchargePercent &&
        minutes == other.minutes &&
        amount == other.amount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, promotionId.hashCode);
    _$hash = $jc(_$hash, segmentId.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, dayType.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, pricePerHour.hashCode);
    _$hash = $jc(_$hash, surchargePercent.hashCode);
    _$hash = $jc(_$hash, minutes.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedQuoteLine')
          ..add('kind', kind)
          ..add('promotionId', promotionId)
          ..add('segmentId', segmentId)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('dayType', dayType)
          ..add('label', label)
          ..add('pricePerHour', pricePerHour)
          ..add('surchargePercent', surchargePercent)
          ..add('minutes', minutes)
          ..add('amount', amount))
        .toString();
  }
}

class TimedQuoteLineBuilder
    implements Builder<TimedQuoteLine, TimedQuoteLineBuilder> {
  _$TimedQuoteLine? _$v;

  TimedQuoteLineKindEnum? _kind;
  TimedQuoteLineKindEnum? get kind => _$this._kind;
  set kind(TimedQuoteLineKindEnum? kind) => _$this._kind = kind;

  String? _promotionId;
  String? get promotionId => _$this._promotionId;
  set promotionId(String? promotionId) => _$this._promotionId = promotionId;

  String? _segmentId;
  String? get segmentId => _$this._segmentId;
  set segmentId(String? segmentId) => _$this._segmentId = segmentId;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  String? _dayType;
  String? get dayType => _$this._dayType;
  set dayType(String? dayType) => _$this._dayType = dayType;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _pricePerHour;
  String? get pricePerHour => _$this._pricePerHour;
  set pricePerHour(String? pricePerHour) => _$this._pricePerHour = pricePerHour;

  String? _surchargePercent;
  String? get surchargePercent => _$this._surchargePercent;
  set surchargePercent(String? surchargePercent) =>
      _$this._surchargePercent = surchargePercent;

  int? _minutes;
  int? get minutes => _$this._minutes;
  set minutes(int? minutes) => _$this._minutes = minutes;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  TimedQuoteLineBuilder() {
    TimedQuoteLine._defaults(this);
  }

  TimedQuoteLineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _promotionId = $v.promotionId;
      _segmentId = $v.segmentId;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _dayType = $v.dayType;
      _label = $v.label;
      _pricePerHour = $v.pricePerHour;
      _surchargePercent = $v.surchargePercent;
      _minutes = $v.minutes;
      _amount = $v.amount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedQuoteLine other) {
    _$v = other as _$TimedQuoteLine;
  }

  @override
  void update(void Function(TimedQuoteLineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedQuoteLine build() => _build();

  _$TimedQuoteLine _build() {
    final _$result = _$v ??
        _$TimedQuoteLine._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'TimedQuoteLine', 'kind'),
          promotionId: promotionId,
          segmentId: segmentId,
          startsAt: BuiltValueNullFieldError.checkNotNull(
              startsAt, r'TimedQuoteLine', 'startsAt'),
          endsAt: BuiltValueNullFieldError.checkNotNull(
              endsAt, r'TimedQuoteLine', 'endsAt'),
          dayType: dayType,
          label: label,
          pricePerHour: BuiltValueNullFieldError.checkNotNull(
              pricePerHour, r'TimedQuoteLine', 'pricePerHour'),
          surchargePercent: BuiltValueNullFieldError.checkNotNull(
              surchargePercent, r'TimedQuoteLine', 'surchargePercent'),
          minutes: BuiltValueNullFieldError.checkNotNull(
              minutes, r'TimedQuoteLine', 'minutes'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'TimedQuoteLine', 'amount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
