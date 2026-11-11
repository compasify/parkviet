// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_board_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenBoardResult extends KitchenBoardResult {
  @override
  final KitchenBoard data;

  factory _$KitchenBoardResult(
          [void Function(KitchenBoardResultBuilder)? updates]) =>
      (KitchenBoardResultBuilder()..update(updates))._build();

  _$KitchenBoardResult._({required this.data}) : super._();
  @override
  KitchenBoardResult rebuild(
          void Function(KitchenBoardResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenBoardResultBuilder toBuilder() =>
      KitchenBoardResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenBoardResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'KitchenBoardResult')
          ..add('data', data))
        .toString();
  }
}

class KitchenBoardResultBuilder
    implements Builder<KitchenBoardResult, KitchenBoardResultBuilder> {
  _$KitchenBoardResult? _$v;

  KitchenBoardBuilder? _data;
  KitchenBoardBuilder get data => _$this._data ??= KitchenBoardBuilder();
  set data(KitchenBoardBuilder? data) => _$this._data = data;

  KitchenBoardResultBuilder() {
    KitchenBoardResult._defaults(this);
  }

  KitchenBoardResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenBoardResult other) {
    _$v = other as _$KitchenBoardResult;
  }

  @override
  void update(void Function(KitchenBoardResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenBoardResult build() => _build();

  _$KitchenBoardResult _build() {
    _$KitchenBoardResult _$result;
    try {
      _$result = _$v ??
          _$KitchenBoardResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenBoardResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
