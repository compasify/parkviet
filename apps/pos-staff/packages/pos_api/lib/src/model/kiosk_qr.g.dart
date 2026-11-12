// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_qr.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskQr extends KioskQr {
  @override
  final String qrUrl;
  @override
  final String? bankName;
  @override
  final String accountNumber;
  @override
  final String? accountName;
  @override
  final String transferNote;

  factory _$KioskQr([void Function(KioskQrBuilder)? updates]) =>
      (KioskQrBuilder()..update(updates))._build();

  _$KioskQr._(
      {required this.qrUrl,
      this.bankName,
      required this.accountNumber,
      this.accountName,
      required this.transferNote})
      : super._();
  @override
  KioskQr rebuild(void Function(KioskQrBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskQrBuilder toBuilder() => KioskQrBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskQr &&
        qrUrl == other.qrUrl &&
        bankName == other.bankName &&
        accountNumber == other.accountNumber &&
        accountName == other.accountName &&
        transferNote == other.transferNote;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, qrUrl.hashCode);
    _$hash = $jc(_$hash, bankName.hashCode);
    _$hash = $jc(_$hash, accountNumber.hashCode);
    _$hash = $jc(_$hash, accountName.hashCode);
    _$hash = $jc(_$hash, transferNote.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskQr')
          ..add('qrUrl', qrUrl)
          ..add('bankName', bankName)
          ..add('accountNumber', accountNumber)
          ..add('accountName', accountName)
          ..add('transferNote', transferNote))
        .toString();
  }
}

class KioskQrBuilder implements Builder<KioskQr, KioskQrBuilder> {
  _$KioskQr? _$v;

  String? _qrUrl;
  String? get qrUrl => _$this._qrUrl;
  set qrUrl(String? qrUrl) => _$this._qrUrl = qrUrl;

  String? _bankName;
  String? get bankName => _$this._bankName;
  set bankName(String? bankName) => _$this._bankName = bankName;

  String? _accountNumber;
  String? get accountNumber => _$this._accountNumber;
  set accountNumber(String? accountNumber) =>
      _$this._accountNumber = accountNumber;

  String? _accountName;
  String? get accountName => _$this._accountName;
  set accountName(String? accountName) => _$this._accountName = accountName;

  String? _transferNote;
  String? get transferNote => _$this._transferNote;
  set transferNote(String? transferNote) => _$this._transferNote = transferNote;

  KioskQrBuilder() {
    KioskQr._defaults(this);
  }

  KioskQrBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _qrUrl = $v.qrUrl;
      _bankName = $v.bankName;
      _accountNumber = $v.accountNumber;
      _accountName = $v.accountName;
      _transferNote = $v.transferNote;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskQr other) {
    _$v = other as _$KioskQr;
  }

  @override
  void update(void Function(KioskQrBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskQr build() => _build();

  _$KioskQr _build() {
    final _$result = _$v ??
        _$KioskQr._(
          qrUrl:
              BuiltValueNullFieldError.checkNotNull(qrUrl, r'KioskQr', 'qrUrl'),
          bankName: bankName,
          accountNumber: BuiltValueNullFieldError.checkNotNull(
              accountNumber, r'KioskQr', 'accountNumber'),
          accountName: accountName,
          transferNote: BuiltValueNullFieldError.checkNotNull(
              transferNote, r'KioskQr', 'transferNote'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
