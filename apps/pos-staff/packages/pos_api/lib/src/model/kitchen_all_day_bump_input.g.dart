// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_all_day_bump_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenAllDayBumpInput extends KitchenAllDayBumpInput {
  @override
  final String? branchId;
  @override
  final BuiltList<String>? stationIds;
  @override
  final String key;
  @override
  final int? quantity;

  factory _$KitchenAllDayBumpInput(
          [void Function(KitchenAllDayBumpInputBuilder)? updates]) =>
      (KitchenAllDayBumpInputBuilder()..update(updates))._build();

  _$KitchenAllDayBumpInput._(
      {this.branchId, this.stationIds, required this.key, this.quantity})
      : super._();
  @override
  KitchenAllDayBumpInput rebuild(
          void Function(KitchenAllDayBumpInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenAllDayBumpInputBuilder toBuilder() =>
      KitchenAllDayBumpInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenAllDayBumpInput &&
        branchId == other.branchId &&
        stationIds == other.stationIds &&
        key == other.key &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, stationIds.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenAllDayBumpInput')
          ..add('branchId', branchId)
          ..add('stationIds', stationIds)
          ..add('key', key)
          ..add('quantity', quantity))
        .toString();
  }
}

class KitchenAllDayBumpInputBuilder
    implements Builder<KitchenAllDayBumpInput, KitchenAllDayBumpInputBuilder> {
  _$KitchenAllDayBumpInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  ListBuilder<String>? _stationIds;
  ListBuilder<String> get stationIds =>
      _$this._stationIds ??= ListBuilder<String>();
  set stationIds(ListBuilder<String>? stationIds) =>
      _$this._stationIds = stationIds;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  KitchenAllDayBumpInputBuilder() {
    KitchenAllDayBumpInput._defaults(this);
  }

  KitchenAllDayBumpInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _stationIds = $v.stationIds?.toBuilder();
      _key = $v.key;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenAllDayBumpInput other) {
    _$v = other as _$KitchenAllDayBumpInput;
  }

  @override
  void update(void Function(KitchenAllDayBumpInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenAllDayBumpInput build() => _build();

  _$KitchenAllDayBumpInput _build() {
    _$KitchenAllDayBumpInput _$result;
    try {
      _$result = _$v ??
          _$KitchenAllDayBumpInput._(
            branchId: branchId,
            stationIds: _stationIds?.build(),
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'KitchenAllDayBumpInput', 'key'),
            quantity: quantity,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stationIds';
        _stationIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenAllDayBumpInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
