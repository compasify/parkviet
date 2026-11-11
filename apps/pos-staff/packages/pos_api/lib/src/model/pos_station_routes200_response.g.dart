// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_station_routes200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosStationRoutes200Response extends PosStationRoutes200Response {
  @override
  final BuiltList<StationRoute> data;

  factory _$PosStationRoutes200Response(
          [void Function(PosStationRoutes200ResponseBuilder)? updates]) =>
      (PosStationRoutes200ResponseBuilder()..update(updates))._build();

  _$PosStationRoutes200Response._({required this.data}) : super._();
  @override
  PosStationRoutes200Response rebuild(
          void Function(PosStationRoutes200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosStationRoutes200ResponseBuilder toBuilder() =>
      PosStationRoutes200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosStationRoutes200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosStationRoutes200Response')
          ..add('data', data))
        .toString();
  }
}

class PosStationRoutes200ResponseBuilder
    implements
        Builder<PosStationRoutes200Response,
            PosStationRoutes200ResponseBuilder> {
  _$PosStationRoutes200Response? _$v;

  ListBuilder<StationRoute>? _data;
  ListBuilder<StationRoute> get data =>
      _$this._data ??= ListBuilder<StationRoute>();
  set data(ListBuilder<StationRoute>? data) => _$this._data = data;

  PosStationRoutes200ResponseBuilder() {
    PosStationRoutes200Response._defaults(this);
  }

  PosStationRoutes200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosStationRoutes200Response other) {
    _$v = other as _$PosStationRoutes200Response;
  }

  @override
  void update(void Function(PosStationRoutes200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosStationRoutes200Response build() => _build();

  _$PosStationRoutes200Response _build() {
    _$PosStationRoutes200Response _$result;
    try {
      _$result = _$v ??
          _$PosStationRoutes200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosStationRoutes200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
