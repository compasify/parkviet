// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_register.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskRegister extends KioskRegister {
  @override
  final KioskRegisterRef register;
  @override
  final KioskDeviceRef? device;
  @override
  final bool provisioned;
  @override
  final KioskShiftRef? shift;
  @override
  final int waitingOrders;

  factory _$KioskRegister([void Function(KioskRegisterBuilder)? updates]) =>
      (KioskRegisterBuilder()..update(updates))._build();

  _$KioskRegister._(
      {required this.register,
      this.device,
      required this.provisioned,
      this.shift,
      required this.waitingOrders})
      : super._();
  @override
  KioskRegister rebuild(void Function(KioskRegisterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskRegisterBuilder toBuilder() => KioskRegisterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskRegister &&
        register == other.register &&
        device == other.device &&
        provisioned == other.provisioned &&
        shift == other.shift &&
        waitingOrders == other.waitingOrders;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, register.hashCode);
    _$hash = $jc(_$hash, device.hashCode);
    _$hash = $jc(_$hash, provisioned.hashCode);
    _$hash = $jc(_$hash, shift.hashCode);
    _$hash = $jc(_$hash, waitingOrders.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskRegister')
          ..add('register', register)
          ..add('device', device)
          ..add('provisioned', provisioned)
          ..add('shift', shift)
          ..add('waitingOrders', waitingOrders))
        .toString();
  }
}

class KioskRegisterBuilder
    implements Builder<KioskRegister, KioskRegisterBuilder> {
  _$KioskRegister? _$v;

  KioskRegisterRefBuilder? _register;
  KioskRegisterRefBuilder get register =>
      _$this._register ??= KioskRegisterRefBuilder();
  set register(KioskRegisterRefBuilder? register) =>
      _$this._register = register;

  KioskDeviceRefBuilder? _device;
  KioskDeviceRefBuilder get device =>
      _$this._device ??= KioskDeviceRefBuilder();
  set device(KioskDeviceRefBuilder? device) => _$this._device = device;

  bool? _provisioned;
  bool? get provisioned => _$this._provisioned;
  set provisioned(bool? provisioned) => _$this._provisioned = provisioned;

  KioskShiftRefBuilder? _shift;
  KioskShiftRefBuilder get shift => _$this._shift ??= KioskShiftRefBuilder();
  set shift(KioskShiftRefBuilder? shift) => _$this._shift = shift;

  int? _waitingOrders;
  int? get waitingOrders => _$this._waitingOrders;
  set waitingOrders(int? waitingOrders) =>
      _$this._waitingOrders = waitingOrders;

  KioskRegisterBuilder() {
    KioskRegister._defaults(this);
  }

  KioskRegisterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _register = $v.register.toBuilder();
      _device = $v.device?.toBuilder();
      _provisioned = $v.provisioned;
      _shift = $v.shift?.toBuilder();
      _waitingOrders = $v.waitingOrders;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskRegister other) {
    _$v = other as _$KioskRegister;
  }

  @override
  void update(void Function(KioskRegisterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskRegister build() => _build();

  _$KioskRegister _build() {
    _$KioskRegister _$result;
    try {
      _$result = _$v ??
          _$KioskRegister._(
            register: register.build(),
            device: _device?.build(),
            provisioned: BuiltValueNullFieldError.checkNotNull(
                provisioned, r'KioskRegister', 'provisioned'),
            shift: _shift?.build(),
            waitingOrders: BuiltValueNullFieldError.checkNotNull(
                waitingOrders, r'KioskRegister', 'waitingOrders'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'register';
        register.build();
        _$failedField = 'device';
        _device?.build();

        _$failedField = 'shift';
        _shift?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskRegister', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
