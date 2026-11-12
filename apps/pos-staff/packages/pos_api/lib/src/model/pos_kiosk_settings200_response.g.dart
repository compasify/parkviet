// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kiosk_settings200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKioskSettings200Response extends PosKioskSettings200Response {
  @override
  final KioskSettings data;

  factory _$PosKioskSettings200Response(
          [void Function(PosKioskSettings200ResponseBuilder)? updates]) =>
      (PosKioskSettings200ResponseBuilder()..update(updates))._build();

  _$PosKioskSettings200Response._({required this.data}) : super._();
  @override
  PosKioskSettings200Response rebuild(
          void Function(PosKioskSettings200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKioskSettings200ResponseBuilder toBuilder() =>
      PosKioskSettings200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKioskSettings200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosKioskSettings200Response')
          ..add('data', data))
        .toString();
  }
}

class PosKioskSettings200ResponseBuilder
    implements
        Builder<PosKioskSettings200Response,
            PosKioskSettings200ResponseBuilder> {
  _$PosKioskSettings200Response? _$v;

  KioskSettingsBuilder? _data;
  KioskSettingsBuilder get data => _$this._data ??= KioskSettingsBuilder();
  set data(KioskSettingsBuilder? data) => _$this._data = data;

  PosKioskSettings200ResponseBuilder() {
    PosKioskSettings200Response._defaults(this);
  }

  PosKioskSettings200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKioskSettings200Response other) {
    _$v = other as _$PosKioskSettings200Response;
  }

  @override
  void update(void Function(PosKioskSettings200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKioskSettings200Response build() => _build();

  _$PosKioskSettings200Response _build() {
    _$PosKioskSettings200Response _$result;
    try {
      _$result = _$v ??
          _$PosKioskSettings200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKioskSettings200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
