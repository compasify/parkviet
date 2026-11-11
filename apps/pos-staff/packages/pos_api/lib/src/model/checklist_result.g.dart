// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChecklistResult extends ChecklistResult {
  @override
  final ChecklistOutcome data;

  factory _$ChecklistResult([void Function(ChecklistResultBuilder)? updates]) =>
      (ChecklistResultBuilder()..update(updates))._build();

  _$ChecklistResult._({required this.data}) : super._();
  @override
  ChecklistResult rebuild(void Function(ChecklistResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChecklistResultBuilder toBuilder() => ChecklistResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChecklistResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ChecklistResult')..add('data', data))
        .toString();
  }
}

class ChecklistResultBuilder
    implements Builder<ChecklistResult, ChecklistResultBuilder> {
  _$ChecklistResult? _$v;

  ChecklistOutcomeBuilder? _data;
  ChecklistOutcomeBuilder get data =>
      _$this._data ??= ChecklistOutcomeBuilder();
  set data(ChecklistOutcomeBuilder? data) => _$this._data = data;

  ChecklistResultBuilder() {
    ChecklistResult._defaults(this);
  }

  ChecklistResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChecklistResult other) {
    _$v = other as _$ChecklistResult;
  }

  @override
  void update(void Function(ChecklistResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChecklistResult build() => _build();

  _$ChecklistResult _build() {
    _$ChecklistResult _$result;
    try {
      _$result = _$v ??
          _$ChecklistResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ChecklistResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
