// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printer_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrinterCreate201Response extends PosPrinterCreate201Response {
  @override
  final Printer data;

  factory _$PosPrinterCreate201Response(
          [void Function(PosPrinterCreate201ResponseBuilder)? updates]) =>
      (PosPrinterCreate201ResponseBuilder()..update(updates))._build();

  _$PosPrinterCreate201Response._({required this.data}) : super._();
  @override
  PosPrinterCreate201Response rebuild(
          void Function(PosPrinterCreate201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinterCreate201ResponseBuilder toBuilder() =>
      PosPrinterCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinterCreate201Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosPrinterCreate201Response')
          ..add('data', data))
        .toString();
  }
}

class PosPrinterCreate201ResponseBuilder
    implements
        Builder<PosPrinterCreate201Response,
            PosPrinterCreate201ResponseBuilder> {
  _$PosPrinterCreate201Response? _$v;

  PrinterBuilder? _data;
  PrinterBuilder get data => _$this._data ??= PrinterBuilder();
  set data(PrinterBuilder? data) => _$this._data = data;

  PosPrinterCreate201ResponseBuilder() {
    PosPrinterCreate201Response._defaults(this);
  }

  PosPrinterCreate201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrinterCreate201Response other) {
    _$v = other as _$PosPrinterCreate201Response;
  }

  @override
  void update(void Function(PosPrinterCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinterCreate201Response build() => _build();

  _$PosPrinterCreate201Response _build() {
    _$PosPrinterCreate201Response _$result;
    try {
      _$result = _$v ??
          _$PosPrinterCreate201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrinterCreate201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
