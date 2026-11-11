// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_route_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract class StationRouteInputBuilder {
  void replace(StationRouteInput other);
  void update(void Function(StationRouteInputBuilder) updates);
  String? get kitchenStationId;
  set kitchenStationId(String? kitchenStationId);

  String? get productId;
  set productId(String? productId);

  String? get kitchenCategory;
  set kitchenCategory(String? kitchenCategory);

  String? get serviceMode;
  set serviceMode(String? serviceMode);
}

class _$$StationRouteInput extends $StationRouteInput {
  @override
  final String? kitchenStationId;
  @override
  final String? productId;
  @override
  final String? kitchenCategory;
  @override
  final String? serviceMode;

  factory _$$StationRouteInput(
          [void Function($StationRouteInputBuilder)? updates]) =>
      ($StationRouteInputBuilder()..update(updates))._build();

  _$$StationRouteInput._(
      {this.kitchenStationId,
      this.productId,
      this.kitchenCategory,
      this.serviceMode})
      : super._();
  @override
  $StationRouteInput rebuild(
          void Function($StationRouteInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $StationRouteInputBuilder toBuilder() =>
      $StationRouteInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $StationRouteInput &&
        kitchenStationId == other.kitchenStationId &&
        productId == other.productId &&
        kitchenCategory == other.kitchenCategory &&
        serviceMode == other.serviceMode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kitchenStationId.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, kitchenCategory.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$StationRouteInput')
          ..add('kitchenStationId', kitchenStationId)
          ..add('productId', productId)
          ..add('kitchenCategory', kitchenCategory)
          ..add('serviceMode', serviceMode))
        .toString();
  }
}

class $StationRouteInputBuilder
    implements
        Builder<$StationRouteInput, $StationRouteInputBuilder>,
        StationRouteInputBuilder {
  _$$StationRouteInput? _$v;

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

  $StationRouteInputBuilder() {
    $StationRouteInput._defaults(this);
  }

  $StationRouteInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kitchenStationId = $v.kitchenStationId;
      _productId = $v.productId;
      _kitchenCategory = $v.kitchenCategory;
      _serviceMode = $v.serviceMode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $StationRouteInput other) {
    _$v = other as _$$StationRouteInput;
  }

  @override
  void update(void Function($StationRouteInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $StationRouteInput build() => _build();

  _$$StationRouteInput _build() {
    final _$result = _$v ??
        _$$StationRouteInput._(
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
