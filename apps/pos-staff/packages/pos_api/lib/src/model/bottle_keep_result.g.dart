// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottle_keep_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BottleKeepResult extends BottleKeepResult {
  @override
  final BottleKeep data;

  factory _$BottleKeepResult(
          [void Function(BottleKeepResultBuilder)? updates]) =>
      (BottleKeepResultBuilder()..update(updates))._build();

  _$BottleKeepResult._({required this.data}) : super._();
  @override
  BottleKeepResult rebuild(void Function(BottleKeepResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BottleKeepResultBuilder toBuilder() =>
      BottleKeepResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BottleKeepResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'BottleKeepResult')..add('data', data))
        .toString();
  }
}

class BottleKeepResultBuilder
    implements Builder<BottleKeepResult, BottleKeepResultBuilder> {
  _$BottleKeepResult? _$v;

  BottleKeepBuilder? _data;
  BottleKeepBuilder get data => _$this._data ??= BottleKeepBuilder();
  set data(BottleKeepBuilder? data) => _$this._data = data;

  BottleKeepResultBuilder() {
    BottleKeepResult._defaults(this);
  }

  BottleKeepResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BottleKeepResult other) {
    _$v = other as _$BottleKeepResult;
  }

  @override
  void update(void Function(BottleKeepResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BottleKeepResult build() => _build();

  _$BottleKeepResult _build() {
    _$BottleKeepResult _$result;
    try {
      _$result = _$v ??
          _$BottleKeepResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BottleKeepResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
