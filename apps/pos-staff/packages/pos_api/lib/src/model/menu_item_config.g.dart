// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MenuItemConfigKindEnum _$menuItemConfigKindEnum_single =
    const MenuItemConfigKindEnum._('single');
const MenuItemConfigKindEnum _$menuItemConfigKindEnum_combo =
    const MenuItemConfigKindEnum._('combo');

MenuItemConfigKindEnum _$menuItemConfigKindEnumValueOf(String name) {
  switch (name) {
    case 'single':
      return _$menuItemConfigKindEnum_single;
    case 'combo':
      return _$menuItemConfigKindEnum_combo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MenuItemConfigKindEnum> _$menuItemConfigKindEnumValues =
    BuiltSet<MenuItemConfigKindEnum>(const <MenuItemConfigKindEnum>[
  _$menuItemConfigKindEnum_single,
  _$menuItemConfigKindEnum_combo,
]);

Serializer<MenuItemConfigKindEnum> _$menuItemConfigKindEnumSerializer =
    _$MenuItemConfigKindEnumSerializer();

class _$MenuItemConfigKindEnumSerializer
    implements PrimitiveSerializer<MenuItemConfigKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'single': 'single',
    'combo': 'combo',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'single': 'single',
    'combo': 'combo',
  };

  @override
  final Iterable<Type> types = const <Type>[MenuItemConfigKindEnum];
  @override
  final String wireName = 'MenuItemConfigKindEnum';

  @override
  Object serialize(Serializers serializers, MenuItemConfigKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MenuItemConfigKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MenuItemConfigKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

abstract class MenuItemConfigBuilder {
  void replace(MenuItemConfig other);
  void update(void Function(MenuItemConfigBuilder) updates);
  String? get id;
  set id(String? id);

  String? get productId;
  set productId(String? productId);

  String? get name;
  set name(String? name);

  MenuItemConfigKindEnum? get kind;
  set kind(MenuItemConfigKindEnum? kind);

  String? get menuCategoryId;
  set menuCategoryId(String? menuCategoryId);

  String? get kitchenCategory;
  set kitchenCategory(String? kitchenCategory);

  bool? get cupLabel;
  set cupLabel(bool? cupLabel);

  bool? get showComponentsOnKds;
  set showComponentsOnKds(bool? showComponentsOnKds);

  int? get position;
  set position(int? position);

  bool? get active;
  set active(bool? active);

  bool? get qrOrderable;
  set qrOrderable(bool? qrOrderable);

  String? get taxCategoryId;
  set taxCategoryId(String? taxCategoryId);

  ListBuilder<String> get modifierGroupIds;
  set modifierGroupIds(ListBuilder<String>? modifierGroupIds);

  ListBuilder<MenuItemConfigComponentsInner> get components;
  set components(ListBuilder<MenuItemConfigComponentsInner>? components);
}

class _$$MenuItemConfig extends $MenuItemConfig {
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

  factory _$$MenuItemConfig([void Function($MenuItemConfigBuilder)? updates]) =>
      ($MenuItemConfigBuilder()..update(updates))._build();

  _$$MenuItemConfig._(
      {required this.id,
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
  $MenuItemConfig rebuild(void Function($MenuItemConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $MenuItemConfigBuilder toBuilder() => $MenuItemConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $MenuItemConfig &&
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
    return (newBuiltValueToStringHelper(r'$MenuItemConfig')
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

class $MenuItemConfigBuilder
    implements
        Builder<$MenuItemConfig, $MenuItemConfigBuilder>,
        MenuItemConfigBuilder {
  _$$MenuItemConfig? _$v;

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

  $MenuItemConfigBuilder() {
    $MenuItemConfig._defaults(this);
  }

  $MenuItemConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(covariant $MenuItemConfig other) {
    _$v = other as _$$MenuItemConfig;
  }

  @override
  void update(void Function($MenuItemConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $MenuItemConfig build() => _build();

  _$$MenuItemConfig _build() {
    _$$MenuItemConfig _$result;
    try {
      _$result = _$v ??
          _$$MenuItemConfig._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'$MenuItemConfig', 'id'),
            productId: BuiltValueNullFieldError.checkNotNull(
                productId, r'$MenuItemConfig', 'productId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'$MenuItemConfig', 'name'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'$MenuItemConfig', 'kind'),
            menuCategoryId: menuCategoryId,
            kitchenCategory: kitchenCategory,
            cupLabel: BuiltValueNullFieldError.checkNotNull(
                cupLabel, r'$MenuItemConfig', 'cupLabel'),
            showComponentsOnKds: BuiltValueNullFieldError.checkNotNull(
                showComponentsOnKds, r'$MenuItemConfig', 'showComponentsOnKds'),
            position: BuiltValueNullFieldError.checkNotNull(
                position, r'$MenuItemConfig', 'position'),
            active: BuiltValueNullFieldError.checkNotNull(
                active, r'$MenuItemConfig', 'active'),
            qrOrderable: qrOrderable,
            taxCategoryId: taxCategoryId,
            modifierGroupIds: modifierGroupIds.build(),
            components: components.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifierGroupIds';
        modifierGroupIds.build();
        _$failedField = 'components';
        components.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'$MenuItemConfig', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
