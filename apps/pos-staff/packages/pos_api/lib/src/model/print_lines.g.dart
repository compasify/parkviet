// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_lines.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintLines extends PrintLines {
  @override
  final OneOf oneOf;

  factory _$PrintLines([void Function(PrintLinesBuilder)? updates]) =>
      (PrintLinesBuilder()..update(updates))._build();

  _$PrintLines._({required this.oneOf}) : super._();
  @override
  PrintLines rebuild(void Function(PrintLinesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintLinesBuilder toBuilder() => PrintLinesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintLines && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintLines')..add('oneOf', oneOf))
        .toString();
  }
}

class PrintLinesBuilder implements Builder<PrintLines, PrintLinesBuilder> {
  _$PrintLines? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  PrintLinesBuilder() {
    PrintLines._defaults(this);
  }

  PrintLinesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintLines other) {
    _$v = other as _$PrintLines;
  }

  @override
  void update(void Function(PrintLinesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintLines build() => _build();

  _$PrintLines _build() {
    final _$result = _$v ??
        _$PrintLines._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'PrintLines', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
