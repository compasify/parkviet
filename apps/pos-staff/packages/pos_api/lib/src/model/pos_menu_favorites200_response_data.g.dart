// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_menu_favorites200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosMenuFavorites200ResponseData
    extends PosMenuFavorites200ResponseData {
  @override
  final String branchId;
  @override
  final BuiltList<String> menuItemIds;

  factory _$PosMenuFavorites200ResponseData(
          [void Function(PosMenuFavorites200ResponseDataBuilder)? updates]) =>
      (PosMenuFavorites200ResponseDataBuilder()..update(updates))._build();

  _$PosMenuFavorites200ResponseData._(
      {required this.branchId, required this.menuItemIds})
      : super._();
  @override
  PosMenuFavorites200ResponseData rebuild(
          void Function(PosMenuFavorites200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosMenuFavorites200ResponseDataBuilder toBuilder() =>
      PosMenuFavorites200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosMenuFavorites200ResponseData &&
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
    return (newBuiltValueToStringHelper(r'PosMenuFavorites200ResponseData')
          ..add('branchId', branchId)
          ..add('menuItemIds', menuItemIds))
        .toString();
  }
}

class PosMenuFavorites200ResponseDataBuilder
    implements
        Builder<PosMenuFavorites200ResponseData,
            PosMenuFavorites200ResponseDataBuilder> {
  _$PosMenuFavorites200ResponseData? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  ListBuilder<String>? _menuItemIds;
  ListBuilder<String> get menuItemIds =>
      _$this._menuItemIds ??= ListBuilder<String>();
  set menuItemIds(ListBuilder<String>? menuItemIds) =>
      _$this._menuItemIds = menuItemIds;

  PosMenuFavorites200ResponseDataBuilder() {
    PosMenuFavorites200ResponseData._defaults(this);
  }

  PosMenuFavorites200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _menuItemIds = $v.menuItemIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosMenuFavorites200ResponseData other) {
    _$v = other as _$PosMenuFavorites200ResponseData;
  }

  @override
  void update(void Function(PosMenuFavorites200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosMenuFavorites200ResponseData build() => _build();

  _$PosMenuFavorites200ResponseData _build() {
    _$PosMenuFavorites200ResponseData _$result;
    try {
      _$result = _$v ??
          _$PosMenuFavorites200ResponseData._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'PosMenuFavorites200ResponseData', 'branchId'),
            menuItemIds: menuItemIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'menuItemIds';
        menuItemIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosMenuFavorites200ResponseData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
