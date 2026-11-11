// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationList extends ReservationList {
  @override
  final BuiltList<Reservation> data;
  @override
  final ReservationListMeta meta;

  factory _$ReservationList([void Function(ReservationListBuilder)? updates]) =>
      (ReservationListBuilder()..update(updates))._build();

  _$ReservationList._({required this.data, required this.meta}) : super._();
  @override
  ReservationList rebuild(void Function(ReservationListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationListBuilder toBuilder() => ReservationListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationList && data == other.data && meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationList')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class ReservationListBuilder
    implements Builder<ReservationList, ReservationListBuilder> {
  _$ReservationList? _$v;

  ListBuilder<Reservation>? _data;
  ListBuilder<Reservation> get data =>
      _$this._data ??= ListBuilder<Reservation>();
  set data(ListBuilder<Reservation>? data) => _$this._data = data;

  ReservationListMetaBuilder? _meta;
  ReservationListMetaBuilder get meta =>
      _$this._meta ??= ReservationListMetaBuilder();
  set meta(ReservationListMetaBuilder? meta) => _$this._meta = meta;

  ReservationListBuilder() {
    ReservationList._defaults(this);
  }

  ReservationListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationList other) {
    _$v = other as _$ReservationList;
  }

  @override
  void update(void Function(ReservationListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationList build() => _build();

  _$ReservationList _build() {
    _$ReservationList _$result;
    try {
      _$result = _$v ??
          _$ReservationList._(
            data: data.build(),
            meta: meta.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
