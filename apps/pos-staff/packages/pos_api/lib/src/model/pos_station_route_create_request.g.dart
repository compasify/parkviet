// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_station_route_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosStationRouteCreateRequest extends PosStationRouteCreateRequest {
  @override
  final String branchId;
  @override
  final String? kitchenStationId;
  @override
  final String? productId;
  @override
  final String? kitchenCategory;
  @override
  final String? serviceMode;

  factory _$PosStationRouteCreateRequest(
          [void Function(PosStationRouteCreateRequestBuilder)? updates]) =>
      (PosStationRouteCreateRequestBuilder()..update(updates))._build();

  _$PosStationRouteCreateRequest._(
      {required this.branchId,
      this.kitchenStationId,
      this.productId,
      this.kitchenCategory,
      this.serviceMode})
      : super._();
  @override
  PosStationRouteCreateRequest rebuild(
          void Function(PosStationRouteCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosStationRouteCreateRequestBuilder toBuilder() =>
      PosStationRouteCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosStationRouteCreateRequest &&
        branchId == other.branchId &&
        kitchenStationId == other.kitchenStationId &&
        productId == other.productId &&
        kitchenCategory == other.kitchenCategory &&
        serviceMode == other.serviceMode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, kitchenStationId.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, kitchenCategory.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosStationRouteCreateRequest')
          ..add('branchId', branchId)
          ..add('kitchenStationId', kitchenStationId)
          ..add('productId', productId)
          ..add('kitchenCategory', kitchenCategory)
          ..add('serviceMode', serviceMode))
        .toString();
  }
}

class PosStationRouteCreateRequestBuilder
    implements
        Builder<PosStationRouteCreateRequest,
            PosStationRouteCreateRequestBuilder>,
        StationRouteInputBuilder {
  _$PosStationRouteCreateRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(covariant String? branchId) => _$this._branchId = branchId;

  String? _kitchenStationId;
  String? get kitchenStationId => _$this._kitchenStationId;
  set kitchenStationId(covariant String? kitchenStationId) =>
      _$this._kitchenStationId = kitchenStationId;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(covariant String? productId) => _$this._productId = productId;

  String? _kitchenCategory;
  String? get kitchenCategory => _$this._kitchenCategory;
  set kitchenCategory(covariant String? kitchenCategory) =>
      _$this._kitchenCategory = kitchenCategory;

  String? _serviceMode;
  String? get serviceMode => _$this._serviceMode;
  set serviceMode(covariant String? serviceMode) =>
      _$this._serviceMode = serviceMode;

  PosStationRouteCreateRequestBuilder() {
    PosStationRouteCreateRequest._defaults(this);
  }

  PosStationRouteCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _kitchenStationId = $v.kitchenStationId;
      _productId = $v.productId;
      _kitchenCategory = $v.kitchenCategory;
      _serviceMode = $v.serviceMode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant PosStationRouteCreateRequest other) {
    _$v = other as _$PosStationRouteCreateRequest;
  }

  @override
  void update(void Function(PosStationRouteCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosStationRouteCreateRequest build() => _build();

  _$PosStationRouteCreateRequest _build() {
    final _$result = _$v ??
        _$PosStationRouteCreateRequest._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'PosStationRouteCreateRequest', 'branchId'),
          kitchenStationId: kitchenStationId,
          productId: productId,
          kitchenCategory: kitchenCategory,
          serviceMode: serviceMode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
