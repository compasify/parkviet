// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintJobResult extends PrintJobResult {
  @override
  final PrintJob printJob;
  @override
  final JsonObject? print;
  @override
  final JsonObject? receipt;

  factory _$PrintJobResult([void Function(PrintJobResultBuilder)? updates]) =>
      (PrintJobResultBuilder()..update(updates))._build();

  _$PrintJobResult._({required this.printJob, this.print, this.receipt})
      : super._();
  @override
  PrintJobResult rebuild(void Function(PrintJobResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintJobResultBuilder toBuilder() => PrintJobResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintJobResult &&
        printJob == other.printJob &&
        print == other.print &&
        receipt == other.receipt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, printJob.hashCode);
    _$hash = $jc(_$hash, print.hashCode);
    _$hash = $jc(_$hash, receipt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintJobResult')
          ..add('printJob', printJob)
          ..add('print', print)
          ..add('receipt', receipt))
        .toString();
  }
}

class PrintJobResultBuilder
    implements Builder<PrintJobResult, PrintJobResultBuilder> {
  _$PrintJobResult? _$v;

  PrintJobBuilder? _printJob;
  PrintJobBuilder get printJob => _$this._printJob ??= PrintJobBuilder();
  set printJob(PrintJobBuilder? printJob) => _$this._printJob = printJob;

  JsonObject? _print;
  JsonObject? get print => _$this._print;
  set print(JsonObject? print) => _$this._print = print;

  JsonObject? _receipt;
  JsonObject? get receipt => _$this._receipt;
  set receipt(JsonObject? receipt) => _$this._receipt = receipt;

  PrintJobResultBuilder() {
    PrintJobResult._defaults(this);
  }

  PrintJobResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _printJob = $v.printJob.toBuilder();
      _print = $v.print;
      _receipt = $v.receipt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintJobResult other) {
    _$v = other as _$PrintJobResult;
  }

  @override
  void update(void Function(PrintJobResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintJobResult build() => _build();

  _$PrintJobResult _build() {
    _$PrintJobResult _$result;
    try {
      _$result = _$v ??
          _$PrintJobResult._(
            printJob: printJob.build(),
            print: print,
            receipt: receipt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'printJob';
        printJob.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintJobResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
