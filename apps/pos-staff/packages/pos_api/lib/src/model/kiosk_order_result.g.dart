// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_order_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskOrderResult extends KioskOrderResult {
  @override
  final KioskOrder data;

  factory _$KioskOrderResult(
          [void Function(KioskOrderResultBuilder)? updates]) =>
      (KioskOrderResultBuilder()..update(updates))._build();

  _$KioskOrderResult._({required this.data}) : super._();
  @override
  KioskOrderResult rebuild(void Function(KioskOrderResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskOrderResultBuilder toBuilder() =>
      KioskOrderResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskOrderResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'KioskOrderResult')..add('data', data))
        .toString();
  }
}

class KioskOrderResultBuilder
    implements Builder<KioskOrderResult, KioskOrderResultBuilder> {
  _$KioskOrderResult? _$v;

  KioskOrderBuilder? _data;
  KioskOrderBuilder get data => _$this._data ??= KioskOrderBuilder();
  set data(KioskOrderBuilder? data) => _$this._data = data;

  KioskOrderResultBuilder() {
    KioskOrderResult._defaults(this);
  }

  KioskOrderResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskOrderResult other) {
    _$v = other as _$KioskOrderResult;
  }

  @override
  void update(void Function(KioskOrderResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskOrderResult build() => _build();

  _$KioskOrderResult _build() {
    _$KioskOrderResult _$result;
    try {
      _$result = _$v ??
          _$KioskOrderResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskOrderResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
