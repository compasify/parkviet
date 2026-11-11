// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_print_claim200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosDevicePrintClaim200Response extends PosDevicePrintClaim200Response {
  @override
  final PrintJobClaim? data;

  factory _$PosDevicePrintClaim200Response(
          [void Function(PosDevicePrintClaim200ResponseBuilder)? updates]) =>
      (PosDevicePrintClaim200ResponseBuilder()..update(updates))._build();

  _$PosDevicePrintClaim200Response._({this.data}) : super._();
  @override
  PosDevicePrintClaim200Response rebuild(
          void Function(PosDevicePrintClaim200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDevicePrintClaim200ResponseBuilder toBuilder() =>
      PosDevicePrintClaim200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDevicePrintClaim200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosDevicePrintClaim200Response')
          ..add('data', data))
        .toString();
  }
}

class PosDevicePrintClaim200ResponseBuilder
    implements
        Builder<PosDevicePrintClaim200Response,
            PosDevicePrintClaim200ResponseBuilder> {
  _$PosDevicePrintClaim200Response? _$v;

  PrintJobClaimBuilder? _data;
  PrintJobClaimBuilder get data => _$this._data ??= PrintJobClaimBuilder();
  set data(PrintJobClaimBuilder? data) => _$this._data = data;

  PosDevicePrintClaim200ResponseBuilder() {
    PosDevicePrintClaim200Response._defaults(this);
  }

  PosDevicePrintClaim200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDevicePrintClaim200Response other) {
    _$v = other as _$PosDevicePrintClaim200Response;
  }

  @override
  void update(void Function(PosDevicePrintClaim200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDevicePrintClaim200Response build() => _build();

  _$PosDevicePrintClaim200Response _build() {
    _$PosDevicePrintClaim200Response _$result;
    try {
      _$result = _$v ??
          _$PosDevicePrintClaim200Response._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosDevicePrintClaim200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
