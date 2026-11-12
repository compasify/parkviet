// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_visit_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleVisitResult extends VehicleVisitResult {
  @override
  final VehicleVisit data;

  factory _$VehicleVisitResult(
          [void Function(VehicleVisitResultBuilder)? updates]) =>
      (VehicleVisitResultBuilder()..update(updates))._build();

  _$VehicleVisitResult._({required this.data}) : super._();
  @override
  VehicleVisitResult rebuild(
          void Function(VehicleVisitResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleVisitResultBuilder toBuilder() =>
      VehicleVisitResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleVisitResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'VehicleVisitResult')
          ..add('data', data))
        .toString();
  }
}

class VehicleVisitResultBuilder
    implements Builder<VehicleVisitResult, VehicleVisitResultBuilder> {
  _$VehicleVisitResult? _$v;

  VehicleVisitBuilder? _data;
  VehicleVisitBuilder get data => _$this._data ??= VehicleVisitBuilder();
  set data(VehicleVisitBuilder? data) => _$this._data = data;

  VehicleVisitResultBuilder() {
    VehicleVisitResult._defaults(this);
  }

  VehicleVisitResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleVisitResult other) {
    _$v = other as _$VehicleVisitResult;
  }

  @override
  void update(void Function(VehicleVisitResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleVisitResult build() => _build();

  _$VehicleVisitResult _build() {
    _$VehicleVisitResult _$result;
    try {
      _$result = _$v ??
          _$VehicleVisitResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'VehicleVisitResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
