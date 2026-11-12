// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_request_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApprovalRequestList extends ApprovalRequestList {
  @override
  final BuiltList<ApprovalRequest> data;
  @override
  final BuiltMap<String, JsonObject?> meta;

  factory _$ApprovalRequestList(
          [void Function(ApprovalRequestListBuilder)? updates]) =>
      (ApprovalRequestListBuilder()..update(updates))._build();

  _$ApprovalRequestList._({required this.data, required this.meta}) : super._();
  @override
  ApprovalRequestList rebuild(
          void Function(ApprovalRequestListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApprovalRequestListBuilder toBuilder() =>
      ApprovalRequestListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApprovalRequestList &&
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
    return (newBuiltValueToStringHelper(r'ApprovalRequestList')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class ApprovalRequestListBuilder
    implements Builder<ApprovalRequestList, ApprovalRequestListBuilder> {
  _$ApprovalRequestList? _$v;

  ListBuilder<ApprovalRequest>? _data;
  ListBuilder<ApprovalRequest> get data =>
      _$this._data ??= ListBuilder<ApprovalRequest>();
  set data(ListBuilder<ApprovalRequest>? data) => _$this._data = data;

  MapBuilder<String, JsonObject?>? _meta;
  MapBuilder<String, JsonObject?> get meta =>
      _$this._meta ??= MapBuilder<String, JsonObject?>();
  set meta(MapBuilder<String, JsonObject?>? meta) => _$this._meta = meta;

  ApprovalRequestListBuilder() {
    ApprovalRequestList._defaults(this);
  }

  ApprovalRequestListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApprovalRequestList other) {
    _$v = other as _$ApprovalRequestList;
  }

  @override
  void update(void Function(ApprovalRequestListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApprovalRequestList build() => _build();

  _$ApprovalRequestList _build() {
    _$ApprovalRequestList _$result;
    try {
      _$result = _$v ??
          _$ApprovalRequestList._(
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
            r'ApprovalRequestList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
