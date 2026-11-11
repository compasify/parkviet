// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_seat_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationSeatInput extends ReservationSeatInput {
  @override
  final String editorId;
  @override
  final int? guestCount;

  factory _$ReservationSeatInput(
          [void Function(ReservationSeatInputBuilder)? updates]) =>
      (ReservationSeatInputBuilder()..update(updates))._build();

  _$ReservationSeatInput._({required this.editorId, this.guestCount})
      : super._();
  @override
  ReservationSeatInput rebuild(
          void Function(ReservationSeatInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationSeatInputBuilder toBuilder() =>
      ReservationSeatInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationSeatInput &&
        editorId == other.editorId &&
        guestCount == other.guestCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationSeatInput')
          ..add('editorId', editorId)
          ..add('guestCount', guestCount))
        .toString();
  }
}

class ReservationSeatInputBuilder
    implements Builder<ReservationSeatInput, ReservationSeatInputBuilder> {
  _$ReservationSeatInput? _$v;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  ReservationSeatInputBuilder() {
    ReservationSeatInput._defaults(this);
  }

  ReservationSeatInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _editorId = $v.editorId;
      _guestCount = $v.guestCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationSeatInput other) {
    _$v = other as _$ReservationSeatInput;
  }

  @override
  void update(void Function(ReservationSeatInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationSeatInput build() => _build();

  _$ReservationSeatInput _build() {
    final _$result = _$v ??
        _$ReservationSeatInput._(
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'ReservationSeatInput', 'editorId'),
          guestCount: guestCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
