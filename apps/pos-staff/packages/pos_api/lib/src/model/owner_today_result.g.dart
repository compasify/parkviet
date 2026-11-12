// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_today_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnerTodayResult extends OwnerTodayResult {
  @override
  final OwnerToday data;

  factory _$OwnerTodayResult(
          [void Function(OwnerTodayResultBuilder)? updates]) =>
      (OwnerTodayResultBuilder()..update(updates))._build();

  _$OwnerTodayResult._({required this.data}) : super._();
  @override
  OwnerTodayResult rebuild(void Function(OwnerTodayResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerTodayResultBuilder toBuilder() =>
      OwnerTodayResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerTodayResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OwnerTodayResult')..add('data', data))
        .toString();
  }
}

class OwnerTodayResultBuilder
    implements Builder<OwnerTodayResult, OwnerTodayResultBuilder> {
  _$OwnerTodayResult? _$v;

  OwnerTodayBuilder? _data;
  OwnerTodayBuilder get data => _$this._data ??= OwnerTodayBuilder();
  set data(OwnerTodayBuilder? data) => _$this._data = data;

  OwnerTodayResultBuilder() {
    OwnerTodayResult._defaults(this);
  }

  OwnerTodayResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerTodayResult other) {
    _$v = other as _$OwnerTodayResult;
  }

  @override
  void update(void Function(OwnerTodayResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerTodayResult build() => _build();

  _$OwnerTodayResult _build() {
    _$OwnerTodayResult _$result;
    try {
      _$result = _$v ??
          _$OwnerTodayResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OwnerTodayResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
