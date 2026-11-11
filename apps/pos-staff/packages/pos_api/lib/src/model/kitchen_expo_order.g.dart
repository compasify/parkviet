// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_expo_order.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenExpoOrder extends KitchenExpoOrder {
  @override
  final String workspaceId;
  @override
  final BuiltMap<String, JsonObject?> header;
  @override
  final String serviceMode;
  @override
  final DateTime? readySince;
  @override
  final BuiltList<KitchenExpoItem> items;

  factory _$KitchenExpoOrder(
          [void Function(KitchenExpoOrderBuilder)? updates]) =>
      (KitchenExpoOrderBuilder()..update(updates))._build();

  _$KitchenExpoOrder._(
      {required this.workspaceId,
      required this.header,
      required this.serviceMode,
      this.readySince,
      required this.items})
      : super._();
  @override
  KitchenExpoOrder rebuild(void Function(KitchenExpoOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenExpoOrderBuilder toBuilder() =>
      KitchenExpoOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenExpoOrder &&
        workspaceId == other.workspaceId &&
        header == other.header &&
        serviceMode == other.serviceMode &&
        readySince == other.readySince &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, header.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jc(_$hash, readySince.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenExpoOrder')
          ..add('workspaceId', workspaceId)
          ..add('header', header)
          ..add('serviceMode', serviceMode)
          ..add('readySince', readySince)
          ..add('items', items))
        .toString();
  }
}

class KitchenExpoOrderBuilder
    implements Builder<KitchenExpoOrder, KitchenExpoOrderBuilder> {
  _$KitchenExpoOrder? _$v;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  MapBuilder<String, JsonObject?>? _header;
  MapBuilder<String, JsonObject?> get header =>
      _$this._header ??= MapBuilder<String, JsonObject?>();
  set header(MapBuilder<String, JsonObject?>? header) =>
      _$this._header = header;

  String? _serviceMode;
  String? get serviceMode => _$this._serviceMode;
  set serviceMode(String? serviceMode) => _$this._serviceMode = serviceMode;

  DateTime? _readySince;
  DateTime? get readySince => _$this._readySince;
  set readySince(DateTime? readySince) => _$this._readySince = readySince;

  ListBuilder<KitchenExpoItem>? _items;
  ListBuilder<KitchenExpoItem> get items =>
      _$this._items ??= ListBuilder<KitchenExpoItem>();
  set items(ListBuilder<KitchenExpoItem>? items) => _$this._items = items;

  KitchenExpoOrderBuilder() {
    KitchenExpoOrder._defaults(this);
  }

  KitchenExpoOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspaceId = $v.workspaceId;
      _header = $v.header.toBuilder();
      _serviceMode = $v.serviceMode;
      _readySince = $v.readySince;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenExpoOrder other) {
    _$v = other as _$KitchenExpoOrder;
  }

  @override
  void update(void Function(KitchenExpoOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenExpoOrder build() => _build();

  _$KitchenExpoOrder _build() {
    _$KitchenExpoOrder _$result;
    try {
      _$result = _$v ??
          _$KitchenExpoOrder._(
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'KitchenExpoOrder', 'workspaceId'),
            header: header.build(),
            serviceMode: BuiltValueNullFieldError.checkNotNull(
                serviceMode, r'KitchenExpoOrder', 'serviceMode'),
            readySince: readySince,
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'header';
        header.build();

        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenExpoOrder', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
