// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_station_route_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosStationRouteCreate201Response
    extends PosStationRouteCreate201Response {
  @override
  final StationRoute data;

  factory _$PosStationRouteCreate201Response(
          [void Function(PosStationRouteCreate201ResponseBuilder)? updates]) =>
      (PosStationRouteCreate201ResponseBuilder()..update(updates))._build();

  _$PosStationRouteCreate201Response._({required this.data}) : super._();
  @override
  PosStationRouteCreate201Response rebuild(
          void Function(PosStationRouteCreate201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosStationRouteCreate201ResponseBuilder toBuilder() =>
      PosStationRouteCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosStationRouteCreate201Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosStationRouteCreate201Response')
          ..add('data', data))
        .toString();
  }
}

class PosStationRouteCreate201ResponseBuilder
    implements
        Builder<PosStationRouteCreate201Response,
            PosStationRouteCreate201ResponseBuilder> {
  _$PosStationRouteCreate201Response? _$v;

  StationRouteBuilder? _data;
  StationRouteBuilder get data => _$this._data ??= StationRouteBuilder();
  set data(StationRouteBuilder? data) => _$this._data = data;

  PosStationRouteCreate201ResponseBuilder() {
    PosStationRouteCreate201Response._defaults(this);
  }

  PosStationRouteCreate201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosStationRouteCreate201Response other) {
    _$v = other as _$PosStationRouteCreate201Response;
  }

  @override
  void update(void Function(PosStationRouteCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosStationRouteCreate201Response build() => _build();

  _$PosStationRouteCreate201Response _build() {
    _$PosStationRouteCreate201Response _$result;
    try {
      _$result = _$v ??
          _$PosStationRouteCreate201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosStationRouteCreate201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
