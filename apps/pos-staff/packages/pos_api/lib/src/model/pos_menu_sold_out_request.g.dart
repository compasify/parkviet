// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_menu_sold_out_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosMenuSoldOutRequest extends PosMenuSoldOutRequest {
  @override
  final String branchId;
  @override
  final String menuItemId;
  @override
  final bool soldOut;

  factory _$PosMenuSoldOutRequest(
          [void Function(PosMenuSoldOutRequestBuilder)? updates]) =>
      (PosMenuSoldOutRequestBuilder()..update(updates))._build();

  _$PosMenuSoldOutRequest._(
      {required this.branchId, required this.menuItemId, required this.soldOut})
      : super._();
  @override
  PosMenuSoldOutRequest rebuild(
          void Function(PosMenuSoldOutRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosMenuSoldOutRequestBuilder toBuilder() =>
      PosMenuSoldOutRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosMenuSoldOutRequest &&
        branchId == other.branchId &&
        menuItemId == other.menuItemId &&
        soldOut == other.soldOut;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, menuItemId.hashCode);
    _$hash = $jc(_$hash, soldOut.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosMenuSoldOutRequest')
          ..add('branchId', branchId)
          ..add('menuItemId', menuItemId)
          ..add('soldOut', soldOut))
        .toString();
  }
}

class PosMenuSoldOutRequestBuilder
    implements Builder<PosMenuSoldOutRequest, PosMenuSoldOutRequestBuilder> {
  _$PosMenuSoldOutRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _menuItemId;
  String? get menuItemId => _$this._menuItemId;
  set menuItemId(String? menuItemId) => _$this._menuItemId = menuItemId;

  bool? _soldOut;
  bool? get soldOut => _$this._soldOut;
  set soldOut(bool? soldOut) => _$this._soldOut = soldOut;

  PosMenuSoldOutRequestBuilder() {
    PosMenuSoldOutRequest._defaults(this);
  }

  PosMenuSoldOutRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _menuItemId = $v.menuItemId;
      _soldOut = $v.soldOut;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosMenuSoldOutRequest other) {
    _$v = other as _$PosMenuSoldOutRequest;
  }

  @override
  void update(void Function(PosMenuSoldOutRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosMenuSoldOutRequest build() => _build();

  _$PosMenuSoldOutRequest _build() {
    final _$result = _$v ??
        _$PosMenuSoldOutRequest._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'PosMenuSoldOutRequest', 'branchId'),
          menuItemId: BuiltValueNullFieldError.checkNotNull(
              menuItemId, r'PosMenuSoldOutRequest', 'menuItemId'),
          soldOut: BuiltValueNullFieldError.checkNotNull(
              soldOut, r'PosMenuSoldOutRequest', 'soldOut'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
