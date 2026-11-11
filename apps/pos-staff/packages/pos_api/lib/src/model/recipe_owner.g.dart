// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_owner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RecipeOwnerOwnerTypeEnum _$recipeOwnerOwnerTypeEnum_variant =
    const RecipeOwnerOwnerTypeEnum._('variant');
const RecipeOwnerOwnerTypeEnum _$recipeOwnerOwnerTypeEnum_modifierOption =
    const RecipeOwnerOwnerTypeEnum._('modifierOption');

RecipeOwnerOwnerTypeEnum _$recipeOwnerOwnerTypeEnumValueOf(String name) {
  switch (name) {
    case 'variant':
      return _$recipeOwnerOwnerTypeEnum_variant;
    case 'modifierOption':
      return _$recipeOwnerOwnerTypeEnum_modifierOption;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RecipeOwnerOwnerTypeEnum> _$recipeOwnerOwnerTypeEnumValues =
    BuiltSet<RecipeOwnerOwnerTypeEnum>(const <RecipeOwnerOwnerTypeEnum>[
  _$recipeOwnerOwnerTypeEnum_variant,
  _$recipeOwnerOwnerTypeEnum_modifierOption,
]);

Serializer<RecipeOwnerOwnerTypeEnum> _$recipeOwnerOwnerTypeEnumSerializer =
    _$RecipeOwnerOwnerTypeEnumSerializer();

class _$RecipeOwnerOwnerTypeEnumSerializer
    implements PrimitiveSerializer<RecipeOwnerOwnerTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'variant': 'variant',
    'modifierOption': 'modifier_option',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'variant': 'variant',
    'modifier_option': 'modifierOption',
  };

  @override
  final Iterable<Type> types = const <Type>[RecipeOwnerOwnerTypeEnum];
  @override
  final String wireName = 'RecipeOwnerOwnerTypeEnum';

  @override
  Object serialize(Serializers serializers, RecipeOwnerOwnerTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RecipeOwnerOwnerTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RecipeOwnerOwnerTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RecipeOwner extends RecipeOwner {
  @override
  final RecipeOwnerOwnerTypeEnum ownerType;
  @override
  final String ownerId;
  @override
  final bool? trackInventory;
  @override
  final Recipe? active;
  @override
  final BuiltList<RecipeOwnerVersionsInner> versions;

  factory _$RecipeOwner([void Function(RecipeOwnerBuilder)? updates]) =>
      (RecipeOwnerBuilder()..update(updates))._build();

  _$RecipeOwner._(
      {required this.ownerType,
      required this.ownerId,
      this.trackInventory,
      this.active,
      required this.versions})
      : super._();
  @override
  RecipeOwner rebuild(void Function(RecipeOwnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecipeOwnerBuilder toBuilder() => RecipeOwnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecipeOwner &&
        ownerType == other.ownerType &&
        ownerId == other.ownerId &&
        trackInventory == other.trackInventory &&
        active == other.active &&
        versions == other.versions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ownerType.hashCode);
    _$hash = $jc(_$hash, ownerId.hashCode);
    _$hash = $jc(_$hash, trackInventory.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, versions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecipeOwner')
          ..add('ownerType', ownerType)
          ..add('ownerId', ownerId)
          ..add('trackInventory', trackInventory)
          ..add('active', active)
          ..add('versions', versions))
        .toString();
  }
}

class RecipeOwnerBuilder implements Builder<RecipeOwner, RecipeOwnerBuilder> {
  _$RecipeOwner? _$v;

  RecipeOwnerOwnerTypeEnum? _ownerType;
  RecipeOwnerOwnerTypeEnum? get ownerType => _$this._ownerType;
  set ownerType(RecipeOwnerOwnerTypeEnum? ownerType) =>
      _$this._ownerType = ownerType;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(String? ownerId) => _$this._ownerId = ownerId;

  bool? _trackInventory;
  bool? get trackInventory => _$this._trackInventory;
  set trackInventory(bool? trackInventory) =>
      _$this._trackInventory = trackInventory;

  RecipeBuilder? _active;
  RecipeBuilder get active => _$this._active ??= RecipeBuilder();
  set active(RecipeBuilder? active) => _$this._active = active;

  ListBuilder<RecipeOwnerVersionsInner>? _versions;
  ListBuilder<RecipeOwnerVersionsInner> get versions =>
      _$this._versions ??= ListBuilder<RecipeOwnerVersionsInner>();
  set versions(ListBuilder<RecipeOwnerVersionsInner>? versions) =>
      _$this._versions = versions;

  RecipeOwnerBuilder() {
    RecipeOwner._defaults(this);
  }

  RecipeOwnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ownerType = $v.ownerType;
      _ownerId = $v.ownerId;
      _trackInventory = $v.trackInventory;
      _active = $v.active?.toBuilder();
      _versions = $v.versions.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecipeOwner other) {
    _$v = other as _$RecipeOwner;
  }

  @override
  void update(void Function(RecipeOwnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecipeOwner build() => _build();

  _$RecipeOwner _build() {
    _$RecipeOwner _$result;
    try {
      _$result = _$v ??
          _$RecipeOwner._(
            ownerType: BuiltValueNullFieldError.checkNotNull(
                ownerType, r'RecipeOwner', 'ownerType'),
            ownerId: BuiltValueNullFieldError.checkNotNull(
                ownerId, r'RecipeOwner', 'ownerId'),
            trackInventory: trackInventory,
            active: _active?.build(),
            versions: versions.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'active';
        _active?.build();
        _$failedField = 'versions';
        versions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RecipeOwner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
