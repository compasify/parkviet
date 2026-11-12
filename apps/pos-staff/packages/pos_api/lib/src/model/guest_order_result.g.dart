// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_order_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GuestOrderResult extends GuestOrderResult {
  @override
  final GuestOrder data;

  factory _$GuestOrderResult(
          [void Function(GuestOrderResultBuilder)? updates]) =>
      (GuestOrderResultBuilder()..update(updates))._build();

  _$GuestOrderResult._({required this.data}) : super._();
  @override
  GuestOrderResult rebuild(void Function(GuestOrderResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestOrderResultBuilder toBuilder() =>
      GuestOrderResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestOrderResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'GuestOrderResult')..add('data', data))
        .toString();
  }
}

class GuestOrderResultBuilder
    implements Builder<GuestOrderResult, GuestOrderResultBuilder> {
  _$GuestOrderResult? _$v;

  GuestOrderBuilder? _data;
  GuestOrderBuilder get data => _$this._data ??= GuestOrderBuilder();
  set data(GuestOrderBuilder? data) => _$this._data = data;

  GuestOrderResultBuilder() {
    GuestOrderResult._defaults(this);
  }

  GuestOrderResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestOrderResult other) {
    _$v = other as _$GuestOrderResult;
  }

  @override
  void update(void Function(GuestOrderResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestOrderResult build() => _build();

  _$GuestOrderResult _build() {
    _$GuestOrderResult _$result;
    try {
      _$result = _$v ??
          _$GuestOrderResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GuestOrderResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
