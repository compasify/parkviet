// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_minutes_card.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimedMinutesCard extends TimedMinutesCard {
  @override
  final String id;
  @override
  final String? cardHint;

  factory _$TimedMinutesCard(
          [void Function(TimedMinutesCardBuilder)? updates]) =>
      (TimedMinutesCardBuilder()..update(updates))._build();

  _$TimedMinutesCard._({required this.id, this.cardHint}) : super._();
  @override
  TimedMinutesCard rebuild(void Function(TimedMinutesCardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedMinutesCardBuilder toBuilder() =>
      TimedMinutesCardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedMinutesCard &&
        id == other.id &&
        cardHint == other.cardHint;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, cardHint.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedMinutesCard')
          ..add('id', id)
          ..add('cardHint', cardHint))
        .toString();
  }
}

class TimedMinutesCardBuilder
    implements Builder<TimedMinutesCard, TimedMinutesCardBuilder> {
  _$TimedMinutesCard? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _cardHint;
  String? get cardHint => _$this._cardHint;
  set cardHint(String? cardHint) => _$this._cardHint = cardHint;

  TimedMinutesCardBuilder() {
    TimedMinutesCard._defaults(this);
  }

  TimedMinutesCardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _cardHint = $v.cardHint;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedMinutesCard other) {
    _$v = other as _$TimedMinutesCard;
  }

  @override
  void update(void Function(TimedMinutesCardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedMinutesCard build() => _build();

  _$TimedMinutesCard _build() {
    final _$result = _$v ??
        _$TimedMinutesCard._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'TimedMinutesCard', 'id'),
          cardHint: cardHint,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
