// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_order_accept_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GuestOrderAcceptResult extends GuestOrderAcceptResult {
  @override
  final GuestOrder data;
  @override
  final GuestOrderAcceptMeta meta;

  factory _$GuestOrderAcceptResult(
          [void Function(GuestOrderAcceptResultBuilder)? updates]) =>
      (GuestOrderAcceptResultBuilder()..update(updates))._build();

  _$GuestOrderAcceptResult._({required this.data, required this.meta})
      : super._();
  @override
  GuestOrderAcceptResult rebuild(
          void Function(GuestOrderAcceptResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestOrderAcceptResultBuilder toBuilder() =>
      GuestOrderAcceptResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestOrderAcceptResult &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GuestOrderAcceptResult')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GuestOrderAcceptResultBuilder
    implements Builder<GuestOrderAcceptResult, GuestOrderAcceptResultBuilder> {
  _$GuestOrderAcceptResult? _$v;

  GuestOrderBuilder? _data;
  GuestOrderBuilder get data => _$this._data ??= GuestOrderBuilder();
  set data(GuestOrderBuilder? data) => _$this._data = data;

  GuestOrderAcceptMetaBuilder? _meta;
  GuestOrderAcceptMetaBuilder get meta =>
      _$this._meta ??= GuestOrderAcceptMetaBuilder();
  set meta(GuestOrderAcceptMetaBuilder? meta) => _$this._meta = meta;

  GuestOrderAcceptResultBuilder() {
    GuestOrderAcceptResult._defaults(this);
  }

  GuestOrderAcceptResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestOrderAcceptResult other) {
    _$v = other as _$GuestOrderAcceptResult;
  }

  @override
  void update(void Function(GuestOrderAcceptResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestOrderAcceptResult build() => _build();

  _$GuestOrderAcceptResult _build() {
    _$GuestOrderAcceptResult _$result;
    try {
      _$result = _$v ??
          _$GuestOrderAcceptResult._(
            data: data.build(),
            meta: meta.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GuestOrderAcceptResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
