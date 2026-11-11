// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_order_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformOrderList extends PlatformOrderList {
  @override
  final BuiltList<PlatformOrder> data;
  @override
  final BuiltMap<String, JsonObject?> meta;

  factory _$PlatformOrderList(
          [void Function(PlatformOrderListBuilder)? updates]) =>
      (PlatformOrderListBuilder()..update(updates))._build();

  _$PlatformOrderList._({required this.data, required this.meta}) : super._();
  @override
  PlatformOrderList rebuild(void Function(PlatformOrderListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformOrderListBuilder toBuilder() =>
      PlatformOrderListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformOrderList &&
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
    return (newBuiltValueToStringHelper(r'PlatformOrderList')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class PlatformOrderListBuilder
    implements Builder<PlatformOrderList, PlatformOrderListBuilder> {
  _$PlatformOrderList? _$v;

  ListBuilder<PlatformOrder>? _data;
  ListBuilder<PlatformOrder> get data =>
      _$this._data ??= ListBuilder<PlatformOrder>();
  set data(ListBuilder<PlatformOrder>? data) => _$this._data = data;

  MapBuilder<String, JsonObject?>? _meta;
  MapBuilder<String, JsonObject?> get meta =>
      _$this._meta ??= MapBuilder<String, JsonObject?>();
  set meta(MapBuilder<String, JsonObject?>? meta) => _$this._meta = meta;

  PlatformOrderListBuilder() {
    PlatformOrderList._defaults(this);
  }

  PlatformOrderListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformOrderList other) {
    _$v = other as _$PlatformOrderList;
  }

  @override
  void update(void Function(PlatformOrderListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformOrderList build() => _build();

  _$PlatformOrderList _build() {
    _$PlatformOrderList _$result;
    try {
      _$result = _$v ??
          _$PlatformOrderList._(
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
            r'PlatformOrderList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
