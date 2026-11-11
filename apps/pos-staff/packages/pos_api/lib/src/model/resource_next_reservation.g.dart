// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_next_reservation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResourceNextReservation extends ResourceNextReservation {
  @override
  final String id;
  @override
  final DateTime startsAt;
  @override
  final String guestName;
  @override
  final int partySize;

  factory _$ResourceNextReservation(
          [void Function(ResourceNextReservationBuilder)? updates]) =>
      (ResourceNextReservationBuilder()..update(updates))._build();

  _$ResourceNextReservation._(
      {required this.id,
      required this.startsAt,
      required this.guestName,
      required this.partySize})
      : super._();
  @override
  ResourceNextReservation rebuild(
          void Function(ResourceNextReservationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceNextReservationBuilder toBuilder() =>
      ResourceNextReservationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceNextReservation &&
        id == other.id &&
        startsAt == other.startsAt &&
        guestName == other.guestName &&
        partySize == other.partySize;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, guestName.hashCode);
    _$hash = $jc(_$hash, partySize.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResourceNextReservation')
          ..add('id', id)
          ..add('startsAt', startsAt)
          ..add('guestName', guestName)
          ..add('partySize', partySize))
        .toString();
  }
}

class ResourceNextReservationBuilder
    implements
        Builder<ResourceNextReservation, ResourceNextReservationBuilder> {
  _$ResourceNextReservation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  String? _guestName;
  String? get guestName => _$this._guestName;
  set guestName(String? guestName) => _$this._guestName = guestName;

  int? _partySize;
  int? get partySize => _$this._partySize;
  set partySize(int? partySize) => _$this._partySize = partySize;

  ResourceNextReservationBuilder() {
    ResourceNextReservation._defaults(this);
  }

  ResourceNextReservationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _startsAt = $v.startsAt;
      _guestName = $v.guestName;
      _partySize = $v.partySize;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceNextReservation other) {
    _$v = other as _$ResourceNextReservation;
  }

  @override
  void update(void Function(ResourceNextReservationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceNextReservation build() => _build();

  _$ResourceNextReservation _build() {
    final _$result = _$v ??
        _$ResourceNextReservation._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ResourceNextReservation', 'id'),
          startsAt: BuiltValueNullFieldError.checkNotNull(
              startsAt, r'ResourceNextReservation', 'startsAt'),
          guestName: BuiltValueNullFieldError.checkNotNull(
              guestName, r'ResourceNextReservation', 'guestName'),
          partySize: BuiltValueNullFieldError.checkNotNull(
              partySize, r'ResourceNextReservation', 'partySize'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
