// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResourceResult extends ResourceResult {
  @override
  final Resource data;

  factory _$ResourceResult([void Function(ResourceResultBuilder)? updates]) =>
      (ResourceResultBuilder()..update(updates))._build();

  _$ResourceResult._({required this.data}) : super._();
  @override
  ResourceResult rebuild(void Function(ResourceResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceResultBuilder toBuilder() => ResourceResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ResourceResult')..add('data', data))
        .toString();
  }
}

class ResourceResultBuilder
    implements Builder<ResourceResult, ResourceResultBuilder> {
  _$ResourceResult? _$v;

  ResourceBuilder? _data;
  ResourceBuilder get data => _$this._data ??= ResourceBuilder();
  set data(ResourceBuilder? data) => _$this._data = data;

  ResourceResultBuilder() {
    ResourceResult._defaults(this);
  }

  ResourceResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceResult other) {
    _$v = other as _$ResourceResult;
  }

  @override
  void update(void Function(ResourceResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceResult build() => _build();

  _$ResourceResult _build() {
    _$ResourceResult _$result;
    try {
      _$result = _$v ??
          _$ResourceResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ResourceResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
