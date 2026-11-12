// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_settings_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskSettingsInput extends KioskSettingsInput {
  @override
  final String branchId;
  @override
  final int? kioskIdleSeconds;
  @override
  final int? kioskQrTimeoutSeconds;
  @override
  final bool? kioskKitchenBeforePayment;

  factory _$KioskSettingsInput(
          [void Function(KioskSettingsInputBuilder)? updates]) =>
      (KioskSettingsInputBuilder()..update(updates))._build();

  _$KioskSettingsInput._(
      {required this.branchId,
      this.kioskIdleSeconds,
      this.kioskQrTimeoutSeconds,
      this.kioskKitchenBeforePayment})
      : super._();
  @override
  KioskSettingsInput rebuild(
          void Function(KioskSettingsInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskSettingsInputBuilder toBuilder() =>
      KioskSettingsInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskSettingsInput &&
        branchId == other.branchId &&
        kioskIdleSeconds == other.kioskIdleSeconds &&
        kioskQrTimeoutSeconds == other.kioskQrTimeoutSeconds &&
        kioskKitchenBeforePayment == other.kioskKitchenBeforePayment;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, kioskIdleSeconds.hashCode);
    _$hash = $jc(_$hash, kioskQrTimeoutSeconds.hashCode);
    _$hash = $jc(_$hash, kioskKitchenBeforePayment.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskSettingsInput')
          ..add('branchId', branchId)
          ..add('kioskIdleSeconds', kioskIdleSeconds)
          ..add('kioskQrTimeoutSeconds', kioskQrTimeoutSeconds)
          ..add('kioskKitchenBeforePayment', kioskKitchenBeforePayment))
        .toString();
  }
}

class KioskSettingsInputBuilder
    implements Builder<KioskSettingsInput, KioskSettingsInputBuilder> {
  _$KioskSettingsInput? _$v;

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

  KioskSettingsInputBuilder() {
    KioskSettingsInput._defaults(this);
  }

  KioskSettingsInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _kioskIdleSeconds = $v.kioskIdleSeconds;
      _kioskQrTimeoutSeconds = $v.kioskQrTimeoutSeconds;
      _kioskKitchenBeforePayment = $v.kioskKitchenBeforePayment;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskSettingsInput other) {
    _$v = other as _$KioskSettingsInput;
  }

  @override
  void update(void Function(KioskSettingsInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskSettingsInput build() => _build();

  _$KioskSettingsInput _build() {
    final _$result = _$v ??
        _$KioskSettingsInput._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'KioskSettingsInput', 'branchId'),
          kioskIdleSeconds: kioskIdleSeconds,
          kioskQrTimeoutSeconds: kioskQrTimeoutSeconds,
          kioskKitchenBeforePayment: kioskKitchenBeforePayment,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
