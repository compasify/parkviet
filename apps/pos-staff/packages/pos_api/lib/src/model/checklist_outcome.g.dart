// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_outcome.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChecklistOutcome extends ChecklistOutcome {
  @override
  final JsonObject document;
  @override
  final PrintJob? printJob;

  factory _$ChecklistOutcome(
          [void Function(ChecklistOutcomeBuilder)? updates]) =>
      (ChecklistOutcomeBuilder()..update(updates))._build();

  _$ChecklistOutcome._({required this.document, this.printJob}) : super._();
  @override
  ChecklistOutcome rebuild(void Function(ChecklistOutcomeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChecklistOutcomeBuilder toBuilder() =>
      ChecklistOutcomeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChecklistOutcome &&
        document == other.document &&
        printJob == other.printJob;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, document.hashCode);
    _$hash = $jc(_$hash, printJob.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChecklistOutcome')
          ..add('document', document)
          ..add('printJob', printJob))
        .toString();
  }
}

class ChecklistOutcomeBuilder
    implements Builder<ChecklistOutcome, ChecklistOutcomeBuilder> {
  _$ChecklistOutcome? _$v;

  JsonObject? _document;
  JsonObject? get document => _$this._document;
  set document(JsonObject? document) => _$this._document = document;

  PrintJobBuilder? _printJob;
  PrintJobBuilder get printJob => _$this._printJob ??= PrintJobBuilder();
  set printJob(PrintJobBuilder? printJob) => _$this._printJob = printJob;

  ChecklistOutcomeBuilder() {
    ChecklistOutcome._defaults(this);
  }

  ChecklistOutcomeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _document = $v.document;
      _printJob = $v.printJob?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChecklistOutcome other) {
    _$v = other as _$ChecklistOutcome;
  }

  @override
  void update(void Function(ChecklistOutcomeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChecklistOutcome build() => _build();

  _$ChecklistOutcome _build() {
    _$ChecklistOutcome _$result;
    try {
      _$result = _$v ??
          _$ChecklistOutcome._(
            document: BuiltValueNullFieldError.checkNotNull(
                document, r'ChecklistOutcome', 'document'),
            printJob: _printJob?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'printJob';
        _printJob?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ChecklistOutcome', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
