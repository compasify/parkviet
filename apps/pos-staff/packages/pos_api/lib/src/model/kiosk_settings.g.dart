// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskSettings extends KioskSettings {
  @override
  final String branchId;
  @override
  final int kioskIdleSeconds;
  @override
  final int kioskQrTimeoutSeconds;
  @override
  final bool kioskKitchenBeforePayment;
  @override
  final BuiltList<KioskRegister> kiosks;

  factory _$KioskSettings([void Function(KioskSettingsBuilder)? updates]) =>
      (KioskSettingsBuilder()..update(updates))._build();

  _$KioskSettings._(
      {required this.branchId,
      required this.kioskIdleSeconds,
      required this.kioskQrTimeoutSeconds,
      required this.kioskKitchenBeforePayment,
      required this.kiosks})
      : super._();
  @override
  KioskSettings rebuild(void Function(KioskSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskSettingsBuilder toBuilder() => KioskSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskSettings &&
        branchId == other.branchId &&
        kioskIdleSeconds == other.kioskIdleSeconds &&
        kioskQrTimeoutSeconds == other.kioskQrTimeoutSeconds &&
        kioskKitchenBeforePayment == other.kioskKitchenBeforePayment &&
        kiosks == other.kiosks;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, kioskIdleSeconds.hashCode);
    _$hash = $jc(_$hash, kioskQrTimeoutSeconds.hashCode);
    _$hash = $jc(_$hash, kioskKitchenBeforePayment.hashCode);
    _$hash = $jc(_$hash, kiosks.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskSettings')
          ..add('branchId', branchId)
          ..add('kioskIdleSeconds', kioskIdleSeconds)
          ..add('kioskQrTimeoutSeconds', kioskQrTimeoutSeconds)
          ..add('kioskKitchenBeforePayment', kioskKitchenBeforePayment)
          ..add('kiosks', kiosks))
        .toString();
  }
}

class KioskSettingsBuilder
    implements Builder<KioskSettings, KioskSettingsBuilder> {
  _$KioskSettings? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  int? _kioskIdleSeconds;
  int? get kioskIdleSeconds => _$this._kioskIdleSeconds;
  set kioskIdleSeconds(int? kioskIdleSeconds) =>
      _$this._kioskIdleSeconds = kioskIdleSeconds;

  int? _kioskQrTimeoutSeconds;
  int? get kioskQrTimeoutSeconds => _$this._kioskQrTimeoutSeconds;
  set kioskQrTimeoutSeconds(int? kioskQrTimeoutSeconds) =>
      _$this._kioskQrTimeoutSeconds = kioskQrTimeoutSeconds;

  bool? _kioskKitchenBeforePayment;
  bool? get kioskKitchenBeforePayment => _$this._kioskKitchenBeforePayment;
  set kioskKitchenBeforePayment(bool? kioskKitchenBeforePayment) =>
      _$this._kioskKitchenBeforePayment = kioskKitchenBeforePayment;

  ListBuilder<KioskRegister>? _kiosks;
  ListBuilder<KioskRegister> get kiosks =>
      _$this._kiosks ??= ListBuilder<KioskRegister>();
  set kiosks(ListBuilder<KioskRegister>? kiosks) => _$this._kiosks = kiosks;

  KioskSettingsBuilder() {
    KioskSettings._defaults(this);
  }

  KioskSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _kioskIdleSeconds = $v.kioskIdleSeconds;
      _kioskQrTimeoutSeconds = $v.kioskQrTimeoutSeconds;
      _kioskKitchenBeforePayment = $v.kioskKitchenBeforePayment;
      _kiosks = $v.kiosks.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskSettings other) {
    _$v = other as _$KioskSettings;
  }

  @override
  void update(void Function(KioskSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskSettings build() => _build();

  _$KioskSettings _build() {
    _$KioskSettings _$result;
    try {
      _$result = _$v ??
          _$KioskSettings._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'KioskSettings', 'branchId'),
            kioskIdleSeconds: BuiltValueNullFieldError.checkNotNull(
                kioskIdleSeconds, r'KioskSettings', 'kioskIdleSeconds'),
            kioskQrTimeoutSeconds: BuiltValueNullFieldError.checkNotNull(
                kioskQrTimeoutSeconds,
                r'KioskSettings',
                'kioskQrTimeoutSeconds'),
            kioskKitchenBeforePayment: BuiltValueNullFieldError.checkNotNull(
                kioskKitchenBeforePayment,
                r'KioskSettings',
                'kioskKitchenBeforePayment'),
            kiosks: kiosks.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'kiosks';
        kiosks.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskSettings', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
