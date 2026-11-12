// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_visit_void_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleVisitVoidInput extends VehicleVisitVoidInput {
  @override
  final String reason;

  factory _$VehicleVisitVoidInput(
          [void Function(VehicleVisitVoidInputBuilder)? updates]) =>
      (VehicleVisitVoidInputBuilder()..update(updates))._build();

  _$VehicleVisitVoidInput._({required this.reason}) : super._();
  @override
  VehicleVisitVoidInput rebuild(
          void Function(VehicleVisitVoidInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleVisitVoidInputBuilder toBuilder() =>
      VehicleVisitVoidInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleVisitVoidInput && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleVisitVoidInput')
          ..add('reason', reason))
        .toString();
  }
}

class VehicleVisitVoidInputBuilder
    implements Builder<VehicleVisitVoidInput, VehicleVisitVoidInputBuilder> {
  _$VehicleVisitVoidInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  VehicleVisitVoidInputBuilder() {
    VehicleVisitVoidInput._defaults(this);
  }

  VehicleVisitVoidInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleVisitVoidInput other) {
    _$v = other as _$VehicleVisitVoidInput;
  }

  @override
  void update(void Function(VehicleVisitVoidInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleVisitVoidInput build() => _build();

  _$VehicleVisitVoidInput _build() {
    final _$result = _$v ??
        _$VehicleVisitVoidInput._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'VehicleVisitVoidInput', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
