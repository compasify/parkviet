// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendant_assignment_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AttendantAssignmentResult extends AttendantAssignmentResult {
  @override
  final AttendantAssignment data;

  factory _$AttendantAssignmentResult(
          [void Function(AttendantAssignmentResultBuilder)? updates]) =>
      (AttendantAssignmentResultBuilder()..update(updates))._build();

  _$AttendantAssignmentResult._({required this.data}) : super._();
  @override
  AttendantAssignmentResult rebuild(
          void Function(AttendantAssignmentResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AttendantAssignmentResultBuilder toBuilder() =>
      AttendantAssignmentResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AttendantAssignmentResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'AttendantAssignmentResult')
          ..add('data', data))
        .toString();
  }
}

class AttendantAssignmentResultBuilder
    implements
        Builder<AttendantAssignmentResult, AttendantAssignmentResultBuilder> {
  _$AttendantAssignmentResult? _$v;

  AttendantAssignmentBuilder? _data;
  AttendantAssignmentBuilder get data =>
      _$this._data ??= AttendantAssignmentBuilder();
  set data(AttendantAssignmentBuilder? data) => _$this._data = data;

  AttendantAssignmentResultBuilder() {
    AttendantAssignmentResult._defaults(this);
  }

  AttendantAssignmentResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AttendantAssignmentResult other) {
    _$v = other as _$AttendantAssignmentResult;
  }

  @override
  void update(void Function(AttendantAssignmentResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AttendantAssignmentResult build() => _build();

  _$AttendantAssignmentResult _build() {
    _$AttendantAssignmentResult _$result;
    try {
      _$result = _$v ??
          _$AttendantAssignmentResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AttendantAssignmentResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
