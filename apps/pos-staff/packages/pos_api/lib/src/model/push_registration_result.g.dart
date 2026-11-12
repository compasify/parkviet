// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_registration_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushRegistrationResult extends PushRegistrationResult {
  @override
  final PushRegistrationState data;

  factory _$PushRegistrationResult(
          [void Function(PushRegistrationResultBuilder)? updates]) =>
      (PushRegistrationResultBuilder()..update(updates))._build();

  _$PushRegistrationResult._({required this.data}) : super._();
  @override
  PushRegistrationResult rebuild(
          void Function(PushRegistrationResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushRegistrationResultBuilder toBuilder() =>
      PushRegistrationResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushRegistrationResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PushRegistrationResult')
          ..add('data', data))
        .toString();
  }
}

class PushRegistrationResultBuilder
    implements Builder<PushRegistrationResult, PushRegistrationResultBuilder> {
  _$PushRegistrationResult? _$v;

  PushRegistrationStateBuilder? _data;
  PushRegistrationStateBuilder get data =>
      _$this._data ??= PushRegistrationStateBuilder();
  set data(PushRegistrationStateBuilder? data) => _$this._data = data;

  PushRegistrationResultBuilder() {
    PushRegistrationResult._defaults(this);
  }

  PushRegistrationResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushRegistrationResult other) {
    _$v = other as _$PushRegistrationResult;
  }

  @override
  void update(void Function(PushRegistrationResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushRegistrationResult build() => _build();

  _$PushRegistrationResult _build() {
    _$PushRegistrationResult _$result;
    try {
      _$result = _$v ??
          _$PushRegistrationResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PushRegistrationResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
