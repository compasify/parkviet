// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MenuItemKindEnum _$menuItemKindEnum_single =
    const MenuItemKindEnum._('single');
const MenuItemKindEnum _$menuItemKindEnum_combo =
    const MenuItemKindEnum._('combo');

MenuItemKindEnum _$menuItemKindEnumValueOf(String name) {
  switch (name) {
    case 'single':
      return _$menuItemKindEnum_single;
    case 'combo':
      return _$menuItemKindEnum_combo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MenuItemKindEnum> _$menuItemKindEnumValues =
    BuiltSet<MenuItemKindEnum>(const <MenuItemKindEnum>[
  _$menuItemKindEnum_single,
  _$menuItemKindEnum_combo,
]);

Serializer<MenuItemKindEnum> _$menuItemKindEnumSerializer =
    _$MenuItemKindEnumSerializer();

class _$MenuItemKindEnumSerializer
    implements PrimitiveSerializer<MenuItemKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'single': 'single',
    'combo': 'combo',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'single': 'single',
    'combo': 'combo',
  };

  @override
  final Iterable<Type> types = const <Type>[MenuItemKindEnum];
  @override
  final String wireName = 'MenuItemKindEnum';

  @override
  Object serialize(Serializers serializers, MenuItemKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MenuItemKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MenuItemKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MenuItem extends MenuItem {
  @override
  final String? imageUrl;
  @override
  final BuiltList<MenuItemAllOfVariants> variants;
  @override
  final bool soldOut;
  @override
  final String id;
  @override
  final String productId;
  @override
  final String name;
  @override
  final MenuItemConfigKindEnum kind;
  @override
  final String? menuCategoryId;
  @override
  final String? kitchenCategory;
  @override
  final bool cupLabel;
  @override
  final bool showComponentsOnKds;
  @override
  final int position;
  @override
  final bool active;
  @override
  final bool? qrOrderable;
  @override
  final String? taxCategoryId;
  @override
  final BuiltList<String> modifierGroupIds;
  @override
  final BuiltList<MenuItemConfigComponentsInner> components;

  factory _$MenuItem([void Function(MenuItemBuilder)? updates]) =>
      (MenuItemBuilder()..update(updates))._build();

  _$MenuItem._(
      {this.imageUrl,
      required this.variants,
      required this.soldOut,
      required this.id,
      required this.productId,
      required this.name,
      required this.kind,
      this.menuCategoryId,
      this.kitchenCategory,
      required this.cupLabel,
      required this.showComponentsOnKds,
      required this.position,
      required this.active,
      this.qrOrderable,
      this.taxCategoryId,
      required this.modifierGroupIds,
      required this.components})
      : super._();
  @override
  MenuItem rebuild(void Function(MenuItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MenuItemBuilder toBuilder() => MenuItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MenuItem &&
        imageUrl == other.imageUrl &&
        variants == other.variants &&
        soldOut == other.soldOut &&
        id == other.id &&
        productId == other.productId &&
        name == other.name &&
        kind == other.kind &&
        menuCategoryId == other.menuCategoryId &&
        kitchenCategory == other.kitchenCategory &&
        cupLabel == other.cupLabel &&
        showComponentsOnKds == other.showComponentsOnKds &&
        position == other.position &&
        active == other.active &&
        qrOrderable == other.qrOrderable &&
        taxCategoryId == other.taxCategoryId &&
        modifierGroupIds == other.modifierGroupIds &&
        components == other.components;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, variants.hashCode);
    _$hash = $jc(_$hash, soldOut.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, menuCategoryId.hashCode);
    _$hash = $jc(_$hash, kitchenCategory.hashCode);
    _$hash = $jc(_$hash, cupLabel.hashCode);
    _$hash = $jc(_$hash, showComponentsOnKds.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, qrOrderable.hashCode);
    _$hash = $jc(_$hash, taxCategoryId.hashCode);
    _$hash = $jc(_$hash, modifierGroupIds.hashCode);
    _$hash = $jc(_$hash, components.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MenuItem')
          ..add('imageUrl', imageUrl)
          ..add('variants', variants)
          ..add('soldOut', soldOut)
          ..add('id', id)
          ..add('productId', productId)
          ..add('name', name)
          ..add('kind', kind)
          ..add('menuCategoryId', menuCategoryId)
          ..add('kitchenCategory', kitchenCategory)
          ..add('cupLabel', cupLabel)
          ..add('showComponentsOnKds', showComponentsOnKds)
          ..add('position', position)
          ..add('active', active)
          ..add('qrOrderable', qrOrderable)
          ..add('taxCategoryId', taxCategoryId)
          ..add('modifierGroupIds', modifierGroupIds)
          ..add('components', components))
        .toString();
  }
}

class MenuItemBuilder
    implements Builder<MenuItem, MenuItemBuilder>, MenuItemConfigBuilder {
  _$MenuItem? _$v;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(covariant String? imageUrl) => _$this._imageUrl = imageUrl;

  ListBuilder<MenuItemAllOfVariants>? _variants;
  ListBuilder<MenuItemAllOfVariants> get variants =>
      _$this._variants ??= ListBuilder<MenuItemAllOfVariants>();
  set variants(covariant ListBuilder<MenuItemAllOfVariants>? variants) =>
      _$this._variants = variants;

  bool? _soldOut;
  bool? get soldOut => _$this._soldOut;
  set soldOut(covariant bool? soldOut) => _$this._soldOut = soldOut;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(covariant String? productId) => _$this._productId = productId;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  MenuItemConfigKindEnum? _kind;
  MenuItemConfigKindEnum? get kind => _$this._kind;
  set kind(covariant MenuItemConfigKindEnum? kind) => _$this._kind = kind;

  String? _menuCategoryId;
  String? get menuCategoryId => _$this._menuCategoryId;
  set menuCategoryId(covariant String? menuCategoryId) =>
      _$this._menuCategoryId = menuCategoryId;

  String? _kitchenCategory;
  String? get kitchenCategory => _$this._kitchenCategory;
  set kitchenCategory(covariant String? kitchenCategory) =>
      _$this._kitchenCategory = kitchenCategory;

  bool? _cupLabel;
  bool? get cupLabel => _$this._cupLabel;
  set cupLabel(covariant bool? cupLabel) => _$this._cupLabel = cupLabel;

  bool? _showComponentsOnKds;
  bool? get showComponentsOnKds => _$this._showComponentsOnKds;
  set showComponentsOnKds(covariant bool? showComponentsOnKds) =>
      _$this._showComponentsOnKds = showComponentsOnKds;

  int? _position;
  int? get position => _$this._position;
  set position(covariant int? position) => _$this._position = position;

  bool? _active;
  bool? get active => _$this._active;
  set active(covariant bool? active) => _$this._active = active;

  bool? _qrOrderable;
  bool? get qrOrderable => _$this._qrOrderable;
  set qrOrderable(covariant bool? qrOrderable) =>
      _$this._qrOrderable = qrOrderable;

  String? _taxCategoryId;
  String? get taxCategoryId => _$this._taxCategoryId;
  set taxCategoryId(covariant String? taxCategoryId) =>
      _$this._taxCategoryId = taxCategoryId;

  ListBuilder<String>? _modifierGroupIds;
  ListBuilder<String> get modifierGroupIds =>
      _$this._modifierGroupIds ??= ListBuilder<String>();
  set modifierGroupIds(covariant ListBuilder<String>? modifierGroupIds) =>
      _$this._modifierGroupIds = modifierGroupIds;

  ListBuilder<MenuItemConfigComponentsInner>? _components;
  ListBuilder<MenuItemConfigComponentsInner> get components =>
      _$this._components ??= ListBuilder<MenuItemConfigComponentsInner>();
  set components(
          covariant ListBuilder<MenuItemConfigComponentsInner>? components) =>
      _$this._components = components;

  MenuItemBuilder() {
    MenuItem._defaults(this);
  }

  MenuItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _imageUrl = $v.imageUrl;
      _variants = $v.variants.toBuilder();
      _soldOut = $v.soldOut;
      _id = $v.id;
      _productId = $v.productId;
      _name = $v.name;
      _kind = $v.kind;
      _menuCategoryId = $v.menuCategoryId;
      _kitchenCategory = $v.kitchenCategory;
      _cupLabel = $v.cupLabel;
      _showComponentsOnKds = $v.showComponentsOnKds;
      _position = $v.position;
      _active = $v.active;
      _qrOrderable = $v.qrOrderable;
      _taxCategoryId = $v.taxCategoryId;
      _modifierGroupIds = $v.modifierGroupIds.toBuilder();
      _components = $v.components.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant MenuItem other) {
    _$v = other as _$MenuItem;
  }

  @override
  void update(void Function(MenuItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MenuItem build() => _build();

  _$MenuItem _build() {
    _$MenuItem _$result;
    try {
      _$result = _$v ??
          _$MenuItem._(
            imageUrl: imageUrl,
            variants: variants.build(),
            soldOut: BuiltValueNullFieldError.checkNotNull(
                soldOut, r'MenuItem', 'soldOut'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'MenuItem', 'id'),
            productId: BuiltValueNullFieldError.checkNotNull(
                productId, r'MenuItem', 'productId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'MenuItem', 'name'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'MenuItem', 'kind'),
            menuCategoryId: menuCategoryId,
            kitchenCategory: kitchenCategory,
            cupLabel: BuiltValueNullFieldError.checkNotNull(
                cupLabel, r'MenuItem', 'cupLabel'),
            showComponentsOnKds: BuiltValueNullFieldError.checkNotNull(
                showComponentsOnKds, r'MenuItem', 'showComponentsOnKds'),
            position: BuiltValueNullFieldError.checkNotNull(
                position, r'MenuItem', 'position'),
            active: BuiltValueNullFieldError.checkNotNull(
                active, r'MenuItem', 'active'),
            qrOrderable: qrOrderable,
            taxCategoryId: taxCategoryId,
            modifierGroupIds: modifierGroupIds.build(),
            components: components.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'variants';
        variants.build();

        _$failedField = 'modifierGroupIds';
        modifierGroupIds.build();
        _$failedField = 'components';
        components.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MenuItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
