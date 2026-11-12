// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_relay_settings_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushRelaySettingsResult extends PushRelaySettingsResult {
  @override
  final PushRelaySettings? data;

  factory _$PushRelaySettingsResult(
          [void Function(PushRelaySettingsResultBuilder)? updates]) =>
      (PushRelaySettingsResultBuilder()..update(updates))._build();

  _$PushRelaySettingsResult._({this.data}) : super._();
  @override
  PushRelaySettingsResult rebuild(
          void Function(PushRelaySettingsResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushRelaySettingsResultBuilder toBuilder() =>
      PushRelaySettingsResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushRelaySettingsResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PushRelaySettingsResult')
          ..add('data', data))
        .toString();
  }
}

class PushRelaySettingsResultBuilder
    implements
        Builder<PushRelaySettingsResult, PushRelaySettingsResultBuilder> {
  _$PushRelaySettingsResult? _$v;

  PushRelaySettingsBuilder? _data;
  PushRelaySettingsBuilder get data =>
      _$this._data ??= PushRelaySettingsBuilder();
  set data(PushRelaySettingsBuilder? data) => _$this._data = data;

  PushRelaySettingsResultBuilder() {
    PushRelaySettingsResult._defaults(this);
  }

  PushRelaySettingsResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushRelaySettingsResult other) {
    _$v = other as _$PushRelaySettingsResult;
  }

  @override
  void update(void Function(PushRelaySettingsResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushRelaySettingsResult build() => _build();

  _$PushRelaySettingsResult _build() {
    _$PushRelaySettingsResult _$result;
    try {
      _$result = _$v ??
          _$PushRelaySettingsResult._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PushRelaySettingsResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
