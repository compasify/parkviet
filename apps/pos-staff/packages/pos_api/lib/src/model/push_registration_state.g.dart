// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_registration_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushRegistrationState extends PushRegistrationState {
  @override
  final PushRegistration? registration;
  @override
  final bool relay;

  factory _$PushRegistrationState(
          [void Function(PushRegistrationStateBuilder)? updates]) =>
      (PushRegistrationStateBuilder()..update(updates))._build();

  _$PushRegistrationState._({this.registration, required this.relay})
      : super._();
  @override
  PushRegistrationState rebuild(
          void Function(PushRegistrationStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushRegistrationStateBuilder toBuilder() =>
      PushRegistrationStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushRegistrationState &&
        registration == other.registration &&
        relay == other.relay;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registration.hashCode);
    _$hash = $jc(_$hash, relay.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushRegistrationState')
          ..add('registration', registration)
          ..add('relay', relay))
        .toString();
  }
}

class PushRegistrationStateBuilder
    implements Builder<PushRegistrationState, PushRegistrationStateBuilder> {
  _$PushRegistrationState? _$v;

  PushRegistrationBuilder? _registration;
  PushRegistrationBuilder get registration =>
      _$this._registration ??= PushRegistrationBuilder();
  set registration(PushRegistrationBuilder? registration) =>
      _$this._registration = registration;

  bool? _relay;
  bool? get relay => _$this._relay;
  set relay(bool? relay) => _$this._relay = relay;

  PushRegistrationStateBuilder() {
    PushRegistrationState._defaults(this);
  }

  PushRegistrationStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registration = $v.registration?.toBuilder();
      _relay = $v.relay;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushRegistrationState other) {
    _$v = other as _$PushRegistrationState;
  }

  @override
  void update(void Function(PushRegistrationStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushRegistrationState build() => _build();

  _$PushRegistrationState _build() {
    _$PushRegistrationState _$result;
    try {
      _$result = _$v ??
          _$PushRegistrationState._(
            registration: _registration?.build(),
            relay: BuiltValueNullFieldError.checkNotNull(
                relay, r'PushRegistrationState', 'relay'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'registration';
        _registration?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PushRegistrationState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
