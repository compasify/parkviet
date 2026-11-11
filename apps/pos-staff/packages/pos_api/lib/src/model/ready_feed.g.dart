// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ready_feed.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReadyFeed extends ReadyFeed {
  @override
  final String branchId;
  @override
  final DateTime serverNow;
  @override
  final String? areaId;
  @override
  final BuiltList<ReadyFeedItem> items;

  factory _$ReadyFeed([void Function(ReadyFeedBuilder)? updates]) =>
      (ReadyFeedBuilder()..update(updates))._build();

  _$ReadyFeed._(
      {required this.branchId,
      required this.serverNow,
      this.areaId,
      required this.items})
      : super._();
  @override
  ReadyFeed rebuild(void Function(ReadyFeedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReadyFeedBuilder toBuilder() => ReadyFeedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReadyFeed &&
        branchId == other.branchId &&
        serverNow == other.serverNow &&
        areaId == other.areaId &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, serverNow.hashCode);
    _$hash = $jc(_$hash, areaId.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReadyFeed')
          ..add('branchId', branchId)
          ..add('serverNow', serverNow)
          ..add('areaId', areaId)
          ..add('items', items))
        .toString();
  }
}

class ReadyFeedBuilder implements Builder<ReadyFeed, ReadyFeedBuilder> {
  _$ReadyFeed? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  DateTime? _serverNow;
  DateTime? get serverNow => _$this._serverNow;
  set serverNow(DateTime? serverNow) => _$this._serverNow = serverNow;

  String? _areaId;
  String? get areaId => _$this._areaId;
  set areaId(String? areaId) => _$this._areaId = areaId;

  ListBuilder<ReadyFeedItem>? _items;
  ListBuilder<ReadyFeedItem> get items =>
      _$this._items ??= ListBuilder<ReadyFeedItem>();
  set items(ListBuilder<ReadyFeedItem>? items) => _$this._items = items;

  ReadyFeedBuilder() {
    ReadyFeed._defaults(this);
  }

  ReadyFeedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _serverNow = $v.serverNow;
      _areaId = $v.areaId;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReadyFeed other) {
    _$v = other as _$ReadyFeed;
  }

  @override
  void update(void Function(ReadyFeedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReadyFeed build() => _build();

  _$ReadyFeed _build() {
    _$ReadyFeed _$result;
    try {
      _$result = _$v ??
          _$ReadyFeed._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'ReadyFeed', 'branchId'),
            serverNow: BuiltValueNullFieldError.checkNotNull(
                serverNow, r'ReadyFeed', 'serverNow'),
            areaId: areaId,
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReadyFeed', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
