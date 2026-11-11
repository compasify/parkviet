// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_route.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StationRoute extends StationRoute {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String kitchenStationId;
  @override
  final String? productId;
  @override
  final String? productName;
  @override
  final String? kitchenCategory;
  @override
  final String? serviceMode;

  factory _$StationRoute([void Function(StationRouteBuilder)? updates]) =>
      (StationRouteBuilder()..update(updates))._build();

  _$StationRoute._(
      {required this.id,
      required this.branchId,
      required this.kitchenStationId,
      this.productId,
      this.productName,
      this.kitchenCategory,
      this.serviceMode})
      : super._();
  @override
  StationRoute rebuild(void Function(StationRouteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StationRouteBuilder toBuilder() => StationRouteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StationRoute &&
        id == other.id &&
        branchId == other.branchId &&
        kitchenStationId == other.kitchenStationId &&
        productId == other.productId &&
        productName == other.productName &&
        kitchenCategory == other.kitchenCategory &&
        serviceMode == other.serviceMode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, kitchenStationId.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, productName.hashCode);
    _$hash = $jc(_$hash, kitchenCategory.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StationRoute')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('kitchenStationId', kitchenStationId)
          ..add('productId', productId)
          ..add('productName', productName)
          ..add('kitchenCategory', kitchenCategory)
          ..add('serviceMode', serviceMode))
        .toString();
  }
}

class StationRouteBuilder
    implements Builder<StationRoute, StationRouteBuilder> {
  _$StationRoute? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _kitchenStationId;
  String? get kitchenStationId => _$this._kitchenStationId;
  set kitchenStationId(String? kitchenStationId) =>
      _$this._kitchenStationId = kitchenStationId;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _productName;
  String? get productName => _$this._productName;
  set productName(String? productName) => _$this._productName = productName;

  String? _kitchenCategory;
  String? get kitchenCategory => _$this._kitchenCategory;
  set kitchenCategory(String? kitchenCategory) =>
      _$this._kitchenCategory = kitchenCategory;

  String? _serviceMode;
  String? get serviceMode => _$this._serviceMode;
  set serviceMode(String? serviceMode) => _$this._serviceMode = serviceMode;

  StationRouteBuilder() {
    StationRoute._defaults(this);
  }

  StationRouteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _kitchenStationId = $v.kitchenStationId;
      _productId = $v.productId;
      _productName = $v.productName;
      _kitchenCategory = $v.kitchenCategory;
      _serviceMode = $v.serviceMode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StationRoute other) {
    _$v = other as _$StationRoute;
  }

  @override
  void update(void Function(StationRouteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StationRoute build() => _build();

  _$StationRoute _build() {
    final _$result = _$v ??
        _$StationRoute._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'StationRoute', 'id'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'StationRoute', 'branchId'),
          kitchenStationId: BuiltValueNullFieldError.checkNotNull(
              kitchenStationId, r'StationRoute', 'kitchenStationId'),
          productId: productId,
          productName: productName,
          kitchenCategory: kitchenCategory,
          serviceMode: serviceMode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
