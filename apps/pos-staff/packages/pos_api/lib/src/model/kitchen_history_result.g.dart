// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_history_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenHistoryResult extends KitchenHistoryResult {
  @override
  final KitchenHistory data;

  factory _$KitchenHistoryResult(
          [void Function(KitchenHistoryResultBuilder)? updates]) =>
      (KitchenHistoryResultBuilder()..update(updates))._build();

  _$KitchenHistoryResult._({required this.data}) : super._();
  @override
  KitchenHistoryResult rebuild(
          void Function(KitchenHistoryResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenHistoryResultBuilder toBuilder() =>
      KitchenHistoryResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenHistoryResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'KitchenHistoryResult')
          ..add('data', data))
        .toString();
  }
}

class KitchenHistoryResultBuilder
    implements Builder<KitchenHistoryResult, KitchenHistoryResultBuilder> {
  _$KitchenHistoryResult? _$v;

  KitchenHistoryBuilder? _data;
  KitchenHistoryBuilder get data => _$this._data ??= KitchenHistoryBuilder();
  set data(KitchenHistoryBuilder? data) => _$this._data = data;

  KitchenHistoryResultBuilder() {
    KitchenHistoryResult._defaults(this);
  }

  KitchenHistoryResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenHistoryResult other) {
    _$v = other as _$KitchenHistoryResult;
  }

  @override
  void update(void Function(KitchenHistoryResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenHistoryResult build() => _build();

  _$KitchenHistoryResult _build() {
    _$KitchenHistoryResult _$result;
    try {
      _$result = _$v ??
          _$KitchenHistoryResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenHistoryResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
