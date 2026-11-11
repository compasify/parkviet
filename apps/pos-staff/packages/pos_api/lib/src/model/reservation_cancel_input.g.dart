// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_cancel_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReservationCancelInputStatusEnum
    _$reservationCancelInputStatusEnum_canceled =
    const ReservationCancelInputStatusEnum._('canceled');
const ReservationCancelInputStatusEnum
    _$reservationCancelInputStatusEnum_noShow =
    const ReservationCancelInputStatusEnum._('noShow');

ReservationCancelInputStatusEnum _$reservationCancelInputStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'canceled':
      return _$reservationCancelInputStatusEnum_canceled;
    case 'noShow':
      return _$reservationCancelInputStatusEnum_noShow;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationCancelInputStatusEnum>
    _$reservationCancelInputStatusEnumValues = BuiltSet<
        ReservationCancelInputStatusEnum>(const <ReservationCancelInputStatusEnum>[
  _$reservationCancelInputStatusEnum_canceled,
  _$reservationCancelInputStatusEnum_noShow,
]);

Serializer<ReservationCancelInputStatusEnum>
    _$reservationCancelInputStatusEnumSerializer =
    _$ReservationCancelInputStatusEnumSerializer();

class _$ReservationCancelInputStatusEnumSerializer
    implements PrimitiveSerializer<ReservationCancelInputStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'canceled': 'canceled',
    'noShow': 'no_show',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'canceled': 'canceled',
    'no_show': 'noShow',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationCancelInputStatusEnum];
  @override
  final String wireName = 'ReservationCancelInputStatusEnum';

  @override
  Object serialize(
          Serializers serializers, ReservationCancelInputStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationCancelInputStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationCancelInputStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationCancelInput extends ReservationCancelInput {
  @override
  final ReservationCancelInputStatusEnum? status;

  factory _$ReservationCancelInput(
          [void Function(ReservationCancelInputBuilder)? updates]) =>
      (ReservationCancelInputBuilder()..update(updates))._build();

  _$ReservationCancelInput._({this.status}) : super._();
  @override
  ReservationCancelInput rebuild(
          void Function(ReservationCancelInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationCancelInputBuilder toBuilder() =>
      ReservationCancelInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationCancelInput && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationCancelInput')
          ..add('status', status))
        .toString();
  }
}

class ReservationCancelInputBuilder
    implements Builder<ReservationCancelInput, ReservationCancelInputBuilder> {
  _$ReservationCancelInput? _$v;

  ReservationCancelInputStatusEnum? _status;
  ReservationCancelInputStatusEnum? get status => _$this._status;
  set status(ReservationCancelInputStatusEnum? status) =>
      _$this._status = status;

  ReservationCancelInputBuilder() {
    ReservationCancelInput._defaults(this);
  }

  ReservationCancelInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationCancelInput other) {
    _$v = other as _$ReservationCancelInput;
  }

  @override
  void update(void Function(ReservationCancelInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationCancelInput build() => _build();

  _$ReservationCancelInput _build() {
    final _$result = _$v ??
        _$ReservationCancelInput._(
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
