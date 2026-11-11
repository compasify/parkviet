// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_pair_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DevicePairResult extends DevicePairResult {
  @override
  final Device device;
  @override
  final String token;

  factory _$DevicePairResult(
          [void Function(DevicePairResultBuilder)? updates]) =>
      (DevicePairResultBuilder()..update(updates))._build();

  _$DevicePairResult._({required this.device, required this.token}) : super._();
  @override
  DevicePairResult rebuild(void Function(DevicePairResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DevicePairResultBuilder toBuilder() =>
      DevicePairResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DevicePairResult &&
        device == other.device &&
        token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, device.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DevicePairResult')
          ..add('device', device)
          ..add('token', token))
        .toString();
  }
}

class DevicePairResultBuilder
    implements Builder<DevicePairResult, DevicePairResultBuilder> {
  _$DevicePairResult? _$v;

  DeviceBuilder? _device;
  DeviceBuilder get device => _$this._device ??= DeviceBuilder();
  set device(DeviceBuilder? device) => _$this._device = device;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  DevicePairResultBuilder() {
    DevicePairResult._defaults(this);
  }

  DevicePairResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _device = $v.device.toBuilder();
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DevicePairResult other) {
    _$v = other as _$DevicePairResult;
  }

  @override
  void update(void Function(DevicePairResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DevicePairResult build() => _build();

  _$DevicePairResult _build() {
    _$DevicePairResult _$result;
    try {
      _$result = _$v ??
          _$DevicePairResult._(
            device: device.build(),
            token: BuiltValueNullFieldError.checkNotNull(
                token, r'DevicePairResult', 'token'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'device';
        device.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DevicePairResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
