// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_seller.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EinvoiceSeller extends EinvoiceSeller {
  @override
  final String? name;
  @override
  final String? taxCode;
  @override
  final String? address;
  @override
  final String? outletCode;
  @override
  final String? outletName;

  factory _$EinvoiceSeller([void Function(EinvoiceSellerBuilder)? updates]) =>
      (EinvoiceSellerBuilder()..update(updates))._build();

  _$EinvoiceSeller._(
      {this.name, this.taxCode, this.address, this.outletCode, this.outletName})
      : super._();
  @override
  EinvoiceSeller rebuild(void Function(EinvoiceSellerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceSellerBuilder toBuilder() => EinvoiceSellerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceSeller &&
        name == other.name &&
        taxCode == other.taxCode &&
        address == other.address &&
        outletCode == other.outletCode &&
        outletName == other.outletName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, taxCode.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, outletCode.hashCode);
    _$hash = $jc(_$hash, outletName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceSeller')
          ..add('name', name)
          ..add('taxCode', taxCode)
          ..add('address', address)
          ..add('outletCode', outletCode)
          ..add('outletName', outletName))
        .toString();
  }
}

class EinvoiceSellerBuilder
    implements Builder<EinvoiceSeller, EinvoiceSellerBuilder> {
  _$EinvoiceSeller? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _taxCode;
  String? get taxCode => _$this._taxCode;
  set taxCode(String? taxCode) => _$this._taxCode = taxCode;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _outletCode;
  String? get outletCode => _$this._outletCode;
  set outletCode(String? outletCode) => _$this._outletCode = outletCode;

  String? _outletName;
  String? get outletName => _$this._outletName;
  set outletName(String? outletName) => _$this._outletName = outletName;

  EinvoiceSellerBuilder() {
    EinvoiceSeller._defaults(this);
  }

  EinvoiceSellerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _taxCode = $v.taxCode;
      _address = $v.address;
      _outletCode = $v.outletCode;
      _outletName = $v.outletName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceSeller other) {
    _$v = other as _$EinvoiceSeller;
  }

  @override
  void update(void Function(EinvoiceSellerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceSeller build() => _build();

  _$EinvoiceSeller _build() {
    final _$result = _$v ??
        _$EinvoiceSeller._(
          name: name,
          taxCode: taxCode,
          address: address,
          outletCode: outletCode,
          outletName: outletName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
