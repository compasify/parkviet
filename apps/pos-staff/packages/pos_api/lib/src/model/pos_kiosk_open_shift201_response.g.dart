// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kiosk_open_shift201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKioskOpenShift201Response extends PosKioskOpenShift201Response {
  @override
  final KioskShift data;

  factory _$PosKioskOpenShift201Response(
          [void Function(PosKioskOpenShift201ResponseBuilder)? updates]) =>
      (PosKioskOpenShift201ResponseBuilder()..update(updates))._build();

  _$PosKioskOpenShift201Response._({required this.data}) : super._();
  @override
  PosKioskOpenShift201Response rebuild(
          void Function(PosKioskOpenShift201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKioskOpenShift201ResponseBuilder toBuilder() =>
      PosKioskOpenShift201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKioskOpenShift201Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosKioskOpenShift201Response')
          ..add('data', data))
        .toString();
  }
}

class PosKioskOpenShift201ResponseBuilder
    implements
        Builder<PosKioskOpenShift201Response,
            PosKioskOpenShift201ResponseBuilder> {
  _$PosKioskOpenShift201Response? _$v;

  KioskShiftBuilder? _data;
  KioskShiftBuilder get data => _$this._data ??= KioskShiftBuilder();
  set data(KioskShiftBuilder? data) => _$this._data = data;

  PosKioskOpenShift201ResponseBuilder() {
    PosKioskOpenShift201Response._defaults(this);
  }

  PosKioskOpenShift201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKioskOpenShift201Response other) {
    _$v = other as _$PosKioskOpenShift201Response;
  }

  @override
  void update(void Function(PosKioskOpenShift201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKioskOpenShift201Response build() => _build();

  _$PosKioskOpenShift201Response _build() {
    _$PosKioskOpenShift201Response _$result;
    try {
      _$result = _$v ??
          _$PosKioskOpenShift201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKioskOpenShift201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
