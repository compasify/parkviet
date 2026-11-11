// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AreaResult extends AreaResult {
  @override
  final Area data;

  factory _$AreaResult([void Function(AreaResultBuilder)? updates]) =>
      (AreaResultBuilder()..update(updates))._build();

  _$AreaResult._({required this.data}) : super._();
  @override
  AreaResult rebuild(void Function(AreaResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AreaResultBuilder toBuilder() => AreaResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AreaResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'AreaResult')..add('data', data))
        .toString();
  }
}

class AreaResultBuilder implements Builder<AreaResult, AreaResultBuilder> {
  _$AreaResult? _$v;

  AreaBuilder? _data;
  AreaBuilder get data => _$this._data ??= AreaBuilder();
  set data(AreaBuilder? data) => _$this._data = data;

  AreaResultBuilder() {
    AreaResult._defaults(this);
  }

  AreaResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AreaResult other) {
    _$v = other as _$AreaResult;
  }

  @override
  void update(void Function(AreaResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AreaResult build() => _build();

  _$AreaResult _build() {
    _$AreaResult _$result;
    try {
      _$result = _$v ??
          _$AreaResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AreaResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
