// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_order_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GuestOrderList extends GuestOrderList {
  @override
  final BuiltList<GuestOrder> data;
  @override
  final BuiltMap<String, JsonObject?> meta;

  factory _$GuestOrderList([void Function(GuestOrderListBuilder)? updates]) =>
      (GuestOrderListBuilder()..update(updates))._build();

  _$GuestOrderList._({required this.data, required this.meta}) : super._();
  @override
  GuestOrderList rebuild(void Function(GuestOrderListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestOrderListBuilder toBuilder() => GuestOrderListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestOrderList && data == other.data && meta == other.meta;
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
    return (newBuiltValueToStringHelper(r'GuestOrderList')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GuestOrderListBuilder
    implements Builder<GuestOrderList, GuestOrderListBuilder> {
  _$GuestOrderList? _$v;

  ListBuilder<GuestOrder>? _data;
  ListBuilder<GuestOrder> get data =>
      _$this._data ??= ListBuilder<GuestOrder>();
  set data(ListBuilder<GuestOrder>? data) => _$this._data = data;

  MapBuilder<String, JsonObject?>? _meta;
  MapBuilder<String, JsonObject?> get meta =>
      _$this._meta ??= MapBuilder<String, JsonObject?>();
  set meta(MapBuilder<String, JsonObject?>? meta) => _$this._meta = meta;

  GuestOrderListBuilder() {
    GuestOrderList._defaults(this);
  }

  GuestOrderListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestOrderList other) {
    _$v = other as _$GuestOrderList;
  }

  @override
  void update(void Function(GuestOrderListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestOrderList build() => _build();

  _$GuestOrderList _build() {
    _$GuestOrderList _$result;
    try {
      _$result = _$v ??
          _$GuestOrderList._(
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
            r'GuestOrderList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
