// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_expo_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenExpoItem extends KitchenExpoItem {
  @override
  final KitchenTicketItem item;
  @override
  final String kitchenTicketId;
  @override
  final String stationName;

  factory _$KitchenExpoItem([void Function(KitchenExpoItemBuilder)? updates]) =>
      (KitchenExpoItemBuilder()..update(updates))._build();

  _$KitchenExpoItem._(
      {required this.item,
      required this.kitchenTicketId,
      required this.stationName})
      : super._();
  @override
  KitchenExpoItem rebuild(void Function(KitchenExpoItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenExpoItemBuilder toBuilder() => KitchenExpoItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenExpoItem &&
        item == other.item &&
        kitchenTicketId == other.kitchenTicketId &&
        stationName == other.stationName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, item.hashCode);
    _$hash = $jc(_$hash, kitchenTicketId.hashCode);
    _$hash = $jc(_$hash, stationName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenExpoItem')
          ..add('item', item)
          ..add('kitchenTicketId', kitchenTicketId)
          ..add('stationName', stationName))
        .toString();
  }
}

class KitchenExpoItemBuilder
    implements Builder<KitchenExpoItem, KitchenExpoItemBuilder> {
  _$KitchenExpoItem? _$v;

  KitchenTicketItemBuilder? _item;
  KitchenTicketItemBuilder get item =>
      _$this._item ??= KitchenTicketItemBuilder();
  set item(KitchenTicketItemBuilder? item) => _$this._item = item;

  String? _kitchenTicketId;
  String? get kitchenTicketId => _$this._kitchenTicketId;
  set kitchenTicketId(String? kitchenTicketId) =>
      _$this._kitchenTicketId = kitchenTicketId;

  String? _stationName;
  String? get stationName => _$this._stationName;
  set stationName(String? stationName) => _$this._stationName = stationName;

  KitchenExpoItemBuilder() {
    KitchenExpoItem._defaults(this);
  }

  KitchenExpoItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _item = $v.item.toBuilder();
      _kitchenTicketId = $v.kitchenTicketId;
      _stationName = $v.stationName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenExpoItem other) {
    _$v = other as _$KitchenExpoItem;
  }

  @override
  void update(void Function(KitchenExpoItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenExpoItem build() => _build();

  _$KitchenExpoItem _build() {
    _$KitchenExpoItem _$result;
    try {
      _$result = _$v ??
          _$KitchenExpoItem._(
            item: item.build(),
            kitchenTicketId: BuiltValueNullFieldError.checkNotNull(
                kitchenTicketId, r'KitchenExpoItem', 'kitchenTicketId'),
            stationName: BuiltValueNullFieldError.checkNotNull(
                stationName, r'KitchenExpoItem', 'stationName'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'item';
        item.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenExpoItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
