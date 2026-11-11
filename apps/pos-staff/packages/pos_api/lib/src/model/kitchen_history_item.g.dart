// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_history_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenHistoryItem extends KitchenHistoryItem {
  @override
  final String name;
  @override
  final String quantity;
  @override
  final String? stationName;
  @override
  final String status;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>> modifiers;
  @override
  final String? note;

  factory _$KitchenHistoryItem(
          [void Function(KitchenHistoryItemBuilder)? updates]) =>
      (KitchenHistoryItemBuilder()..update(updates))._build();

  _$KitchenHistoryItem._(
      {required this.name,
      required this.quantity,
      this.stationName,
      required this.status,
      required this.modifiers,
      this.note})
      : super._();
  @override
  KitchenHistoryItem rebuild(
          void Function(KitchenHistoryItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenHistoryItemBuilder toBuilder() =>
      KitchenHistoryItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenHistoryItem &&
        name == other.name &&
        quantity == other.quantity &&
        stationName == other.stationName &&
        status == other.status &&
        modifiers == other.modifiers &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, stationName.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenHistoryItem')
          ..add('name', name)
          ..add('quantity', quantity)
          ..add('stationName', stationName)
          ..add('status', status)
          ..add('modifiers', modifiers)
          ..add('note', note))
        .toString();
  }
}

class KitchenHistoryItemBuilder
    implements Builder<KitchenHistoryItem, KitchenHistoryItemBuilder> {
  _$KitchenHistoryItem? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  String? _stationName;
  String? get stationName => _$this._stationName;
  set stationName(String? stationName) => _$this._stationName = stationName;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  ListBuilder<BuiltMap<String, JsonObject?>>? _modifiers;
  ListBuilder<BuiltMap<String, JsonObject?>> get modifiers =>
      _$this._modifiers ??= ListBuilder<BuiltMap<String, JsonObject?>>();
  set modifiers(ListBuilder<BuiltMap<String, JsonObject?>>? modifiers) =>
      _$this._modifiers = modifiers;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  KitchenHistoryItemBuilder() {
    KitchenHistoryItem._defaults(this);
  }

  KitchenHistoryItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _quantity = $v.quantity;
      _stationName = $v.stationName;
      _status = $v.status;
      _modifiers = $v.modifiers.toBuilder();
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenHistoryItem other) {
    _$v = other as _$KitchenHistoryItem;
  }

  @override
  void update(void Function(KitchenHistoryItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenHistoryItem build() => _build();

  _$KitchenHistoryItem _build() {
    _$KitchenHistoryItem _$result;
    try {
      _$result = _$v ??
          _$KitchenHistoryItem._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'KitchenHistoryItem', 'name'),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'KitchenHistoryItem', 'quantity'),
            stationName: stationName,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'KitchenHistoryItem', 'status'),
            modifiers: modifiers.build(),
            note: note,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        modifiers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenHistoryItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
