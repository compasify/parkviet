// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_claim.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintJobClaim extends PrintJobClaim {
  @override
  final String id;
  @override
  final String kind;
  @override
  final int attempt;
  @override
  final String claimExpiresAt;
  @override
  final PrintJobClaimPrinter printer;
  @override
  final JsonObject document;

  factory _$PrintJobClaim([void Function(PrintJobClaimBuilder)? updates]) =>
      (PrintJobClaimBuilder()..update(updates))._build();

  _$PrintJobClaim._(
      {required this.id,
      required this.kind,
      required this.attempt,
      required this.claimExpiresAt,
      required this.printer,
      required this.document})
      : super._();
  @override
  PrintJobClaim rebuild(void Function(PrintJobClaimBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintJobClaimBuilder toBuilder() => PrintJobClaimBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintJobClaim &&
        id == other.id &&
        kind == other.kind &&
        attempt == other.attempt &&
        claimExpiresAt == other.claimExpiresAt &&
        printer == other.printer &&
        document == other.document;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, attempt.hashCode);
    _$hash = $jc(_$hash, claimExpiresAt.hashCode);
    _$hash = $jc(_$hash, printer.hashCode);
    _$hash = $jc(_$hash, document.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintJobClaim')
          ..add('id', id)
          ..add('kind', kind)
          ..add('attempt', attempt)
          ..add('claimExpiresAt', claimExpiresAt)
          ..add('printer', printer)
          ..add('document', document))
        .toString();
  }
}

class PrintJobClaimBuilder
    implements Builder<PrintJobClaim, PrintJobClaimBuilder> {
  _$PrintJobClaim? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _kind;
  String? get kind => _$this._kind;
  set kind(String? kind) => _$this._kind = kind;

  int? _attempt;
  int? get attempt => _$this._attempt;
  set attempt(int? attempt) => _$this._attempt = attempt;

  String? _claimExpiresAt;
  String? get claimExpiresAt => _$this._claimExpiresAt;
  set claimExpiresAt(String? claimExpiresAt) =>
      _$this._claimExpiresAt = claimExpiresAt;

  PrintJobClaimPrinterBuilder? _printer;
  PrintJobClaimPrinterBuilder get printer =>
      _$this._printer ??= PrintJobClaimPrinterBuilder();
  set printer(PrintJobClaimPrinterBuilder? printer) =>
      _$this._printer = printer;

  JsonObject? _document;
  JsonObject? get document => _$this._document;
  set document(JsonObject? document) => _$this._document = document;

  PrintJobClaimBuilder() {
    PrintJobClaim._defaults(this);
  }

  PrintJobClaimBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _attempt = $v.attempt;
      _claimExpiresAt = $v.claimExpiresAt;
      _printer = $v.printer.toBuilder();
      _document = $v.document;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintJobClaim other) {
    _$v = other as _$PrintJobClaim;
  }

  @override
  void update(void Function(PrintJobClaimBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintJobClaim build() => _build();

  _$PrintJobClaim _build() {
    _$PrintJobClaim _$result;
    try {
      _$result = _$v ??
          _$PrintJobClaim._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PrintJobClaim', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'PrintJobClaim', 'kind'),
            attempt: BuiltValueNullFieldError.checkNotNull(
                attempt, r'PrintJobClaim', 'attempt'),
            claimExpiresAt: BuiltValueNullFieldError.checkNotNull(
                claimExpiresAt, r'PrintJobClaim', 'claimExpiresAt'),
            printer: printer.build(),
            document: BuiltValueNullFieldError.checkNotNull(
                document, r'PrintJobClaim', 'document'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'printer';
        printer.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintJobClaim', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
