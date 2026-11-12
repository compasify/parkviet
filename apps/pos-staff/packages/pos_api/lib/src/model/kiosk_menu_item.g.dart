// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_menu_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KioskMenuItemKindEnum _$kioskMenuItemKindEnum_single =
    const KioskMenuItemKindEnum._('single');
const KioskMenuItemKindEnum _$kioskMenuItemKindEnum_combo =
    const KioskMenuItemKindEnum._('combo');

KioskMenuItemKindEnum _$kioskMenuItemKindEnumValueOf(String name) {
  switch (name) {
    case 'single':
      return _$kioskMenuItemKindEnum_single;
    case 'combo':
      return _$kioskMenuItemKindEnum_combo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KioskMenuItemKindEnum> _$kioskMenuItemKindEnumValues =
    BuiltSet<KioskMenuItemKindEnum>(const <KioskMenuItemKindEnum>[
  _$kioskMenuItemKindEnum_single,
  _$kioskMenuItemKindEnum_combo,
]);

Serializer<KioskMenuItemKindEnum> _$kioskMenuItemKindEnumSerializer =
    _$KioskMenuItemKindEnumSerializer();

class _$KioskMenuItemKindEnumSerializer
    implements PrimitiveSerializer<KioskMenuItemKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'single': 'single',
    'combo': 'combo',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'single': 'single',
    'combo': 'combo',
  };

  @override
  final Iterable<Type> types = const <Type>[KioskMenuItemKindEnum];
  @override
  final String wireName = 'KioskMenuItemKindEnum';

  @override
  Object serialize(Serializers serializers, KioskMenuItemKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KioskMenuItemKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KioskMenuItemKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KioskMenuItem extends KioskMenuItem {
  @override
  final String id;
  @override
  final String name;
  @override
  final KioskMenuItemKindEnum kind;
  @override
  final String? menuCategoryId;
  @override
  final int position;
  @override
  final String? imageUrl;
  @override
  final bool soldOut;
  @override
  final BuiltList<String> modifierGroupIds;
  @override
  final BuiltList<KioskMenuComponent> components;
  @override
  final BuiltList<KioskMenuVariant> variants;

  factory _$KioskMenuItem([void Function(KioskMenuItemBuilder)? updates]) =>
      (KioskMenuItemBuilder()..update(updates))._build();

  _$KioskMenuItem._(
      {required this.id,
      required this.name,
      required this.kind,
      this.menuCategoryId,
      required this.position,
      this.imageUrl,
      required this.soldOut,
      required this.modifierGroupIds,
      required this.components,
      required this.variants})
      : super._();
  @override
  KioskMenuItem rebuild(void Function(KioskMenuItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskMenuItemBuilder toBuilder() => KioskMenuItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskMenuItem &&
        id == other.id &&
        name == other.name &&
        kind == other.kind &&
        menuCategoryId == other.menuCategoryId &&
        position == other.position &&
        imageUrl == other.imageUrl &&
        soldOut == other.soldOut &&
        modifierGroupIds == other.modifierGroupIds &&
        components == other.components &&
        variants == other.variants;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, menuCategoryId.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, soldOut.hashCode);
    _$hash = $jc(_$hash, modifierGroupIds.hashCode);
    _$hash = $jc(_$hash, components.hashCode);
    _$hash = $jc(_$hash, variants.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskMenuItem')
          ..add('id', id)
          ..add('name', name)
          ..add('kind', kind)
          ..add('menuCategoryId', menuCategoryId)
          ..add('position', position)
          ..add('imageUrl', imageUrl)
          ..add('soldOut', soldOut)
          ..add('modifierGroupIds', modifierGroupIds)
          ..add('components', components)
          ..add('variants', variants))
        .toString();
  }
}

class KioskMenuItemBuilder
    implements Builder<KioskMenuItem, KioskMenuItemBuilder> {
  _$KioskMenuItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  KioskMenuItemKindEnum? _kind;
  KioskMenuItemKindEnum? get kind => _$this._kind;
  set kind(KioskMenuItemKindEnum? kind) => _$this._kind = kind;

  String? _menuCategoryId;
  String? get menuCategoryId => _$this._menuCategoryId;
  set menuCategoryId(String? menuCategoryId) =>
      _$this._menuCategoryId = menuCategoryId;

  int? _position;
  int? get position => _$this._position;
  set position(int? position) => _$this._position = position;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  bool? _soldOut;
  bool? get soldOut => _$this._soldOut;
  set soldOut(bool? soldOut) => _$this._soldOut = soldOut;

  ListBuilder<String>? _modifierGroupIds;
  ListBuilder<String> get modifierGroupIds =>
      _$this._modifierGroupIds ??= ListBuilder<String>();
  set modifierGroupIds(ListBuilder<String>? modifierGroupIds) =>
      _$this._modifierGroupIds = modifierGroupIds;

  ListBuilder<KioskMenuComponent>? _components;
  ListBuilder<KioskMenuComponent> get components =>
      _$this._components ??= ListBuilder<KioskMenuComponent>();
  set components(ListBuilder<KioskMenuComponent>? components) =>
      _$this._components = components;

  ListBuilder<KioskMenuVariant>? _variants;
  ListBuilder<KioskMenuVariant> get variants =>
      _$this._variants ??= ListBuilder<KioskMenuVariant>();
  set variants(ListBuilder<KioskMenuVariant>? variants) =>
      _$this._variants = variants;

  KioskMenuItemBuilder() {
    KioskMenuItem._defaults(this);
  }

  KioskMenuItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _kind = $v.kind;
      _menuCategoryId = $v.menuCategoryId;
      _position = $v.position;
      _imageUrl = $v.imageUrl;
      _soldOut = $v.soldOut;
      _modifierGroupIds = $v.modifierGroupIds.toBuilder();
      _components = $v.components.toBuilder();
      _variants = $v.variants.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskMenuItem other) {
    _$v = other as _$KioskMenuItem;
  }

  @override
  void update(void Function(KioskMenuItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskMenuItem build() => _build();

  _$KioskMenuItem _build() {
    _$KioskMenuItem _$result;
    try {
      _$result = _$v ??
          _$KioskMenuItem._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'KioskMenuItem', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'KioskMenuItem', 'name'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'KioskMenuItem', 'kind'),
            menuCategoryId: menuCategoryId,
            position: BuiltValueNullFieldError.checkNotNull(
                position, r'KioskMenuItem', 'position'),
            imageUrl: imageUrl,
            soldOut: BuiltValueNullFieldError.checkNotNull(
                soldOut, r'KioskMenuItem', 'soldOut'),
            modifierGroupIds: modifierGroupIds.build(),
            components: components.build(),
            variants: variants.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifierGroupIds';
        modifierGroupIds.build();
        _$failedField = 'components';
        components.build();
        _$failedField = 'variants';
        variants.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskMenuItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
