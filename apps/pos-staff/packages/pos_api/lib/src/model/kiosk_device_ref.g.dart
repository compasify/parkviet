// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_device_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskDeviceRef extends KioskDeviceRef {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? platform;
  @override
  final String? appVersion;
  @override
  final String? lastSeenAt;

  factory _$KioskDeviceRef([void Function(KioskDeviceRefBuilder)? updates]) =>
      (KioskDeviceRefBuilder()..update(updates))._build();

  _$KioskDeviceRef._(
      {required this.id,
      required this.name,
      this.platform,
      this.appVersion,
      this.lastSeenAt})
      : super._();
  @override
  KioskDeviceRef rebuild(void Function(KioskDeviceRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskDeviceRefBuilder toBuilder() => KioskDeviceRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskDeviceRef &&
        id == other.id &&
        name == other.name &&
        platform == other.platform &&
        appVersion == other.appVersion &&
        lastSeenAt == other.lastSeenAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskDeviceRef')
          ..add('id', id)
          ..add('name', name)
          ..add('platform', platform)
          ..add('appVersion', appVersion)
          ..add('lastSeenAt', lastSeenAt))
        .toString();
  }
}

class KioskDeviceRefBuilder
    implements Builder<KioskDeviceRef, KioskDeviceRefBuilder> {
  _$KioskDeviceRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _platform;
  String? get platform => _$this._platform;
  set platform(String? platform) => _$this._platform = platform;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _lastSeenAt;
  String? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(String? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  KioskDeviceRefBuilder() {
    KioskDeviceRef._defaults(this);
  }

  KioskDeviceRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _platform = $v.platform;
      _appVersion = $v.appVersion;
      _lastSeenAt = $v.lastSeenAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskDeviceRef other) {
    _$v = other as _$KioskDeviceRef;
  }

  @override
  void update(void Function(KioskDeviceRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskDeviceRef build() => _build();

  _$KioskDeviceRef _build() {
    final _$result = _$v ??
        _$KioskDeviceRef._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'KioskDeviceRef', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KioskDeviceRef', 'name'),
          platform: platform,
          appVersion: appVersion,
          lastSeenAt: lastSeenAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
