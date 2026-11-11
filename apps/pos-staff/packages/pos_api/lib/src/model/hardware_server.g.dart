// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hardware_server.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HardwareServer extends HardwareServer {
  @override
  final String publicBaseUrl;
  @override
  final String tlsMode;
  @override
  final int outboundPending;
  @override
  final int outboundFailed;
  @override
  final int outboundOldestPendingAgeSeconds;
  @override
  final DateTime vietqrLastReceivedAt;

  factory _$HardwareServer([void Function(HardwareServerBuilder)? updates]) =>
      (HardwareServerBuilder()..update(updates))._build();

  _$HardwareServer._(
      {required this.publicBaseUrl,
      required this.tlsMode,
      required this.outboundPending,
      required this.outboundFailed,
      required this.outboundOldestPendingAgeSeconds,
      required this.vietqrLastReceivedAt})
      : super._();
  @override
  HardwareServer rebuild(void Function(HardwareServerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HardwareServerBuilder toBuilder() => HardwareServerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HardwareServer &&
        publicBaseUrl == other.publicBaseUrl &&
        tlsMode == other.tlsMode &&
        outboundPending == other.outboundPending &&
        outboundFailed == other.outboundFailed &&
        outboundOldestPendingAgeSeconds ==
            other.outboundOldestPendingAgeSeconds &&
        vietqrLastReceivedAt == other.vietqrLastReceivedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publicBaseUrl.hashCode);
    _$hash = $jc(_$hash, tlsMode.hashCode);
    _$hash = $jc(_$hash, outboundPending.hashCode);
    _$hash = $jc(_$hash, outboundFailed.hashCode);
    _$hash = $jc(_$hash, outboundOldestPendingAgeSeconds.hashCode);
    _$hash = $jc(_$hash, vietqrLastReceivedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HardwareServer')
          ..add('publicBaseUrl', publicBaseUrl)
          ..add('tlsMode', tlsMode)
          ..add('outboundPending', outboundPending)
          ..add('outboundFailed', outboundFailed)
          ..add('outboundOldestPendingAgeSeconds',
              outboundOldestPendingAgeSeconds)
          ..add('vietqrLastReceivedAt', vietqrLastReceivedAt))
        .toString();
  }
}

class HardwareServerBuilder
    implements Builder<HardwareServer, HardwareServerBuilder> {
  _$HardwareServer? _$v;

  String? _publicBaseUrl;
  String? get publicBaseUrl => _$this._publicBaseUrl;
  set publicBaseUrl(String? publicBaseUrl) =>
      _$this._publicBaseUrl = publicBaseUrl;

  String? _tlsMode;
  String? get tlsMode => _$this._tlsMode;
  set tlsMode(String? tlsMode) => _$this._tlsMode = tlsMode;

  int? _outboundPending;
  int? get outboundPending => _$this._outboundPending;
  set outboundPending(int? outboundPending) =>
      _$this._outboundPending = outboundPending;

  int? _outboundFailed;
  int? get outboundFailed => _$this._outboundFailed;
  set outboundFailed(int? outboundFailed) =>
      _$this._outboundFailed = outboundFailed;

  int? _outboundOldestPendingAgeSeconds;
  int? get outboundOldestPendingAgeSeconds =>
      _$this._outboundOldestPendingAgeSeconds;
  set outboundOldestPendingAgeSeconds(int? outboundOldestPendingAgeSeconds) =>
      _$this._outboundOldestPendingAgeSeconds = outboundOldestPendingAgeSeconds;

  DateTime? _vietqrLastReceivedAt;
  DateTime? get vietqrLastReceivedAt => _$this._vietqrLastReceivedAt;
  set vietqrLastReceivedAt(DateTime? vietqrLastReceivedAt) =>
      _$this._vietqrLastReceivedAt = vietqrLastReceivedAt;

  HardwareServerBuilder() {
    HardwareServer._defaults(this);
  }

  HardwareServerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publicBaseUrl = $v.publicBaseUrl;
      _tlsMode = $v.tlsMode;
      _outboundPending = $v.outboundPending;
      _outboundFailed = $v.outboundFailed;
      _outboundOldestPendingAgeSeconds = $v.outboundOldestPendingAgeSeconds;
      _vietqrLastReceivedAt = $v.vietqrLastReceivedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HardwareServer other) {
    _$v = other as _$HardwareServer;
  }

  @override
  void update(void Function(HardwareServerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HardwareServer build() => _build();

  _$HardwareServer _build() {
    final _$result = _$v ??
        _$HardwareServer._(
          publicBaseUrl: BuiltValueNullFieldError.checkNotNull(
              publicBaseUrl, r'HardwareServer', 'publicBaseUrl'),
          tlsMode: BuiltValueNullFieldError.checkNotNull(
              tlsMode, r'HardwareServer', 'tlsMode'),
          outboundPending: BuiltValueNullFieldError.checkNotNull(
              outboundPending, r'HardwareServer', 'outboundPending'),
          outboundFailed: BuiltValueNullFieldError.checkNotNull(
              outboundFailed, r'HardwareServer', 'outboundFailed'),
          outboundOldestPendingAgeSeconds:
              BuiltValueNullFieldError.checkNotNull(
                  outboundOldestPendingAgeSeconds,
                  r'HardwareServer',
                  'outboundOldestPendingAgeSeconds'),
          vietqrLastReceivedAt: BuiltValueNullFieldError.checkNotNull(
              vietqrLastReceivedAt, r'HardwareServer', 'vietqrLastReceivedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
