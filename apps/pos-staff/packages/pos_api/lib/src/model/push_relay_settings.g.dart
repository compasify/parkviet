// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_relay_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushRelaySettings extends PushRelaySettings {
  @override
  final String url;
  @override
  final bool keySet;
  @override
  final String? lastError;
  @override
  final DateTime? lastErrorAt;
  @override
  final DateTime? lastDeliveredAt;
  @override
  final DateTime? updatedAt;

  factory _$PushRelaySettings(
          [void Function(PushRelaySettingsBuilder)? updates]) =>
      (PushRelaySettingsBuilder()..update(updates))._build();

  _$PushRelaySettings._(
      {required this.url,
      required this.keySet,
      this.lastError,
      this.lastErrorAt,
      this.lastDeliveredAt,
      this.updatedAt})
      : super._();
  @override
  PushRelaySettings rebuild(void Function(PushRelaySettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushRelaySettingsBuilder toBuilder() =>
      PushRelaySettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushRelaySettings &&
        url == other.url &&
        keySet == other.keySet &&
        lastError == other.lastError &&
        lastErrorAt == other.lastErrorAt &&
        lastDeliveredAt == other.lastDeliveredAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, keySet.hashCode);
    _$hash = $jc(_$hash, lastError.hashCode);
    _$hash = $jc(_$hash, lastErrorAt.hashCode);
    _$hash = $jc(_$hash, lastDeliveredAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushRelaySettings')
          ..add('url', url)
          ..add('keySet', keySet)
          ..add('lastError', lastError)
          ..add('lastErrorAt', lastErrorAt)
          ..add('lastDeliveredAt', lastDeliveredAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PushRelaySettingsBuilder
    implements Builder<PushRelaySettings, PushRelaySettingsBuilder> {
  _$PushRelaySettings? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  bool? _keySet;
  bool? get keySet => _$this._keySet;
  set keySet(bool? keySet) => _$this._keySet = keySet;

  String? _lastError;
  String? get lastError => _$this._lastError;
  set lastError(String? lastError) => _$this._lastError = lastError;

  DateTime? _lastErrorAt;
  DateTime? get lastErrorAt => _$this._lastErrorAt;
  set lastErrorAt(DateTime? lastErrorAt) => _$this._lastErrorAt = lastErrorAt;

  DateTime? _lastDeliveredAt;
  DateTime? get lastDeliveredAt => _$this._lastDeliveredAt;
  set lastDeliveredAt(DateTime? lastDeliveredAt) =>
      _$this._lastDeliveredAt = lastDeliveredAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PushRelaySettingsBuilder() {
    PushRelaySettings._defaults(this);
  }

  PushRelaySettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _keySet = $v.keySet;
      _lastError = $v.lastError;
      _lastErrorAt = $v.lastErrorAt;
      _lastDeliveredAt = $v.lastDeliveredAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushRelaySettings other) {
    _$v = other as _$PushRelaySettings;
  }

  @override
  void update(void Function(PushRelaySettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushRelaySettings build() => _build();

  _$PushRelaySettings _build() {
    final _$result = _$v ??
        _$PushRelaySettings._(
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'PushRelaySettings', 'url'),
          keySet: BuiltValueNullFieldError.checkNotNull(
              keySet, r'PushRelaySettings', 'keySet'),
          lastError: lastError,
          lastErrorAt: lastErrorAt,
          lastDeliveredAt: lastDeliveredAt,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
