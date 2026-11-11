// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_order_settled.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformOrderSettled extends PlatformOrderSettled {
  @override
  final BuiltList<PlatformOrder> data;

  factory _$PlatformOrderSettled(
          [void Function(PlatformOrderSettledBuilder)? updates]) =>
      (PlatformOrderSettledBuilder()..update(updates))._build();

  _$PlatformOrderSettled._({required this.data}) : super._();
  @override
  PlatformOrderSettled rebuild(
          void Function(PlatformOrderSettledBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformOrderSettledBuilder toBuilder() =>
      PlatformOrderSettledBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformOrderSettled && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PlatformOrderSettled')
          ..add('data', data))
        .toString();
  }
}

class PlatformOrderSettledBuilder
    implements Builder<PlatformOrderSettled, PlatformOrderSettledBuilder> {
  _$PlatformOrderSettled? _$v;

  ListBuilder<PlatformOrder>? _data;
  ListBuilder<PlatformOrder> get data =>
      _$this._data ??= ListBuilder<PlatformOrder>();
  set data(ListBuilder<PlatformOrder>? data) => _$this._data = data;

  PlatformOrderSettledBuilder() {
    PlatformOrderSettled._defaults(this);
  }

  PlatformOrderSettledBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformOrderSettled other) {
    _$v = other as _$PlatformOrderSettled;
  }

  @override
  void update(void Function(PlatformOrderSettledBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformOrderSettled build() => _build();

  _$PlatformOrderSettled _build() {
    _$PlatformOrderSettled _$result;
    try {
      _$result = _$v ??
          _$PlatformOrderSettled._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformOrderSettled', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
