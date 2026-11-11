// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_lines_one_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintLinesOneOf1 extends PrintLinesOneOf1 {
  @override
  final JsonObject? layout;
  @override
  final PrintLinesOneOf1Headings headings;
  @override
  final BuiltList<PrintLinesOneOf1ColumnsInner> columns;
  @override
  final BuiltList<PrintLinesOneOf1RowsInner> rows;

  factory _$PrintLinesOneOf1(
          [void Function(PrintLinesOneOf1Builder)? updates]) =>
      (PrintLinesOneOf1Builder()..update(updates))._build();

  _$PrintLinesOneOf1._(
      {this.layout,
      required this.headings,
      required this.columns,
      required this.rows})
      : super._();
  @override
  PrintLinesOneOf1 rebuild(void Function(PrintLinesOneOf1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintLinesOneOf1Builder toBuilder() =>
      PrintLinesOneOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintLinesOneOf1 &&
        layout == other.layout &&
        headings == other.headings &&
        columns == other.columns &&
        rows == other.rows;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, layout.hashCode);
    _$hash = $jc(_$hash, headings.hashCode);
    _$hash = $jc(_$hash, columns.hashCode);
    _$hash = $jc(_$hash, rows.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintLinesOneOf1')
          ..add('layout', layout)
          ..add('headings', headings)
          ..add('columns', columns)
          ..add('rows', rows))
        .toString();
  }
}

class PrintLinesOneOf1Builder
    implements Builder<PrintLinesOneOf1, PrintLinesOneOf1Builder> {
  _$PrintLinesOneOf1? _$v;

  JsonObject? _layout;
  JsonObject? get layout => _$this._layout;
  set layout(JsonObject? layout) => _$this._layout = layout;

  PrintLinesOneOf1HeadingsBuilder? _headings;
  PrintLinesOneOf1HeadingsBuilder get headings =>
      _$this._headings ??= PrintLinesOneOf1HeadingsBuilder();
  set headings(PrintLinesOneOf1HeadingsBuilder? headings) =>
      _$this._headings = headings;

  ListBuilder<PrintLinesOneOf1ColumnsInner>? _columns;
  ListBuilder<PrintLinesOneOf1ColumnsInner> get columns =>
      _$this._columns ??= ListBuilder<PrintLinesOneOf1ColumnsInner>();
  set columns(ListBuilder<PrintLinesOneOf1ColumnsInner>? columns) =>
      _$this._columns = columns;

  ListBuilder<PrintLinesOneOf1RowsInner>? _rows;
  ListBuilder<PrintLinesOneOf1RowsInner> get rows =>
      _$this._rows ??= ListBuilder<PrintLinesOneOf1RowsInner>();
  set rows(ListBuilder<PrintLinesOneOf1RowsInner>? rows) => _$this._rows = rows;

  PrintLinesOneOf1Builder() {
    PrintLinesOneOf1._defaults(this);
  }

  PrintLinesOneOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _layout = $v.layout;
      _headings = $v.headings.toBuilder();
      _columns = $v.columns.toBuilder();
      _rows = $v.rows.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintLinesOneOf1 other) {
    _$v = other as _$PrintLinesOneOf1;
  }

  @override
  void update(void Function(PrintLinesOneOf1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintLinesOneOf1 build() => _build();

  _$PrintLinesOneOf1 _build() {
    _$PrintLinesOneOf1 _$result;
    try {
      _$result = _$v ??
          _$PrintLinesOneOf1._(
            layout: layout,
            headings: headings.build(),
            columns: columns.build(),
            rows: rows.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'headings';
        headings.build();
        _$failedField = 'columns';
        columns.build();
        _$failedField = 'rows';
        rows.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintLinesOneOf1', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
