// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_station_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenStationResult extends KitchenStationResult {
  @override
  final KitchenStation data;

  factory _$KitchenStationResult(
          [void Function(KitchenStationResultBuilder)? updates]) =>
      (KitchenStationResultBuilder()..update(updates))._build();

  _$KitchenStationResult._({required this.data}) : super._();
  @override
  KitchenStationResult rebuild(
          void Function(KitchenStationResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenStationResultBuilder toBuilder() =>
      KitchenStationResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenStationResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'KitchenStationResult')
          ..add('data', data))
        .toString();
  }
}

class KitchenStationResultBuilder
    implements Builder<KitchenStationResult, KitchenStationResultBuilder> {
  _$KitchenStationResult? _$v;

  KitchenStationBuilder? _data;
  KitchenStationBuilder get data => _$this._data ??= KitchenStationBuilder();
  set data(KitchenStationBuilder? data) => _$this._data = data;

  KitchenStationResultBuilder() {
    KitchenStationResult._defaults(this);
  }

  KitchenStationResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenStationResult other) {
    _$v = other as _$KitchenStationResult;
  }

  @override
  void update(void Function(KitchenStationResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenStationResult build() => _build();

  _$KitchenStationResult _build() {
    _$KitchenStationResult _$result;
    try {
      _$result = _$v ??
          _$KitchenStationResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenStationResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
