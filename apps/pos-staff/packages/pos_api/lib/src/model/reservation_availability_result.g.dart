// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_availability_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationAvailabilityResult extends ReservationAvailabilityResult {
  @override
  final BuiltList<AvailableResource> data;
  @override
  final ReservationAvailabilityResultMeta meta;

  factory _$ReservationAvailabilityResult(
          [void Function(ReservationAvailabilityResultBuilder)? updates]) =>
      (ReservationAvailabilityResultBuilder()..update(updates))._build();

  _$ReservationAvailabilityResult._({required this.data, required this.meta})
      : super._();
  @override
  ReservationAvailabilityResult rebuild(
          void Function(ReservationAvailabilityResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationAvailabilityResultBuilder toBuilder() =>
      ReservationAvailabilityResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationAvailabilityResult &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationAvailabilityResult')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class ReservationAvailabilityResultBuilder
    implements
        Builder<ReservationAvailabilityResult,
            ReservationAvailabilityResultBuilder> {
  _$ReservationAvailabilityResult? _$v;

  ListBuilder<AvailableResource>? _data;
  ListBuilder<AvailableResource> get data =>
      _$this._data ??= ListBuilder<AvailableResource>();
  set data(ListBuilder<AvailableResource>? data) => _$this._data = data;

  ReservationAvailabilityResultMetaBuilder? _meta;
  ReservationAvailabilityResultMetaBuilder get meta =>
      _$this._meta ??= ReservationAvailabilityResultMetaBuilder();
  set meta(ReservationAvailabilityResultMetaBuilder? meta) =>
      _$this._meta = meta;

  ReservationAvailabilityResultBuilder() {
    ReservationAvailabilityResult._defaults(this);
  }

  ReservationAvailabilityResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationAvailabilityResult other) {
    _$v = other as _$ReservationAvailabilityResult;
  }

  @override
  void update(void Function(ReservationAvailabilityResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationAvailabilityResult build() => _build();

  _$ReservationAvailabilityResult _build() {
    _$ReservationAvailabilityResult _$result;
    try {
      _$result = _$v ??
          _$ReservationAvailabilityResult._(
            data: data.build(),
            meta: meta.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationAvailabilityResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
