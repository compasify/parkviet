// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_lines_one_of1_headings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintLinesOneOf1Headings extends PrintLinesOneOf1Headings {
  @override
  final String? index;
  @override
  final String name;

  factory _$PrintLinesOneOf1Headings(
          [void Function(PrintLinesOneOf1HeadingsBuilder)? updates]) =>
      (PrintLinesOneOf1HeadingsBuilder()..update(updates))._build();

  _$PrintLinesOneOf1Headings._({this.index, required this.name}) : super._();
  @override
  PrintLinesOneOf1Headings rebuild(
          void Function(PrintLinesOneOf1HeadingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintLinesOneOf1HeadingsBuilder toBuilder() =>
      PrintLinesOneOf1HeadingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintLinesOneOf1Headings &&
        index == other.index &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, index.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintLinesOneOf1Headings')
          ..add('index', index)
          ..add('name', name))
        .toString();
  }
}

class PrintLinesOneOf1HeadingsBuilder
    implements
        Builder<PrintLinesOneOf1Headings, PrintLinesOneOf1HeadingsBuilder> {
  _$PrintLinesOneOf1Headings? _$v;

  String? _index;
  String? get index => _$this._index;
  set index(String? index) => _$this._index = index;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PrintLinesOneOf1HeadingsBuilder() {
    PrintLinesOneOf1Headings._defaults(this);
  }

  PrintLinesOneOf1HeadingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _index = $v.index;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintLinesOneOf1Headings other) {
    _$v = other as _$PrintLinesOneOf1Headings;
  }

  @override
  void update(void Function(PrintLinesOneOf1HeadingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintLinesOneOf1Headings build() => _build();

  _$PrintLinesOneOf1Headings _build() {
    final _$result = _$v ??
        _$PrintLinesOneOf1Headings._(
          index: index,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PrintLinesOneOf1Headings', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
