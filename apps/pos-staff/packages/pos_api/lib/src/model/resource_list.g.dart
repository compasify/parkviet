// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResourceList extends ResourceList {
  @override
  final BuiltList<Resource> data;

  factory _$ResourceList([void Function(ResourceListBuilder)? updates]) =>
      (ResourceListBuilder()..update(updates))._build();

  _$ResourceList._({required this.data}) : super._();
  @override
  ResourceList rebuild(void Function(ResourceListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceListBuilder toBuilder() => ResourceListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ResourceList')..add('data', data))
        .toString();
  }
}

class ResourceListBuilder
    implements Builder<ResourceList, ResourceListBuilder> {
  _$ResourceList? _$v;

  ListBuilder<Resource>? _data;
  ListBuilder<Resource> get data => _$this._data ??= ListBuilder<Resource>();
  set data(ListBuilder<Resource>? data) => _$this._data = data;

  ResourceListBuilder() {
    ResourceList._defaults(this);
  }

  ResourceListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceList other) {
    _$v = other as _$ResourceList;
  }

  @override
  void update(void Function(ResourceListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceList build() => _build();

  _$ResourceList _build() {
    _$ResourceList _$result;
    try {
      _$result = _$v ??
          _$ResourceList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ResourceList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
