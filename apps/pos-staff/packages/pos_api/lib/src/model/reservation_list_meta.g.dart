// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_list_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationListMeta extends ReservationListMeta {
  @override
  final DateTime from;
  @override
  final DateTime to;

  factory _$ReservationListMeta(
          [void Function(ReservationListMetaBuilder)? updates]) =>
      (ReservationListMetaBuilder()..update(updates))._build();

  _$ReservationListMeta._({required this.from, required this.to}) : super._();
  @override
  ReservationListMeta rebuild(
          void Function(ReservationListMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationListMetaBuilder toBuilder() =>
      ReservationListMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationListMeta && from == other.from && to == other.to;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationListMeta')
          ..add('from', from)
          ..add('to', to))
        .toString();
  }
}

class ReservationListMetaBuilder
    implements Builder<ReservationListMeta, ReservationListMetaBuilder> {
  _$ReservationListMeta? _$v;

  DateTime? _from;
  DateTime? get from => _$this._from;
  set from(DateTime? from) => _$this._from = from;

  DateTime? _to;
  DateTime? get to => _$this._to;
  set to(DateTime? to) => _$this._to = to;

  ReservationListMetaBuilder() {
    ReservationListMeta._defaults(this);
  }

  ReservationListMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _from = $v.from;
      _to = $v.to;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationListMeta other) {
    _$v = other as _$ReservationListMeta;
  }

  @override
  void update(void Function(ReservationListMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationListMeta build() => _build();

  _$ReservationListMeta _build() {
    final _$result = _$v ??
        _$ReservationListMeta._(
          from: BuiltValueNullFieldError.checkNotNull(
              from, r'ReservationListMeta', 'from'),
          to: BuiltValueNullFieldError.checkNotNull(
              to, r'ReservationListMeta', 'to'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
