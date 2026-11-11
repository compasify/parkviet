// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prebill_outcome.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrebillOutcome extends PrebillOutcome {
  @override
  final WorkspacePrebill prebill;
  @override
  final JsonObject? document;
  @override
  final PrintJob? printJob;

  factory _$PrebillOutcome([void Function(PrebillOutcomeBuilder)? updates]) =>
      (PrebillOutcomeBuilder()..update(updates))._build();

  _$PrebillOutcome._({required this.prebill, this.document, this.printJob})
      : super._();
  @override
  PrebillOutcome rebuild(void Function(PrebillOutcomeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrebillOutcomeBuilder toBuilder() => PrebillOutcomeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrebillOutcome &&
        prebill == other.prebill &&
        document == other.document &&
        printJob == other.printJob;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, prebill.hashCode);
    _$hash = $jc(_$hash, document.hashCode);
    _$hash = $jc(_$hash, printJob.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrebillOutcome')
          ..add('prebill', prebill)
          ..add('document', document)
          ..add('printJob', printJob))
        .toString();
  }
}

class PrebillOutcomeBuilder
    implements Builder<PrebillOutcome, PrebillOutcomeBuilder> {
  _$PrebillOutcome? _$v;

  WorkspacePrebillBuilder? _prebill;
  WorkspacePrebillBuilder get prebill =>
      _$this._prebill ??= WorkspacePrebillBuilder();
  set prebill(WorkspacePrebillBuilder? prebill) => _$this._prebill = prebill;

  JsonObject? _document;
  JsonObject? get document => _$this._document;
  set document(JsonObject? document) => _$this._document = document;

  PrintJobBuilder? _printJob;
  PrintJobBuilder get printJob => _$this._printJob ??= PrintJobBuilder();
  set printJob(PrintJobBuilder? printJob) => _$this._printJob = printJob;

  PrebillOutcomeBuilder() {
    PrebillOutcome._defaults(this);
  }

  PrebillOutcomeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _prebill = $v.prebill.toBuilder();
      _document = $v.document;
      _printJob = $v.printJob?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrebillOutcome other) {
    _$v = other as _$PrebillOutcome;
  }

  @override
  void update(void Function(PrebillOutcomeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrebillOutcome build() => _build();

  _$PrebillOutcome _build() {
    _$PrebillOutcome _$result;
    try {
      _$result = _$v ??
          _$PrebillOutcome._(
            prebill: prebill.build(),
            document: document,
            printJob: _printJob?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'prebill';
        prebill.build();

        _$failedField = 'printJob';
        _printJob?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrebillOutcome', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
