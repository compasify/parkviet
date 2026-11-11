// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'append_items_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppendItemsInput extends AppendItemsInput {
  @override
  final BuiltList<AppendItem> items;
  @override
  final String? appendBatchId;

  factory _$AppendItemsInput(
          [void Function(AppendItemsInputBuilder)? updates]) =>
      (AppendItemsInputBuilder()..update(updates))._build();

  _$AppendItemsInput._({required this.items, this.appendBatchId}) : super._();
  @override
  AppendItemsInput rebuild(void Function(AppendItemsInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppendItemsInputBuilder toBuilder() =>
      AppendItemsInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppendItemsInput &&
        items == other.items &&
        appendBatchId == other.appendBatchId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, appendBatchId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppendItemsInput')
          ..add('items', items)
          ..add('appendBatchId', appendBatchId))
        .toString();
  }
}

class AppendItemsInputBuilder
    implements Builder<AppendItemsInput, AppendItemsInputBuilder> {
  _$AppendItemsInput? _$v;

  ListBuilder<AppendItem>? _items;
  ListBuilder<AppendItem> get items =>
      _$this._items ??= ListBuilder<AppendItem>();
  set items(ListBuilder<AppendItem>? items) => _$this._items = items;

  String? _appendBatchId;
  String? get appendBatchId => _$this._appendBatchId;
  set appendBatchId(String? appendBatchId) =>
      _$this._appendBatchId = appendBatchId;

  AppendItemsInputBuilder() {
    AppendItemsInput._defaults(this);
  }

  AppendItemsInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _appendBatchId = $v.appendBatchId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppendItemsInput other) {
    _$v = other as _$AppendItemsInput;
  }

  @override
  void update(void Function(AppendItemsInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppendItemsInput build() => _build();

  _$AppendItemsInput _build() {
    _$AppendItemsInput _$result;
    try {
      _$result = _$v ??
          _$AppendItemsInput._(
            items: items.build(),
            appendBatchId: appendBatchId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AppendItemsInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
