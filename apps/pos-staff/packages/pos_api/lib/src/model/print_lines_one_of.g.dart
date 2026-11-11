// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_lines_one_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintLinesOneOf extends PrintLinesOneOf {
  @override
  final JsonObject? layout;
  @override
  final BuiltList<PrintLinesOneOfItemsInner> items;

  factory _$PrintLinesOneOf([void Function(PrintLinesOneOfBuilder)? updates]) =>
      (PrintLinesOneOfBuilder()..update(updates))._build();

  _$PrintLinesOneOf._({this.layout, required this.items}) : super._();
  @override
  PrintLinesOneOf rebuild(void Function(PrintLinesOneOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintLinesOneOfBuilder toBuilder() => PrintLinesOneOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintLinesOneOf &&
        layout == other.layout &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, layout.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintLinesOneOf')
          ..add('layout', layout)
          ..add('items', items))
        .toString();
  }
}

class PrintLinesOneOfBuilder
    implements Builder<PrintLinesOneOf, PrintLinesOneOfBuilder> {
  _$PrintLinesOneOf? _$v;

  JsonObject? _layout;
  JsonObject? get layout => _$this._layout;
  set layout(JsonObject? layout) => _$this._layout = layout;

  ListBuilder<PrintLinesOneOfItemsInner>? _items;
  ListBuilder<PrintLinesOneOfItemsInner> get items =>
      _$this._items ??= ListBuilder<PrintLinesOneOfItemsInner>();
  set items(ListBuilder<PrintLinesOneOfItemsInner>? items) =>
      _$this._items = items;

  PrintLinesOneOfBuilder() {
    PrintLinesOneOf._defaults(this);
  }

  PrintLinesOneOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _layout = $v.layout;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintLinesOneOf other) {
    _$v = other as _$PrintLinesOneOf;
  }

  @override
  void update(void Function(PrintLinesOneOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintLinesOneOf build() => _build();

  _$PrintLinesOneOf _build() {
    _$PrintLinesOneOf _$result;
    try {
      _$result = _$v ??
          _$PrintLinesOneOf._(
            layout: layout,
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintLinesOneOf', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
