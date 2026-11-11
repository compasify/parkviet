// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printer_test200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrinterTest200ResponseData extends PosPrinterTest200ResponseData {
  @override
  final PrintJob? printJob;
  @override
  final JsonObject? document;

  factory _$PosPrinterTest200ResponseData(
          [void Function(PosPrinterTest200ResponseDataBuilder)? updates]) =>
      (PosPrinterTest200ResponseDataBuilder()..update(updates))._build();

  _$PosPrinterTest200ResponseData._({this.printJob, this.document}) : super._();
  @override
  PosPrinterTest200ResponseData rebuild(
          void Function(PosPrinterTest200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinterTest200ResponseDataBuilder toBuilder() =>
      PosPrinterTest200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinterTest200ResponseData &&
        printJob == other.printJob &&
        document == other.document;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, printJob.hashCode);
    _$hash = $jc(_$hash, document.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosPrinterTest200ResponseData')
          ..add('printJob', printJob)
          ..add('document', document))
        .toString();
  }
}

class PosPrinterTest200ResponseDataBuilder
    implements
        Builder<PosPrinterTest200ResponseData,
            PosPrinterTest200ResponseDataBuilder> {
  _$PosPrinterTest200ResponseData? _$v;

  PrintJobBuilder? _printJob;
  PrintJobBuilder get printJob => _$this._printJob ??= PrintJobBuilder();
  set printJob(PrintJobBuilder? printJob) => _$this._printJob = printJob;

  JsonObject? _document;
  JsonObject? get document => _$this._document;
  set document(JsonObject? document) => _$this._document = document;

  PosPrinterTest200ResponseDataBuilder() {
    PosPrinterTest200ResponseData._defaults(this);
  }

  PosPrinterTest200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _printJob = $v.printJob?.toBuilder();
      _document = $v.document;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrinterTest200ResponseData other) {
    _$v = other as _$PosPrinterTest200ResponseData;
  }

  @override
  void update(void Function(PosPrinterTest200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinterTest200ResponseData build() => _build();

  _$PosPrinterTest200ResponseData _build() {
    _$PosPrinterTest200ResponseData _$result;
    try {
      _$result = _$v ??
          _$PosPrinterTest200ResponseData._(
            printJob: _printJob?.build(),
            document: document,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'printJob';
        _printJob?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrinterTest200ResponseData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
