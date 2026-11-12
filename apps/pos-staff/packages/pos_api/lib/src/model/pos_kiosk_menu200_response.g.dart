// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kiosk_menu200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKioskMenu200Response extends PosKioskMenu200Response {
  @override
  final KioskMenu data;

  factory _$PosKioskMenu200Response(
          [void Function(PosKioskMenu200ResponseBuilder)? updates]) =>
      (PosKioskMenu200ResponseBuilder()..update(updates))._build();

  _$PosKioskMenu200Response._({required this.data}) : super._();
  @override
  PosKioskMenu200Response rebuild(
          void Function(PosKioskMenu200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKioskMenu200ResponseBuilder toBuilder() =>
      PosKioskMenu200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKioskMenu200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosKioskMenu200Response')
          ..add('data', data))
        .toString();
  }
}

class PosKioskMenu200ResponseBuilder
    implements
        Builder<PosKioskMenu200Response, PosKioskMenu200ResponseBuilder> {
  _$PosKioskMenu200Response? _$v;

  KioskMenuBuilder? _data;
  KioskMenuBuilder get data => _$this._data ??= KioskMenuBuilder();
  set data(KioskMenuBuilder? data) => _$this._data = data;

  PosKioskMenu200ResponseBuilder() {
    PosKioskMenu200Response._defaults(this);
  }

  PosKioskMenu200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKioskMenu200Response other) {
    _$v = other as _$PosKioskMenu200Response;
  }

  @override
  void update(void Function(PosKioskMenu200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKioskMenu200Response build() => _build();

  _$PosKioskMenu200Response _build() {
    _$PosKioskMenu200Response _$result;
    try {
      _$result = _$v ??
          _$PosKioskMenu200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKioskMenu200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
