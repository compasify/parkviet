// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_order_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformOrderResult extends PlatformOrderResult {
  @override
  final PlatformOrder data;

  factory _$PlatformOrderResult(
          [void Function(PlatformOrderResultBuilder)? updates]) =>
      (PlatformOrderResultBuilder()..update(updates))._build();

  _$PlatformOrderResult._({required this.data}) : super._();
  @override
  PlatformOrderResult rebuild(
          void Function(PlatformOrderResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformOrderResultBuilder toBuilder() =>
      PlatformOrderResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformOrderResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PlatformOrderResult')
          ..add('data', data))
        .toString();
  }
}

class PlatformOrderResultBuilder
    implements Builder<PlatformOrderResult, PlatformOrderResultBuilder> {
  _$PlatformOrderResult? _$v;

  PlatformOrderBuilder? _data;
  PlatformOrderBuilder get data => _$this._data ??= PlatformOrderBuilder();
  set data(PlatformOrderBuilder? data) => _$this._data = data;

  PlatformOrderResultBuilder() {
    PlatformOrderResult._defaults(this);
  }

  PlatformOrderResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformOrderResult other) {
    _$v = other as _$PlatformOrderResult;
  }

  @override
  void update(void Function(PlatformOrderResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformOrderResult build() => _build();

  _$PlatformOrderResult _build() {
    _$PlatformOrderResult _$result;
    try {
      _$result = _$v ??
          _$PlatformOrderResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformOrderResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
