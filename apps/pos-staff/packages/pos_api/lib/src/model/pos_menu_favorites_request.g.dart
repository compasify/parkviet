// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_menu_favorites_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosMenuFavoritesRequest extends PosMenuFavoritesRequest {
  @override
  final String branchId;
  @override
  final BuiltList<String> menuItemIds;

  factory _$PosMenuFavoritesRequest(
          [void Function(PosMenuFavoritesRequestBuilder)? updates]) =>
      (PosMenuFavoritesRequestBuilder()..update(updates))._build();

  _$PosMenuFavoritesRequest._(
      {required this.branchId, required this.menuItemIds})
      : super._();
  @override
  PosMenuFavoritesRequest rebuild(
          void Function(PosMenuFavoritesRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosMenuFavoritesRequestBuilder toBuilder() =>
      PosMenuFavoritesRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosMenuFavoritesRequest &&
        branchId == other.branchId &&
        menuItemIds == other.menuItemIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, menuItemIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosMenuFavoritesRequest')
          ..add('branchId', branchId)
          ..add('menuItemIds', menuItemIds))
        .toString();
  }
}

class PosMenuFavoritesRequestBuilder
    implements
        Builder<PosMenuFavoritesRequest, PosMenuFavoritesRequestBuilder> {
  _$PosMenuFavoritesRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  ListBuilder<String>? _menuItemIds;
  ListBuilder<String> get menuItemIds =>
      _$this._menuItemIds ??= ListBuilder<String>();
  set menuItemIds(ListBuilder<String>? menuItemIds) =>
      _$this._menuItemIds = menuItemIds;

  PosMenuFavoritesRequestBuilder() {
    PosMenuFavoritesRequest._defaults(this);
  }

  PosMenuFavoritesRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _menuItemIds = $v.menuItemIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosMenuFavoritesRequest other) {
    _$v = other as _$PosMenuFavoritesRequest;
  }

  @override
  void update(void Function(PosMenuFavoritesRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosMenuFavoritesRequest build() => _build();

  _$PosMenuFavoritesRequest _build() {
    _$PosMenuFavoritesRequest _$result;
    try {
      _$result = _$v ??
          _$PosMenuFavoritesRequest._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'PosMenuFavoritesRequest', 'branchId'),
            menuItemIds: menuItemIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'menuItemIds';
        menuItemIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosMenuFavoritesRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
