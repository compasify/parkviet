// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_system_status200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosSystemStatus200Response extends PosSystemStatus200Response {
  @override
  final SystemStatus data;

  factory _$PosSystemStatus200Response(
          [void Function(PosSystemStatus200ResponseBuilder)? updates]) =>
      (PosSystemStatus200ResponseBuilder()..update(updates))._build();

  _$PosSystemStatus200Response._({required this.data}) : super._();
  @override
  PosSystemStatus200Response rebuild(
          void Function(PosSystemStatus200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosSystemStatus200ResponseBuilder toBuilder() =>
      PosSystemStatus200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosSystemStatus200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosSystemStatus200Response')
          ..add('data', data))
        .toString();
  }
}

class PosSystemStatus200ResponseBuilder
    implements
        Builder<PosSystemStatus200Response, PosSystemStatus200ResponseBuilder> {
  _$PosSystemStatus200Response? _$v;

  SystemStatusBuilder? _data;
  SystemStatusBuilder get data => _$this._data ??= SystemStatusBuilder();
  set data(SystemStatusBuilder? data) => _$this._data = data;

  PosSystemStatus200ResponseBuilder() {
    PosSystemStatus200Response._defaults(this);
  }

  PosSystemStatus200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosSystemStatus200Response other) {
    _$v = other as _$PosSystemStatus200Response;
  }

  @override
  void update(void Function(PosSystemStatus200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosSystemStatus200Response build() => _build();

  _$PosSystemStatus200Response _build() {
    _$PosSystemStatus200Response _$result;
    try {
      _$result = _$v ??
          _$PosSystemStatus200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosSystemStatus200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
