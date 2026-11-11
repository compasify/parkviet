// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_board_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResourceBoardResult extends ResourceBoardResult {
  @override
  final ResourceBoard data;

  factory _$ResourceBoardResult(
          [void Function(ResourceBoardResultBuilder)? updates]) =>
      (ResourceBoardResultBuilder()..update(updates))._build();

  _$ResourceBoardResult._({required this.data}) : super._();
  @override
  ResourceBoardResult rebuild(
          void Function(ResourceBoardResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceBoardResultBuilder toBuilder() =>
      ResourceBoardResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceBoardResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ResourceBoardResult')
          ..add('data', data))
        .toString();
  }
}

class ResourceBoardResultBuilder
    implements Builder<ResourceBoardResult, ResourceBoardResultBuilder> {
  _$ResourceBoardResult? _$v;

  ResourceBoardBuilder? _data;
  ResourceBoardBuilder get data => _$this._data ??= ResourceBoardBuilder();
  set data(ResourceBoardBuilder? data) => _$this._data = data;

  ResourceBoardResultBuilder() {
    ResourceBoardResult._defaults(this);
  }

  ResourceBoardResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceBoardResult other) {
    _$v = other as _$ResourceBoardResult;
  }

  @override
  void update(void Function(ResourceBoardResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceBoardResult build() => _build();

  _$ResourceBoardResult _build() {
    _$ResourceBoardResult _$result;
    try {
      _$result = _$v ??
          _$ResourceBoardResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ResourceBoardResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
