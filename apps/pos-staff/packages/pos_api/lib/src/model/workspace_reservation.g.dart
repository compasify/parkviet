// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_reservation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceReservation extends WorkspaceReservation {
  @override
  final String id;
  @override
  final String guestName;
  @override
  final int partySize;
  @override
  final String status;
  @override
  final int revision;
  @override
  final String depositHeld;
  @override
  final BuiltList<ReservationDeposit> deposits;

  factory _$WorkspaceReservation(
          [void Function(WorkspaceReservationBuilder)? updates]) =>
      (WorkspaceReservationBuilder()..update(updates))._build();

  _$WorkspaceReservation._(
      {required this.id,
      required this.guestName,
      required this.partySize,
      required this.status,
      required this.revision,
      required this.depositHeld,
      required this.deposits})
      : super._();
  @override
  WorkspaceReservation rebuild(
          void Function(WorkspaceReservationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceReservationBuilder toBuilder() =>
      WorkspaceReservationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceReservation &&
        id == other.id &&
        guestName == other.guestName &&
        partySize == other.partySize &&
        status == other.status &&
        revision == other.revision &&
        depositHeld == other.depositHeld &&
        deposits == other.deposits;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, guestName.hashCode);
    _$hash = $jc(_$hash, partySize.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, depositHeld.hashCode);
    _$hash = $jc(_$hash, deposits.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceReservation')
          ..add('id', id)
          ..add('guestName', guestName)
          ..add('partySize', partySize)
          ..add('status', status)
          ..add('revision', revision)
          ..add('depositHeld', depositHeld)
          ..add('deposits', deposits))
        .toString();
  }
}

class WorkspaceReservationBuilder
    implements Builder<WorkspaceReservation, WorkspaceReservationBuilder> {
  _$WorkspaceReservation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _guestName;
  String? get guestName => _$this._guestName;
  set guestName(String? guestName) => _$this._guestName = guestName;

  int? _partySize;
  int? get partySize => _$this._partySize;
  set partySize(int? partySize) => _$this._partySize = partySize;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  String? _depositHeld;
  String? get depositHeld => _$this._depositHeld;
  set depositHeld(String? depositHeld) => _$this._depositHeld = depositHeld;

  ListBuilder<ReservationDeposit>? _deposits;
  ListBuilder<ReservationDeposit> get deposits =>
      _$this._deposits ??= ListBuilder<ReservationDeposit>();
  set deposits(ListBuilder<ReservationDeposit>? deposits) =>
      _$this._deposits = deposits;

  WorkspaceReservationBuilder() {
    WorkspaceReservation._defaults(this);
  }

  WorkspaceReservationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _guestName = $v.guestName;
      _partySize = $v.partySize;
      _status = $v.status;
      _revision = $v.revision;
      _depositHeld = $v.depositHeld;
      _deposits = $v.deposits.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceReservation other) {
    _$v = other as _$WorkspaceReservation;
  }

  @override
  void update(void Function(WorkspaceReservationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceReservation build() => _build();

  _$WorkspaceReservation _build() {
    _$WorkspaceReservation _$result;
    try {
      _$result = _$v ??
          _$WorkspaceReservation._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'WorkspaceReservation', 'id'),
            guestName: BuiltValueNullFieldError.checkNotNull(
                guestName, r'WorkspaceReservation', 'guestName'),
            partySize: BuiltValueNullFieldError.checkNotNull(
                partySize, r'WorkspaceReservation', 'partySize'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'WorkspaceReservation', 'status'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'WorkspaceReservation', 'revision'),
            depositHeld: BuiltValueNullFieldError.checkNotNull(
                depositHeld, r'WorkspaceReservation', 'depositHeld'),
            deposits: deposits.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deposits';
        deposits.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkspaceReservation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
