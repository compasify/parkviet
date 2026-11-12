// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_quote.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimedQuote extends TimedQuote {
  @override
  final DateTime asOf;
  @override
  final bool final_;
  @override
  final int playedMinutes;
  @override
  final int billedMinutes;
  @override
  final String amount;
  @override
  final BuiltList<TimedQuoteLine> lines;

  factory _$TimedQuote([void Function(TimedQuoteBuilder)? updates]) =>
      (TimedQuoteBuilder()..update(updates))._build();

  _$TimedQuote._(
      {required this.asOf,
      required this.final_,
      required this.playedMinutes,
      required this.billedMinutes,
      required this.amount,
      required this.lines})
      : super._();
  @override
  TimedQuote rebuild(void Function(TimedQuoteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedQuoteBuilder toBuilder() => TimedQuoteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedQuote &&
        asOf == other.asOf &&
        final_ == other.final_ &&
        playedMinutes == other.playedMinutes &&
        billedMinutes == other.billedMinutes &&
        amount == other.amount &&
        lines == other.lines;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, asOf.hashCode);
    _$hash = $jc(_$hash, final_.hashCode);
    _$hash = $jc(_$hash, playedMinutes.hashCode);
    _$hash = $jc(_$hash, billedMinutes.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedQuote')
          ..add('asOf', asOf)
          ..add('final_', final_)
          ..add('playedMinutes', playedMinutes)
          ..add('billedMinutes', billedMinutes)
          ..add('amount', amount)
          ..add('lines', lines))
        .toString();
  }
}

class TimedQuoteBuilder implements Builder<TimedQuote, TimedQuoteBuilder> {
  _$TimedQuote? _$v;

  DateTime? _asOf;
  DateTime? get asOf => _$this._asOf;
  set asOf(DateTime? asOf) => _$this._asOf = asOf;

  bool? _final_;
  bool? get final_ => _$this._final_;
  set final_(bool? final_) => _$this._final_ = final_;

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

  ListBuilder<TimedQuoteLine>? _lines;
  ListBuilder<TimedQuoteLine> get lines =>
      _$this._lines ??= ListBuilder<TimedQuoteLine>();
  set lines(ListBuilder<TimedQuoteLine>? lines) => _$this._lines = lines;

  TimedQuoteBuilder() {
    TimedQuote._defaults(this);
  }

  TimedQuoteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _asOf = $v.asOf;
      _final_ = $v.final_;
      _playedMinutes = $v.playedMinutes;
      _billedMinutes = $v.billedMinutes;
      _amount = $v.amount;
      _lines = $v.lines.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedQuote other) {
    _$v = other as _$TimedQuote;
  }

  @override
  void update(void Function(TimedQuoteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedQuote build() => _build();

  _$TimedQuote _build() {
    _$TimedQuote _$result;
    try {
      _$result = _$v ??
          _$TimedQuote._(
            asOf: BuiltValueNullFieldError.checkNotNull(
                asOf, r'TimedQuote', 'asOf'),
            final_: BuiltValueNullFieldError.checkNotNull(
                final_, r'TimedQuote', 'final_'),
            playedMinutes: BuiltValueNullFieldError.checkNotNull(
                playedMinutes, r'TimedQuote', 'playedMinutes'),
            billedMinutes: BuiltValueNullFieldError.checkNotNull(
                billedMinutes, r'TimedQuote', 'billedMinutes'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'TimedQuote', 'amount'),
            lines: lines.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lines';
        lines.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TimedQuote', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
