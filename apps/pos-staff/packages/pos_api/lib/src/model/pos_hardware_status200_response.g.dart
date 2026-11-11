// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_hardware_status200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosHardwareStatus200Response extends PosHardwareStatus200Response {
  @override
  final HardwareStatus data;

  factory _$PosHardwareStatus200Response(
          [void Function(PosHardwareStatus200ResponseBuilder)? updates]) =>
      (PosHardwareStatus200ResponseBuilder()..update(updates))._build();

  _$PosHardwareStatus200Response._({required this.data}) : super._();
  @override
  PosHardwareStatus200Response rebuild(
          void Function(PosHardwareStatus200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosHardwareStatus200ResponseBuilder toBuilder() =>
      PosHardwareStatus200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosHardwareStatus200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosHardwareStatus200Response')
          ..add('data', data))
        .toString();
  }
}

class PosHardwareStatus200ResponseBuilder
    implements
        Builder<PosHardwareStatus200Response,
            PosHardwareStatus200ResponseBuilder> {
  _$PosHardwareStatus200Response? _$v;

  HardwareStatusBuilder? _data;
  HardwareStatusBuilder get data => _$this._data ??= HardwareStatusBuilder();
  set data(HardwareStatusBuilder? data) => _$this._data = data;

  PosHardwareStatus200ResponseBuilder() {
    PosHardwareStatus200Response._defaults(this);
  }

  PosHardwareStatus200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosHardwareStatus200Response other) {
    _$v = other as _$PosHardwareStatus200Response;
  }

  @override
  void update(void Function(PosHardwareStatus200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosHardwareStatus200Response build() => _build();

  _$PosHardwareStatus200Response _build() {
    _$PosHardwareStatus200Response _$result;
    try {
      _$result = _$v ??
          _$PosHardwareStatus200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosHardwareStatus200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
