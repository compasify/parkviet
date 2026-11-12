// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kiosk_close_shift200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKioskCloseShift200Response extends PosKioskCloseShift200Response {
  @override
  final KioskShiftClosure data;

  factory _$PosKioskCloseShift200Response(
          [void Function(PosKioskCloseShift200ResponseBuilder)? updates]) =>
      (PosKioskCloseShift200ResponseBuilder()..update(updates))._build();

  _$PosKioskCloseShift200Response._({required this.data}) : super._();
  @override
  PosKioskCloseShift200Response rebuild(
          void Function(PosKioskCloseShift200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKioskCloseShift200ResponseBuilder toBuilder() =>
      PosKioskCloseShift200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKioskCloseShift200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosKioskCloseShift200Response')
          ..add('data', data))
        .toString();
  }
}

class PosKioskCloseShift200ResponseBuilder
    implements
        Builder<PosKioskCloseShift200Response,
            PosKioskCloseShift200ResponseBuilder> {
  _$PosKioskCloseShift200Response? _$v;

  KioskShiftClosureBuilder? _data;
  KioskShiftClosureBuilder get data =>
      _$this._data ??= KioskShiftClosureBuilder();
  set data(KioskShiftClosureBuilder? data) => _$this._data = data;

  PosKioskCloseShift200ResponseBuilder() {
    PosKioskCloseShift200Response._defaults(this);
  }

  PosKioskCloseShift200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKioskCloseShift200Response other) {
    _$v = other as _$PosKioskCloseShift200Response;
  }

  @override
  void update(void Function(PosKioskCloseShift200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKioskCloseShift200Response build() => _build();

  _$PosKioskCloseShift200Response _build() {
    _$PosKioskCloseShift200Response _$result;
    try {
      _$result = _$v ??
          _$PosKioskCloseShift200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKioskCloseShift200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
