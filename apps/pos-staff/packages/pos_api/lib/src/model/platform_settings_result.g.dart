// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_settings_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformSettingsResult extends PlatformSettingsResult {
  @override
  final PlatformSettings data;

  factory _$PlatformSettingsResult(
          [void Function(PlatformSettingsResultBuilder)? updates]) =>
      (PlatformSettingsResultBuilder()..update(updates))._build();

  _$PlatformSettingsResult._({required this.data}) : super._();
  @override
  PlatformSettingsResult rebuild(
          void Function(PlatformSettingsResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformSettingsResultBuilder toBuilder() =>
      PlatformSettingsResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformSettingsResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PlatformSettingsResult')
          ..add('data', data))
        .toString();
  }
}

class PlatformSettingsResultBuilder
    implements Builder<PlatformSettingsResult, PlatformSettingsResultBuilder> {
  _$PlatformSettingsResult? _$v;

  PlatformSettingsBuilder? _data;
  PlatformSettingsBuilder get data =>
      _$this._data ??= PlatformSettingsBuilder();
  set data(PlatformSettingsBuilder? data) => _$this._data = data;

  PlatformSettingsResultBuilder() {
    PlatformSettingsResult._defaults(this);
  }

  PlatformSettingsResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformSettingsResult other) {
    _$v = other as _$PlatformSettingsResult;
  }

  @override
  void update(void Function(PlatformSettingsResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformSettingsResult build() => _build();

  _$PlatformSettingsResult _build() {
    _$PlatformSettingsResult _$result;
    try {
      _$result = _$v ??
          _$PlatformSettingsResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformSettingsResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
