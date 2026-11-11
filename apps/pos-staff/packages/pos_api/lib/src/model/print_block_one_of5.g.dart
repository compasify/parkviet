// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block_one_of5.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintBlockOneOf5 extends PrintBlockOneOf5 {
  @override
  final JsonObject? kind;
  @override
  final String title;
  @override
  final String? number;

  factory _$PrintBlockOneOf5(
          [void Function(PrintBlockOneOf5Builder)? updates]) =>
      (PrintBlockOneOf5Builder()..update(updates))._build();

  _$PrintBlockOneOf5._({this.kind, required this.title, this.number})
      : super._();
  @override
  PrintBlockOneOf5 rebuild(void Function(PrintBlockOneOf5Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockOneOf5Builder toBuilder() =>
      PrintBlockOneOf5Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlockOneOf5 &&
        kind == other.kind &&
        title == other.title &&
        number == other.number;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlockOneOf5')
          ..add('kind', kind)
          ..add('title', title)
          ..add('number', number))
        .toString();
  }
}

class PrintBlockOneOf5Builder
    implements Builder<PrintBlockOneOf5, PrintBlockOneOf5Builder> {
  _$PrintBlockOneOf5? _$v;

  JsonObject? _kind;
  JsonObject? get kind => _$this._kind;
  set kind(JsonObject? kind) => _$this._kind = kind;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _number;
  String? get number => _$this._number;
  set number(String? number) => _$this._number = number;

  PrintBlockOneOf5Builder() {
    PrintBlockOneOf5._defaults(this);
  }

  PrintBlockOneOf5Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _title = $v.title;
      _number = $v.number;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlockOneOf5 other) {
    _$v = other as _$PrintBlockOneOf5;
  }

  @override
  void update(void Function(PrintBlockOneOf5Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlockOneOf5 build() => _build();

  _$PrintBlockOneOf5 _build() {
    final _$result = _$v ??
        _$PrintBlockOneOf5._(
          kind: kind,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'PrintBlockOneOf5', 'title'),
          number: number,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
