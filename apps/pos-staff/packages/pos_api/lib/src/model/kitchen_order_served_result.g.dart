// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_order_served_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenOrderServedResult extends KitchenOrderServedResult {
  @override
  final KitchenOrderServedResultData data;

  factory _$KitchenOrderServedResult(
          [void Function(KitchenOrderServedResultBuilder)? updates]) =>
      (KitchenOrderServedResultBuilder()..update(updates))._build();

  _$KitchenOrderServedResult._({required this.data}) : super._();
  @override
  KitchenOrderServedResult rebuild(
          void Function(KitchenOrderServedResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenOrderServedResultBuilder toBuilder() =>
      KitchenOrderServedResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenOrderServedResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'KitchenOrderServedResult')
          ..add('data', data))
        .toString();
  }
}

class KitchenOrderServedResultBuilder
    implements
        Builder<KitchenOrderServedResult, KitchenOrderServedResultBuilder> {
  _$KitchenOrderServedResult? _$v;

  KitchenOrderServedResultDataBuilder? _data;
  KitchenOrderServedResultDataBuilder get data =>
      _$this._data ??= KitchenOrderServedResultDataBuilder();
  set data(KitchenOrderServedResultDataBuilder? data) => _$this._data = data;

  KitchenOrderServedResultBuilder() {
    KitchenOrderServedResult._defaults(this);
  }

  KitchenOrderServedResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenOrderServedResult other) {
    _$v = other as _$KitchenOrderServedResult;
  }

  @override
  void update(void Function(KitchenOrderServedResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenOrderServedResult build() => _build();

  _$KitchenOrderServedResult _build() {
    _$KitchenOrderServedResult _$result;
    try {
      _$result = _$v ??
          _$KitchenOrderServedResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenOrderServedResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
