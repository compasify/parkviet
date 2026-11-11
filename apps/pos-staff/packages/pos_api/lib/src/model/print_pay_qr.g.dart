// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_pay_qr.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintPayQr extends PrintPayQr {
  @override
  final String value;
  @override
  final String caption;
  @override
  final BuiltList<String> lines;

  factory _$PrintPayQr([void Function(PrintPayQrBuilder)? updates]) =>
      (PrintPayQrBuilder()..update(updates))._build();

  _$PrintPayQr._(
      {required this.value, required this.caption, required this.lines})
      : super._();
  @override
  PrintPayQr rebuild(void Function(PrintPayQrBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintPayQrBuilder toBuilder() => PrintPayQrBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintPayQr &&
        value == other.value &&
        caption == other.caption &&
        lines == other.lines;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, caption.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintPayQr')
          ..add('value', value)
          ..add('caption', caption)
          ..add('lines', lines))
        .toString();
  }
}

class PrintPayQrBuilder implements Builder<PrintPayQr, PrintPayQrBuilder> {
  _$PrintPayQr? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _caption;
  String? get caption => _$this._caption;
  set caption(String? caption) => _$this._caption = caption;

  ListBuilder<String>? _lines;
  ListBuilder<String> get lines => _$this._lines ??= ListBuilder<String>();
  set lines(ListBuilder<String>? lines) => _$this._lines = lines;

  PrintPayQrBuilder() {
    PrintPayQr._defaults(this);
  }

  PrintPayQrBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _caption = $v.caption;
      _lines = $v.lines.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintPayQr other) {
    _$v = other as _$PrintPayQr;
  }

  @override
  void update(void Function(PrintPayQrBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintPayQr build() => _build();

  _$PrintPayQr _build() {
    _$PrintPayQr _$result;
    try {
      _$result = _$v ??
          _$PrintPayQr._(
            value: BuiltValueNullFieldError.checkNotNull(
                value, r'PrintPayQr', 'value'),
            caption: BuiltValueNullFieldError.checkNotNull(
                caption, r'PrintPayQr', 'caption'),
            lines: lines.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lines';
        lines.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintPayQr', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
