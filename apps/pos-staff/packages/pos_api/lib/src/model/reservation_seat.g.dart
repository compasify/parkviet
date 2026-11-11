// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_seat.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationSeat extends ReservationSeat {
  @override
  final Reservation reservation;
  @override
  final Workspace workspace;

  factory _$ReservationSeat([void Function(ReservationSeatBuilder)? updates]) =>
      (ReservationSeatBuilder()..update(updates))._build();

  _$ReservationSeat._({required this.reservation, required this.workspace})
      : super._();
  @override
  ReservationSeat rebuild(void Function(ReservationSeatBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationSeatBuilder toBuilder() => ReservationSeatBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationSeat &&
        reservation == other.reservation &&
        workspace == other.workspace;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservation.hashCode);
    _$hash = $jc(_$hash, workspace.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationSeat')
          ..add('reservation', reservation)
          ..add('workspace', workspace))
        .toString();
  }
}

class ReservationSeatBuilder
    implements Builder<ReservationSeat, ReservationSeatBuilder> {
  _$ReservationSeat? _$v;

  ReservationBuilder? _reservation;
  ReservationBuilder get reservation =>
      _$this._reservation ??= ReservationBuilder();
  set reservation(ReservationBuilder? reservation) =>
      _$this._reservation = reservation;

  WorkspaceBuilder? _workspace;
  WorkspaceBuilder get workspace => _$this._workspace ??= WorkspaceBuilder();
  set workspace(WorkspaceBuilder? workspace) => _$this._workspace = workspace;

  ReservationSeatBuilder() {
    ReservationSeat._defaults(this);
  }

  ReservationSeatBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservation = $v.reservation.toBuilder();
      _workspace = $v.workspace.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationSeat other) {
    _$v = other as _$ReservationSeat;
  }

  @override
  void update(void Function(ReservationSeatBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationSeat build() => _build();

  _$ReservationSeat _build() {
    _$ReservationSeat _$result;
    try {
      _$result = _$v ??
          _$ReservationSeat._(
            reservation: reservation.build(),
            workspace: workspace.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'reservation';
        reservation.build();
        _$failedField = 'workspace';
        workspace.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationSeat', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
