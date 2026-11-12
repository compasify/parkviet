// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_open_order_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnerOpenOrderResult extends OwnerOpenOrderResult {
  @override
  final OwnerOpenOrder data;

  factory _$OwnerOpenOrderResult(
          [void Function(OwnerOpenOrderResultBuilder)? updates]) =>
      (OwnerOpenOrderResultBuilder()..update(updates))._build();

  _$OwnerOpenOrderResult._({required this.data}) : super._();
  @override
  OwnerOpenOrderResult rebuild(
          void Function(OwnerOpenOrderResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerOpenOrderResultBuilder toBuilder() =>
      OwnerOpenOrderResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerOpenOrderResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OwnerOpenOrderResult')
          ..add('data', data))
        .toString();
  }
}

class OwnerOpenOrderResultBuilder
    implements Builder<OwnerOpenOrderResult, OwnerOpenOrderResultBuilder> {
  _$OwnerOpenOrderResult? _$v;

  OwnerOpenOrderBuilder? _data;
  OwnerOpenOrderBuilder get data => _$this._data ??= OwnerOpenOrderBuilder();
  set data(OwnerOpenOrderBuilder? data) => _$this._data = data;

  OwnerOpenOrderResultBuilder() {
    OwnerOpenOrderResult._defaults(this);
  }

  OwnerOpenOrderResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerOpenOrderResult other) {
    _$v = other as _$OwnerOpenOrderResult;
  }

  @override
  void update(void Function(OwnerOpenOrderResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerOpenOrderResult build() => _build();

  _$OwnerOpenOrderResult _build() {
    _$OwnerOpenOrderResult _$result;
    try {
      _$result = _$v ??
          _$OwnerOpenOrderResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OwnerOpenOrderResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
