// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationResult extends ReservationResult {
  @override
  final Reservation data;

  factory _$ReservationResult(
          [void Function(ReservationResultBuilder)? updates]) =>
      (ReservationResultBuilder()..update(updates))._build();

  _$ReservationResult._({required this.data}) : super._();
  @override
  ReservationResult rebuild(void Function(ReservationResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationResultBuilder toBuilder() =>
      ReservationResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ReservationResult')
          ..add('data', data))
        .toString();
  }
}

class ReservationResultBuilder
    implements Builder<ReservationResult, ReservationResultBuilder> {
  _$ReservationResult? _$v;

  ReservationBuilder? _data;
  ReservationBuilder get data => _$this._data ??= ReservationBuilder();
  set data(ReservationBuilder? data) => _$this._data = data;

  ReservationResultBuilder() {
    ReservationResult._defaults(this);
  }

  ReservationResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationResult other) {
    _$v = other as _$ReservationResult;
  }

  @override
  void update(void Function(ReservationResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationResult build() => _build();

  _$ReservationResult _build() {
    _$ReservationResult _$result;
    try {
      _$result = _$v ??
          _$ReservationResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
