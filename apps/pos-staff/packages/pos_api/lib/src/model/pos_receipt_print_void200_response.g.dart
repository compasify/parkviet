// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_receipt_print_void200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosReceiptPrintVoid200Response extends PosReceiptPrintVoid200Response {
  @override
  final PosReceiptPrintVoid200ResponseData data;

  factory _$PosReceiptPrintVoid200Response(
          [void Function(PosReceiptPrintVoid200ResponseBuilder)? updates]) =>
      (PosReceiptPrintVoid200ResponseBuilder()..update(updates))._build();

  _$PosReceiptPrintVoid200Response._({required this.data}) : super._();
  @override
  PosReceiptPrintVoid200Response rebuild(
          void Function(PosReceiptPrintVoid200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosReceiptPrintVoid200ResponseBuilder toBuilder() =>
      PosReceiptPrintVoid200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosReceiptPrintVoid200Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosReceiptPrintVoid200Response')
          ..add('data', data))
        .toString();
  }
}

class PosReceiptPrintVoid200ResponseBuilder
    implements
        Builder<PosReceiptPrintVoid200Response,
            PosReceiptPrintVoid200ResponseBuilder> {
  _$PosReceiptPrintVoid200Response? _$v;

  PosReceiptPrintVoid200ResponseDataBuilder? _data;
  PosReceiptPrintVoid200ResponseDataBuilder get data =>
      _$this._data ??= PosReceiptPrintVoid200ResponseDataBuilder();
  set data(PosReceiptPrintVoid200ResponseDataBuilder? data) =>
      _$this._data = data;

  PosReceiptPrintVoid200ResponseBuilder() {
    PosReceiptPrintVoid200Response._defaults(this);
  }

  PosReceiptPrintVoid200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosReceiptPrintVoid200Response other) {
    _$v = other as _$PosReceiptPrintVoid200Response;
  }

  @override
  void update(void Function(PosReceiptPrintVoid200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosReceiptPrintVoid200Response build() => _build();

  _$PosReceiptPrintVoid200Response _build() {
    _$PosReceiptPrintVoid200Response _$result;
    try {
      _$result = _$v ??
          _$PosReceiptPrintVoid200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosReceiptPrintVoid200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
