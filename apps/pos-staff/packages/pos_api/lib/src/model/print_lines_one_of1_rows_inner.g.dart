// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_lines_one_of1_rows_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintLinesOneOf1RowsInner extends PrintLinesOneOf1RowsInner {
  @override
  final int? index;
  @override
  final String name;
  @override
  final BuiltList<String> cells;
  @override
  final BuiltList<String> details;

  factory _$PrintLinesOneOf1RowsInner(
          [void Function(PrintLinesOneOf1RowsInnerBuilder)? updates]) =>
      (PrintLinesOneOf1RowsInnerBuilder()..update(updates))._build();

  _$PrintLinesOneOf1RowsInner._(
      {this.index,
      required this.name,
      required this.cells,
      required this.details})
      : super._();
  @override
  PrintLinesOneOf1RowsInner rebuild(
          void Function(PrintLinesOneOf1RowsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintLinesOneOf1RowsInnerBuilder toBuilder() =>
      PrintLinesOneOf1RowsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintLinesOneOf1RowsInner &&
        index == other.index &&
        name == other.name &&
        cells == other.cells &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, index.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, cells.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintLinesOneOf1RowsInner')
          ..add('index', index)
          ..add('name', name)
          ..add('cells', cells)
          ..add('details', details))
        .toString();
  }
}

class PrintLinesOneOf1RowsInnerBuilder
    implements
        Builder<PrintLinesOneOf1RowsInner, PrintLinesOneOf1RowsInnerBuilder> {
  _$PrintLinesOneOf1RowsInner? _$v;

  int? _index;
  int? get index => _$this._index;
  set index(int? index) => _$this._index = index;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<String>? _cells;
  ListBuilder<String> get cells => _$this._cells ??= ListBuilder<String>();
  set cells(ListBuilder<String>? cells) => _$this._cells = cells;

  ListBuilder<String>? _details;
  ListBuilder<String> get details => _$this._details ??= ListBuilder<String>();
  set details(ListBuilder<String>? details) => _$this._details = details;

  PrintLinesOneOf1RowsInnerBuilder() {
    PrintLinesOneOf1RowsInner._defaults(this);
  }

  PrintLinesOneOf1RowsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _index = $v.index;
      _name = $v.name;
      _cells = $v.cells.toBuilder();
      _details = $v.details.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintLinesOneOf1RowsInner other) {
    _$v = other as _$PrintLinesOneOf1RowsInner;
  }

  @override
  void update(void Function(PrintLinesOneOf1RowsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintLinesOneOf1RowsInner build() => _build();

  _$PrintLinesOneOf1RowsInner _build() {
    _$PrintLinesOneOf1RowsInner _$result;
    try {
      _$result = _$v ??
          _$PrintLinesOneOf1RowsInner._(
            index: index,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'PrintLinesOneOf1RowsInner', 'name'),
            cells: cells.build(),
            details: details.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'cells';
        cells.build();
        _$failedField = 'details';
        details.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintLinesOneOf1RowsInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
