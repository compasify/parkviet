// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_relay_settings_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushRelaySettingsInput extends PushRelaySettingsInput {
  @override
  final String url;
  @override
  final String? key;

  factory _$PushRelaySettingsInput(
          [void Function(PushRelaySettingsInputBuilder)? updates]) =>
      (PushRelaySettingsInputBuilder()..update(updates))._build();

  _$PushRelaySettingsInput._({required this.url, this.key}) : super._();
  @override
  PushRelaySettingsInput rebuild(
          void Function(PushRelaySettingsInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushRelaySettingsInputBuilder toBuilder() =>
      PushRelaySettingsInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushRelaySettingsInput &&
        url == other.url &&
        key == other.key;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushRelaySettingsInput')
          ..add('url', url)
          ..add('key', key))
        .toString();
  }
}

class PushRelaySettingsInputBuilder
    implements Builder<PushRelaySettingsInput, PushRelaySettingsInputBuilder> {
  _$PushRelaySettingsInput? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  PushRelaySettingsInputBuilder() {
    PushRelaySettingsInput._defaults(this);
  }

  PushRelaySettingsInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _key = $v.key;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushRelaySettingsInput other) {
    _$v = other as _$PushRelaySettingsInput;
  }

  @override
  void update(void Function(PushRelaySettingsInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushRelaySettingsInput build() => _build();

  _$PushRelaySettingsInput _build() {
    final _$result = _$v ??
        _$PushRelaySettingsInput._(
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'PushRelaySettingsInput', 'url'),
          key: key,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
