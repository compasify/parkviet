// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_buyer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EinvoiceBuyer extends EinvoiceBuyer {
  @override
  final String? taxCode;
  @override
  final String? name;
  @override
  final String? address;
  @override
  final String? personalId;
  @override
  final String? phone;
  @override
  final String? passportNo;
  @override
  final String? nationality;
  @override
  final String? email;
  @override
  final String? buyerNote;
  @override
  final String? label;

  factory _$EinvoiceBuyer([void Function(EinvoiceBuyerBuilder)? updates]) =>
      (EinvoiceBuyerBuilder()..update(updates))._build();

  _$EinvoiceBuyer._(
      {this.taxCode,
      this.name,
      this.address,
      this.personalId,
      this.phone,
      this.passportNo,
      this.nationality,
      this.email,
      this.buyerNote,
      this.label})
      : super._();
  @override
  EinvoiceBuyer rebuild(void Function(EinvoiceBuyerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceBuyerBuilder toBuilder() => EinvoiceBuyerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceBuyer &&
        taxCode == other.taxCode &&
        name == other.name &&
        address == other.address &&
        personalId == other.personalId &&
        phone == other.phone &&
        passportNo == other.passportNo &&
        nationality == other.nationality &&
        email == other.email &&
        buyerNote == other.buyerNote &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taxCode.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, personalId.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, passportNo.hashCode);
    _$hash = $jc(_$hash, nationality.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, buyerNote.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceBuyer')
          ..add('taxCode', taxCode)
          ..add('name', name)
          ..add('address', address)
          ..add('personalId', personalId)
          ..add('phone', phone)
          ..add('passportNo', passportNo)
          ..add('nationality', nationality)
          ..add('email', email)
          ..add('buyerNote', buyerNote)
          ..add('label', label))
        .toString();
  }
}

class EinvoiceBuyerBuilder
    implements Builder<EinvoiceBuyer, EinvoiceBuyerBuilder> {
  _$EinvoiceBuyer? _$v;

  String? _taxCode;
  String? get taxCode => _$this._taxCode;
  set taxCode(String? taxCode) => _$this._taxCode = taxCode;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _personalId;
  String? get personalId => _$this._personalId;
  set personalId(String? personalId) => _$this._personalId = personalId;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _passportNo;
  String? get passportNo => _$this._passportNo;
  set passportNo(String? passportNo) => _$this._passportNo = passportNo;

  String? _nationality;
  String? get nationality => _$this._nationality;
  set nationality(String? nationality) => _$this._nationality = nationality;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _buyerNote;
  String? get buyerNote => _$this._buyerNote;
  set buyerNote(String? buyerNote) => _$this._buyerNote = buyerNote;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  EinvoiceBuyerBuilder() {
    EinvoiceBuyer._defaults(this);
  }

  EinvoiceBuyerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taxCode = $v.taxCode;
      _name = $v.name;
      _address = $v.address;
      _personalId = $v.personalId;
      _phone = $v.phone;
      _passportNo = $v.passportNo;
      _nationality = $v.nationality;
      _email = $v.email;
      _buyerNote = $v.buyerNote;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceBuyer other) {
    _$v = other as _$EinvoiceBuyer;
  }

  @override
  void update(void Function(EinvoiceBuyerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceBuyer build() => _build();

  _$EinvoiceBuyer _build() {
    final _$result = _$v ??
        _$EinvoiceBuyer._(
          taxCode: taxCode,
          name: name,
          address: address,
          personalId: personalId,
          phone: phone,
          passportNo: passportNo,
          nationality: nationality,
          email: email,
          buyerNote: buyerNote,
          label: label,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
