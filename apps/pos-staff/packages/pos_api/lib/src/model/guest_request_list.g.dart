// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_request_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GuestRequestList extends GuestRequestList {
  @override
  final BuiltList<GuestRequest> data;
  @override
  final BuiltMap<String, JsonObject?> meta;

  factory _$GuestRequestList(
          [void Function(GuestRequestListBuilder)? updates]) =>
      (GuestRequestListBuilder()..update(updates))._build();

  _$GuestRequestList._({required this.data, required this.meta}) : super._();
  @override
  GuestRequestList rebuild(void Function(GuestRequestListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestRequestListBuilder toBuilder() =>
      GuestRequestListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestRequestList &&
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
    return (newBuiltValueToStringHelper(r'GuestRequestList')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class GuestRequestListBuilder
    implements Builder<GuestRequestList, GuestRequestListBuilder> {
  _$GuestRequestList? _$v;

  ListBuilder<GuestRequest>? _data;
  ListBuilder<GuestRequest> get data =>
      _$this._data ??= ListBuilder<GuestRequest>();
  set data(ListBuilder<GuestRequest>? data) => _$this._data = data;

  MapBuilder<String, JsonObject?>? _meta;
  MapBuilder<String, JsonObject?> get meta =>
      _$this._meta ??= MapBuilder<String, JsonObject?>();
  set meta(MapBuilder<String, JsonObject?>? meta) => _$this._meta = meta;

  GuestRequestListBuilder() {
    GuestRequestList._defaults(this);
  }

  GuestRequestListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestRequestList other) {
    _$v = other as _$GuestRequestList;
  }

  @override
  void update(void Function(GuestRequestListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestRequestList build() => _build();

  _$GuestRequestList _build() {
    _$GuestRequestList _$result;
    try {
      _$result = _$v ??
          _$GuestRequestList._(
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
            r'GuestRequestList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
