// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_request_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GuestRequestResult extends GuestRequestResult {
  @override
  final GuestRequest data;

  factory _$GuestRequestResult(
          [void Function(GuestRequestResultBuilder)? updates]) =>
      (GuestRequestResultBuilder()..update(updates))._build();

  _$GuestRequestResult._({required this.data}) : super._();
  @override
  GuestRequestResult rebuild(
          void Function(GuestRequestResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestRequestResultBuilder toBuilder() =>
      GuestRequestResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestRequestResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'GuestRequestResult')
          ..add('data', data))
        .toString();
  }
}

class GuestRequestResultBuilder
    implements Builder<GuestRequestResult, GuestRequestResultBuilder> {
  _$GuestRequestResult? _$v;

  GuestRequestBuilder? _data;
  GuestRequestBuilder get data => _$this._data ??= GuestRequestBuilder();
  set data(GuestRequestBuilder? data) => _$this._data = data;

  GuestRequestResultBuilder() {
    GuestRequestResult._defaults(this);
  }

  GuestRequestResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestRequestResult other) {
    _$v = other as _$GuestRequestResult;
  }

  @override
  void update(void Function(GuestRequestResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestRequestResult build() => _build();

  _$GuestRequestResult _build() {
    _$GuestRequestResult _$result;
    try {
      _$result = _$v ??
          _$GuestRequestResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GuestRequestResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
