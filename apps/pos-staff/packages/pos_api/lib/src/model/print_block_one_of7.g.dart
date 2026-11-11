// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block_one_of7.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintBlockOneOf7 extends PrintBlockOneOf7 {
  @override
  final JsonObject? kind;
  @override
  final num mm;

  factory _$PrintBlockOneOf7(
          [void Function(PrintBlockOneOf7Builder)? updates]) =>
      (PrintBlockOneOf7Builder()..update(updates))._build();

  _$PrintBlockOneOf7._({this.kind, required this.mm}) : super._();
  @override
  PrintBlockOneOf7 rebuild(void Function(PrintBlockOneOf7Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockOneOf7Builder toBuilder() =>
      PrintBlockOneOf7Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlockOneOf7 && kind == other.kind && mm == other.mm;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, mm.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlockOneOf7')
          ..add('kind', kind)
          ..add('mm', mm))
        .toString();
  }
}

class PrintBlockOneOf7Builder
    implements Builder<PrintBlockOneOf7, PrintBlockOneOf7Builder> {
  _$PrintBlockOneOf7? _$v;

  JsonObject? _kind;
  JsonObject? get kind => _$this._kind;
  set kind(JsonObject? kind) => _$this._kind = kind;

  num? _mm;
  num? get mm => _$this._mm;
  set mm(num? mm) => _$this._mm = mm;

  PrintBlockOneOf7Builder() {
    PrintBlockOneOf7._defaults(this);
  }

  PrintBlockOneOf7Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _mm = $v.mm;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlockOneOf7 other) {
    _$v = other as _$PrintBlockOneOf7;
  }

  @override
  void update(void Function(PrintBlockOneOf7Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlockOneOf7 build() => _build();

  _$PrintBlockOneOf7 _build() {
    final _$result = _$v ??
        _$PrintBlockOneOf7._(
          kind: kind,
          mm: BuiltValueNullFieldError.checkNotNull(
              mm, r'PrintBlockOneOf7', 'mm'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
