// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_kitchen_select_station_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosDeviceKitchenSelectStationRequest
    extends PosDeviceKitchenSelectStationRequest {
  @override
  final String? stationId;

  factory _$PosDeviceKitchenSelectStationRequest(
          [void Function(PosDeviceKitchenSelectStationRequestBuilder)?
              updates]) =>
      (PosDeviceKitchenSelectStationRequestBuilder()..update(updates))._build();

  _$PosDeviceKitchenSelectStationRequest._({this.stationId}) : super._();
  @override
  PosDeviceKitchenSelectStationRequest rebuild(
          void Function(PosDeviceKitchenSelectStationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDeviceKitchenSelectStationRequestBuilder toBuilder() =>
      PosDeviceKitchenSelectStationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDeviceKitchenSelectStationRequest &&
        stationId == other.stationId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stationId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosDeviceKitchenSelectStationRequest')
          ..add('stationId', stationId))
        .toString();
  }
}

class PosDeviceKitchenSelectStationRequestBuilder
    implements
        Builder<PosDeviceKitchenSelectStationRequest,
            PosDeviceKitchenSelectStationRequestBuilder> {
  _$PosDeviceKitchenSelectStationRequest? _$v;

  String? _stationId;
  String? get stationId => _$this._stationId;
  set stationId(String? stationId) => _$this._stationId = stationId;

  PosDeviceKitchenSelectStationRequestBuilder() {
    PosDeviceKitchenSelectStationRequest._defaults(this);
  }

  PosDeviceKitchenSelectStationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stationId = $v.stationId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDeviceKitchenSelectStationRequest other) {
    _$v = other as _$PosDeviceKitchenSelectStationRequest;
  }

  @override
  void update(
      void Function(PosDeviceKitchenSelectStationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDeviceKitchenSelectStationRequest build() => _build();

  _$PosDeviceKitchenSelectStationRequest _build() {
    final _$result = _$v ??
        _$PosDeviceKitchenSelectStationRequest._(
          stationId: stationId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
