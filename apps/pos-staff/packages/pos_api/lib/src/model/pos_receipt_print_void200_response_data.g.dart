// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_receipt_print_void200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosReceiptPrintVoid200ResponseData
    extends PosReceiptPrintVoid200ResponseData {
  @override
  final JsonObject print;
  @override
  final JsonObject receipt;

  factory _$PosReceiptPrintVoid200ResponseData(
          [void Function(PosReceiptPrintVoid200ResponseDataBuilder)?
              updates]) =>
      (PosReceiptPrintVoid200ResponseDataBuilder()..update(updates))._build();

  _$PosReceiptPrintVoid200ResponseData._(
      {required this.print, required this.receipt})
      : super._();
  @override
  PosReceiptPrintVoid200ResponseData rebuild(
          void Function(PosReceiptPrintVoid200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosReceiptPrintVoid200ResponseDataBuilder toBuilder() =>
      PosReceiptPrintVoid200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosReceiptPrintVoid200ResponseData &&
        print == other.print &&
        receipt == other.receipt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, print.hashCode);
    _$hash = $jc(_$hash, receipt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosReceiptPrintVoid200ResponseData')
          ..add('print', print)
          ..add('receipt', receipt))
        .toString();
  }
}

class PosReceiptPrintVoid200ResponseDataBuilder
    implements
        Builder<PosReceiptPrintVoid200ResponseData,
            PosReceiptPrintVoid200ResponseDataBuilder> {
  _$PosReceiptPrintVoid200ResponseData? _$v;

  JsonObject? _print;
  JsonObject? get print => _$this._print;
  set print(JsonObject? print) => _$this._print = print;

  JsonObject? _receipt;
  JsonObject? get receipt => _$this._receipt;
  set receipt(JsonObject? receipt) => _$this._receipt = receipt;

  PosReceiptPrintVoid200ResponseDataBuilder() {
    PosReceiptPrintVoid200ResponseData._defaults(this);
  }

  PosReceiptPrintVoid200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _print = $v.print;
      _receipt = $v.receipt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosReceiptPrintVoid200ResponseData other) {
    _$v = other as _$PosReceiptPrintVoid200ResponseData;
  }

  @override
  void update(
      void Function(PosReceiptPrintVoid200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosReceiptPrintVoid200ResponseData build() => _build();

  _$PosReceiptPrintVoid200ResponseData _build() {
    final _$result = _$v ??
        _$PosReceiptPrintVoid200ResponseData._(
          print: BuiltValueNullFieldError.checkNotNull(
              print, r'PosReceiptPrintVoid200ResponseData', 'print'),
          receipt: BuiltValueNullFieldError.checkNotNull(
              receipt, r'PosReceiptPrintVoid200ResponseData', 'receipt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
