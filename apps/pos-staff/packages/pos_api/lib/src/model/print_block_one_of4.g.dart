// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block_one_of4.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintBlockOneOf4 extends PrintBlockOneOf4 {
  @override
  final JsonObject? kind;
  @override
  final BuiltList<PrintBlockOneOf4PartiesInner> parties;

  factory _$PrintBlockOneOf4(
          [void Function(PrintBlockOneOf4Builder)? updates]) =>
      (PrintBlockOneOf4Builder()..update(updates))._build();

  _$PrintBlockOneOf4._({this.kind, required this.parties}) : super._();
  @override
  PrintBlockOneOf4 rebuild(void Function(PrintBlockOneOf4Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockOneOf4Builder toBuilder() =>
      PrintBlockOneOf4Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlockOneOf4 &&
        kind == other.kind &&
        parties == other.parties;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, parties.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlockOneOf4')
          ..add('kind', kind)
          ..add('parties', parties))
        .toString();
  }
}

class PrintBlockOneOf4Builder
    implements Builder<PrintBlockOneOf4, PrintBlockOneOf4Builder> {
  _$PrintBlockOneOf4? _$v;

  JsonObject? _kind;
  JsonObject? get kind => _$this._kind;
  set kind(JsonObject? kind) => _$this._kind = kind;

  ListBuilder<PrintBlockOneOf4PartiesInner>? _parties;
  ListBuilder<PrintBlockOneOf4PartiesInner> get parties =>
      _$this._parties ??= ListBuilder<PrintBlockOneOf4PartiesInner>();
  set parties(ListBuilder<PrintBlockOneOf4PartiesInner>? parties) =>
      _$this._parties = parties;

  PrintBlockOneOf4Builder() {
    PrintBlockOneOf4._defaults(this);
  }

  PrintBlockOneOf4Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _parties = $v.parties.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlockOneOf4 other) {
    _$v = other as _$PrintBlockOneOf4;
  }

  @override
  void update(void Function(PrintBlockOneOf4Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlockOneOf4 build() => _build();

  _$PrintBlockOneOf4 _build() {
    _$PrintBlockOneOf4 _$result;
    try {
      _$result = _$v ??
          _$PrintBlockOneOf4._(
            kind: kind,
            parties: parties.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'parties';
        parties.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintBlockOneOf4', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
