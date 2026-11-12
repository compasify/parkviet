// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kiosk_state200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKioskState200Response extends PosKioskState200Response {
  @override
  final KioskState data;

  factory _$PosKioskState200Response(
          [void Function(PosKioskState200ResponseBuilder)? updates]) =>
      (PosKioskState200ResponseBuilder()..update(updates))._build();

  _$PosKioskState200Response._({required this.data}) : super._();
  @override
  PosKioskState200Response rebuild(
          void Function(PosKioskState200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKioskState200ResponseBuilder toBuilder() =>
      PosKioskState200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKioskState200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosKioskState200Response')
          ..add('data', data))
        .toString();
  }
}

class PosKioskState200ResponseBuilder
    implements
        Builder<PosKioskState200Response, PosKioskState200ResponseBuilder> {
  _$PosKioskState200Response? _$v;

  KioskStateBuilder? _data;
  KioskStateBuilder get data => _$this._data ??= KioskStateBuilder();
  set data(KioskStateBuilder? data) => _$this._data = data;

  PosKioskState200ResponseBuilder() {
    PosKioskState200Response._defaults(this);
  }

  PosKioskState200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKioskState200Response other) {
    _$v = other as _$PosKioskState200Response;
  }

  @override
  void update(void Function(PosKioskState200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKioskState200Response build() => _build();

  _$PosKioskState200Response _build() {
    _$PosKioskState200Response _$result;
    try {
      _$result = _$v ??
          _$PosKioskState200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKioskState200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
