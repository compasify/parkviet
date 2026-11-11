// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SystemStatusVersion extends SystemStatusVersion {
  @override
  final String app;
  @override
  final String spree;
  @override
  final String rails;

  factory _$SystemStatusVersion(
          [void Function(SystemStatusVersionBuilder)? updates]) =>
      (SystemStatusVersionBuilder()..update(updates))._build();

  _$SystemStatusVersion._(
      {required this.app, required this.spree, required this.rails})
      : super._();
  @override
  SystemStatusVersion rebuild(
          void Function(SystemStatusVersionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemStatusVersionBuilder toBuilder() =>
      SystemStatusVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemStatusVersion &&
        app == other.app &&
        spree == other.spree &&
        rails == other.rails;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, app.hashCode);
    _$hash = $jc(_$hash, spree.hashCode);
    _$hash = $jc(_$hash, rails.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemStatusVersion')
          ..add('app', app)
          ..add('spree', spree)
          ..add('rails', rails))
        .toString();
  }
}

class SystemStatusVersionBuilder
    implements Builder<SystemStatusVersion, SystemStatusVersionBuilder> {
  _$SystemStatusVersion? _$v;

  String? _app;
  String? get app => _$this._app;
  set app(String? app) => _$this._app = app;

  String? _spree;
  String? get spree => _$this._spree;
  set spree(String? spree) => _$this._spree = spree;

  String? _rails;
  String? get rails => _$this._rails;
  set rails(String? rails) => _$this._rails = rails;

  SystemStatusVersionBuilder() {
    SystemStatusVersion._defaults(this);
  }

  SystemStatusVersionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _app = $v.app;
      _spree = $v.spree;
      _rails = $v.rails;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemStatusVersion other) {
    _$v = other as _$SystemStatusVersion;
  }

  @override
  void update(void Function(SystemStatusVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemStatusVersion build() => _build();

  _$SystemStatusVersion _build() {
    final _$result = _$v ??
        _$SystemStatusVersion._(
          app: BuiltValueNullFieldError.checkNotNull(
              app, r'SystemStatusVersion', 'app'),
          spree: BuiltValueNullFieldError.checkNotNull(
              spree, r'SystemStatusVersion', 'spree'),
          rails: BuiltValueNullFieldError.checkNotNull(
              rails, r'SystemStatusVersion', 'rails'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
