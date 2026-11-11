// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_seat_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationSeatResult extends ReservationSeatResult {
  @override
  final ReservationSeat data;

  factory _$ReservationSeatResult(
          [void Function(ReservationSeatResultBuilder)? updates]) =>
      (ReservationSeatResultBuilder()..update(updates))._build();

  _$ReservationSeatResult._({required this.data}) : super._();
  @override
  ReservationSeatResult rebuild(
          void Function(ReservationSeatResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationSeatResultBuilder toBuilder() =>
      ReservationSeatResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationSeatResult && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationSeatResult')
          ..add('data', data))
        .toString();
  }
}

class ReservationSeatResultBuilder
    implements Builder<ReservationSeatResult, ReservationSeatResultBuilder> {
  _$ReservationSeatResult? _$v;

  ReservationSeatBuilder? _data;
  ReservationSeatBuilder get data => _$this._data ??= ReservationSeatBuilder();
  set data(ReservationSeatBuilder? data) => _$this._data = data;

  ReservationSeatResultBuilder() {
    ReservationSeatResult._defaults(this);
  }

  ReservationSeatResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationSeatResult other) {
    _$v = other as _$ReservationSeatResult;
  }

  @override
  void update(void Function(ReservationSeatResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationSeatResult build() => _build();

  _$ReservationSeatResult _build() {
    _$ReservationSeatResult _$result;
    try {
      _$result = _$v ??
          _$ReservationSeatResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationSeatResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
