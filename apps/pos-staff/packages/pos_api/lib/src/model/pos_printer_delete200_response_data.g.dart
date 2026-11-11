// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printer_delete200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrinterDelete200ResponseData
    extends PosPrinterDelete200ResponseData {
  @override
  final String id;

  factory _$PosPrinterDelete200ResponseData(
          [void Function(PosPrinterDelete200ResponseDataBuilder)? updates]) =>
      (PosPrinterDelete200ResponseDataBuilder()..update(updates))._build();

  _$PosPrinterDelete200ResponseData._({required this.id}) : super._();
  @override
  PosPrinterDelete200ResponseData rebuild(
          void Function(PosPrinterDelete200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinterDelete200ResponseDataBuilder toBuilder() =>
      PosPrinterDelete200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinterDelete200ResponseData && id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosPrinterDelete200ResponseData')
          ..add('id', id))
        .toString();
  }
}

class PosPrinterDelete200ResponseDataBuilder
    implements
        Builder<PosPrinterDelete200ResponseData,
            PosPrinterDelete200ResponseDataBuilder> {
  _$PosPrinterDelete200ResponseData? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PosPrinterDelete200ResponseDataBuilder() {
    PosPrinterDelete200ResponseData._defaults(this);
  }

  PosPrinterDelete200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrinterDelete200ResponseData other) {
    _$v = other as _$PosPrinterDelete200ResponseData;
  }

  @override
  void update(void Function(PosPrinterDelete200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinterDelete200ResponseData build() => _build();

  _$PosPrinterDelete200ResponseData _build() {
    final _$result = _$v ??
        _$PosPrinterDelete200ResponseData._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PosPrinterDelete200ResponseData', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
