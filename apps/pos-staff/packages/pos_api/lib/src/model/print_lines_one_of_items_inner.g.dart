// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_lines_one_of_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintLinesOneOfItemsInner extends PrintLinesOneOfItemsInner {
  @override
  final int? index;
  @override
  final String name;
  @override
  final String? amount;
  @override
  final BuiltList<String> details;

  factory _$PrintLinesOneOfItemsInner(
          [void Function(PrintLinesOneOfItemsInnerBuilder)? updates]) =>
      (PrintLinesOneOfItemsInnerBuilder()..update(updates))._build();

  _$PrintLinesOneOfItemsInner._(
      {this.index, required this.name, this.amount, required this.details})
      : super._();
  @override
  PrintLinesOneOfItemsInner rebuild(
          void Function(PrintLinesOneOfItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintLinesOneOfItemsInnerBuilder toBuilder() =>
      PrintLinesOneOfItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintLinesOneOfItemsInner &&
        index == other.index &&
        name == other.name &&
        amount == other.amount &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, index.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintLinesOneOfItemsInner')
          ..add('index', index)
          ..add('name', name)
          ..add('amount', amount)
          ..add('details', details))
        .toString();
  }
}

class PrintLinesOneOfItemsInnerBuilder
    implements
        Builder<PrintLinesOneOfItemsInner, PrintLinesOneOfItemsInnerBuilder> {
  _$PrintLinesOneOfItemsInner? _$v;

  int? _index;
  int? get index => _$this._index;
  set index(int? index) => _$this._index = index;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  ListBuilder<String>? _details;
  ListBuilder<String> get details => _$this._details ??= ListBuilder<String>();
  set details(ListBuilder<String>? details) => _$this._details = details;

  PrintLinesOneOfItemsInnerBuilder() {
    PrintLinesOneOfItemsInner._defaults(this);
  }

  PrintLinesOneOfItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _index = $v.index;
      _name = $v.name;
      _amount = $v.amount;
      _details = $v.details.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintLinesOneOfItemsInner other) {
    _$v = other as _$PrintLinesOneOfItemsInner;
  }

  @override
  void update(void Function(PrintLinesOneOfItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintLinesOneOfItemsInner build() => _build();

  _$PrintLinesOneOfItemsInner _build() {
    _$PrintLinesOneOfItemsInner _$result;
    try {
      _$result = _$v ??
          _$PrintLinesOneOfItemsInner._(
            index: index,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'PrintLinesOneOfItemsInner', 'name'),
            amount: amount,
            details: details.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'details';
        details.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintLinesOneOfItemsInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
