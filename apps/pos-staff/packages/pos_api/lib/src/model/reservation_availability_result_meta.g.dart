// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_availability_result_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationAvailabilityResultMeta
    extends ReservationAvailabilityResultMeta {
  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  final int partySize;

  factory _$ReservationAvailabilityResultMeta(
          [void Function(ReservationAvailabilityResultMetaBuilder)? updates]) =>
      (ReservationAvailabilityResultMetaBuilder()..update(updates))._build();

  _$ReservationAvailabilityResultMeta._(
      {required this.startsAt, required this.endsAt, required this.partySize})
      : super._();
  @override
  ReservationAvailabilityResultMeta rebuild(
          void Function(ReservationAvailabilityResultMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationAvailabilityResultMetaBuilder toBuilder() =>
      ReservationAvailabilityResultMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationAvailabilityResultMeta &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        partySize == other.partySize;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, partySize.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationAvailabilityResultMeta')
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('partySize', partySize))
        .toString();
  }
}

class ReservationAvailabilityResultMetaBuilder
    implements
        Builder<ReservationAvailabilityResultMeta,
            ReservationAvailabilityResultMetaBuilder> {
  _$ReservationAvailabilityResultMeta? _$v;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  int? _partySize;
  int? get partySize => _$this._partySize;
  set partySize(int? partySize) => _$this._partySize = partySize;

  ReservationAvailabilityResultMetaBuilder() {
    ReservationAvailabilityResultMeta._defaults(this);
  }

  ReservationAvailabilityResultMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _partySize = $v.partySize;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationAvailabilityResultMeta other) {
    _$v = other as _$ReservationAvailabilityResultMeta;
  }

  @override
  void update(
      void Function(ReservationAvailabilityResultMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationAvailabilityResultMeta build() => _build();

  _$ReservationAvailabilityResultMeta _build() {
    final _$result = _$v ??
        _$ReservationAvailabilityResultMeta._(
          startsAt: BuiltValueNullFieldError.checkNotNull(
              startsAt, r'ReservationAvailabilityResultMeta', 'startsAt'),
          endsAt: BuiltValueNullFieldError.checkNotNull(
              endsAt, r'ReservationAvailabilityResultMeta', 'endsAt'),
          partySize: BuiltValueNullFieldError.checkNotNull(
              partySize, r'ReservationAvailabilityResultMeta', 'partySize'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
