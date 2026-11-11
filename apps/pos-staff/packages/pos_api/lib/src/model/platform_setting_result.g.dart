// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_setting_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformSettingResult extends PlatformSettingResult {
  @override
  final PlatformSetting data;

  factory _$PlatformSettingResult(
          [void Function(PlatformSettingResultBuilder)? updates]) =>
      (PlatformSettingResultBuilder()..update(updates))._build();

  _$PlatformSettingResult._({required this.data}) : super._();
  @override
  PlatformSettingResult rebuild(
          void Function(PlatformSettingResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformSettingResultBuilder toBuilder() =>
      PlatformSettingResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformSettingResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PlatformSettingResult')
          ..add('data', data))
        .toString();
  }
}

class PlatformSettingResultBuilder
    implements Builder<PlatformSettingResult, PlatformSettingResultBuilder> {
  _$PlatformSettingResult? _$v;

  PlatformSettingBuilder? _data;
  PlatformSettingBuilder get data => _$this._data ??= PlatformSettingBuilder();
  set data(PlatformSettingBuilder? data) => _$this._data = data;

  PlatformSettingResultBuilder() {
    PlatformSettingResult._defaults(this);
  }

  PlatformSettingResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformSettingResult other) {
    _$v = other as _$PlatformSettingResult;
  }

  @override
  void update(void Function(PlatformSettingResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformSettingResult build() => _build();

  _$PlatformSettingResult _build() {
    _$PlatformSettingResult _$result;
    try {
      _$result = _$v ??
          _$PlatformSettingResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformSettingResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
