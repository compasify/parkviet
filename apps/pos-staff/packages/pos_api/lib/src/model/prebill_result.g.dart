// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prebill_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrebillResult extends PrebillResult {
  @override
  final PrebillOutcome data;

  factory _$PrebillResult([void Function(PrebillResultBuilder)? updates]) =>
      (PrebillResultBuilder()..update(updates))._build();

  _$PrebillResult._({required this.data}) : super._();
  @override
  PrebillResult rebuild(void Function(PrebillResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrebillResultBuilder toBuilder() => PrebillResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrebillResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PrebillResult')..add('data', data))
        .toString();
  }
}

class PrebillResultBuilder
    implements Builder<PrebillResult, PrebillResultBuilder> {
  _$PrebillResult? _$v;

  PrebillOutcomeBuilder? _data;
  PrebillOutcomeBuilder get data => _$this._data ??= PrebillOutcomeBuilder();
  set data(PrebillOutcomeBuilder? data) => _$this._data = data;

  PrebillResultBuilder() {
    PrebillResult._defaults(this);
  }

  PrebillResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrebillResult other) {
    _$v = other as _$PrebillResult;
  }

  @override
  void update(void Function(PrebillResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrebillResult build() => _build();

  _$PrebillResult _build() {
    _$PrebillResult _$result;
    try {
      _$result = _$v ??
          _$PrebillResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrebillResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
