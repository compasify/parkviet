// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformSettings extends PlatformSettings {
  @override
  final bool moduleEnabled;
  @override
  final BuiltList<PlatformSetting> platforms;

  factory _$PlatformSettings(
          [void Function(PlatformSettingsBuilder)? updates]) =>
      (PlatformSettingsBuilder()..update(updates))._build();

  _$PlatformSettings._({required this.moduleEnabled, required this.platforms})
      : super._();
  @override
  PlatformSettings rebuild(void Function(PlatformSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformSettingsBuilder toBuilder() =>
      PlatformSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformSettings &&
        moduleEnabled == other.moduleEnabled &&
        platforms == other.platforms;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, moduleEnabled.hashCode);
    _$hash = $jc(_$hash, platforms.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformSettings')
          ..add('moduleEnabled', moduleEnabled)
          ..add('platforms', platforms))
        .toString();
  }
}

class PlatformSettingsBuilder
    implements Builder<PlatformSettings, PlatformSettingsBuilder> {
  _$PlatformSettings? _$v;

  bool? _moduleEnabled;
  bool? get moduleEnabled => _$this._moduleEnabled;
  set moduleEnabled(bool? moduleEnabled) =>
      _$this._moduleEnabled = moduleEnabled;

  ListBuilder<PlatformSetting>? _platforms;
  ListBuilder<PlatformSetting> get platforms =>
      _$this._platforms ??= ListBuilder<PlatformSetting>();
  set platforms(ListBuilder<PlatformSetting>? platforms) =>
      _$this._platforms = platforms;

  PlatformSettingsBuilder() {
    PlatformSettings._defaults(this);
  }

  PlatformSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _moduleEnabled = $v.moduleEnabled;
      _platforms = $v.platforms.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformSettings other) {
    _$v = other as _$PlatformSettings;
  }

  @override
  void update(void Function(PlatformSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformSettings build() => _build();

  _$PlatformSettings _build() {
    _$PlatformSettings _$result;
    try {
      _$result = _$v ??
          _$PlatformSettings._(
            moduleEnabled: BuiltValueNullFieldError.checkNotNull(
                moduleEnabled, r'PlatformSettings', 'moduleEnabled'),
            platforms: platforms.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'platforms';
        platforms.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformSettings', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
