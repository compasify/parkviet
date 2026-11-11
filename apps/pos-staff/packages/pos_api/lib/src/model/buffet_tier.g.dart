// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buffet_tier.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BuffetTierStatusEnum _$buffetTierStatusEnum_active =
    const BuffetTierStatusEnum._('active');
const BuffetTierStatusEnum _$buffetTierStatusEnum_archived =
    const BuffetTierStatusEnum._('archived');

BuffetTierStatusEnum _$buffetTierStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$buffetTierStatusEnum_active;
    case 'archived':
      return _$buffetTierStatusEnum_archived;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BuffetTierStatusEnum> _$buffetTierStatusEnumValues =
    BuiltSet<BuffetTierStatusEnum>(const <BuffetTierStatusEnum>[
  _$buffetTierStatusEnum_active,
  _$buffetTierStatusEnum_archived,
]);

Serializer<BuffetTierStatusEnum> _$buffetTierStatusEnumSerializer =
    _$BuffetTierStatusEnumSerializer();

class _$BuffetTierStatusEnumSerializer
    implements PrimitiveSerializer<BuffetTierStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'archived': 'archived',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'archived': 'archived',
  };

  @override
  final Iterable<Type> types = const <Type>[BuffetTierStatusEnum];
  @override
  final String wireName = 'BuffetTierStatusEnum';

  @override
  Object serialize(Serializers serializers, BuffetTierStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BuffetTierStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BuffetTierStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BuffetTier extends BuffetTier {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String name;
  @override
  final BuffetTierStatusEnum status;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final String variantId;
  @override
  final int durationMinutes;
  @override
  final int? roundItemLimit;
  @override
  final int roundIntervalMinutes;
  @override
  final BuiltList<BuffetTierItem> items;

  factory _$BuffetTier([void Function(BuffetTierBuilder)? updates]) =>
      (BuffetTierBuilder()..update(updates))._build();

  _$BuffetTier._(
      {required this.id,
      required this.branchId,
      required this.name,
      required this.status,
      required this.productId,
      required this.productName,
      required this.variantId,
      required this.durationMinutes,
      this.roundItemLimit,
      required this.roundIntervalMinutes,
      required this.items})
      : super._();
  @override
  BuffetTier rebuild(void Function(BuffetTierBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BuffetTierBuilder toBuilder() => BuffetTierBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BuffetTier &&
        id == other.id &&
        branchId == other.branchId &&
        name == other.name &&
        status == other.status &&
        productId == other.productId &&
        productName == other.productName &&
        variantId == other.variantId &&
        durationMinutes == other.durationMinutes &&
        roundItemLimit == other.roundItemLimit &&
        roundIntervalMinutes == other.roundIntervalMinutes &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, productId.hashCode);
    _$hash = $jc(_$hash, productName.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, durationMinutes.hashCode);
    _$hash = $jc(_$hash, roundItemLimit.hashCode);
    _$hash = $jc(_$hash, roundIntervalMinutes.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BuffetTier')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('name', name)
          ..add('status', status)
          ..add('productId', productId)
          ..add('productName', productName)
          ..add('variantId', variantId)
          ..add('durationMinutes', durationMinutes)
          ..add('roundItemLimit', roundItemLimit)
          ..add('roundIntervalMinutes', roundIntervalMinutes)
          ..add('items', items))
        .toString();
  }
}

class BuffetTierBuilder implements Builder<BuffetTier, BuffetTierBuilder> {
  _$BuffetTier? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  BuffetTierStatusEnum? _status;
  BuffetTierStatusEnum? get status => _$this._status;
  set status(BuffetTierStatusEnum? status) => _$this._status = status;

  String? _productId;
  String? get productId => _$this._productId;
  set productId(String? productId) => _$this._productId = productId;

  String? _productName;
  String? get productName => _$this._productName;
  set productName(String? productName) => _$this._productName = productName;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  int? _durationMinutes;
  int? get durationMinutes => _$this._durationMinutes;
  set durationMinutes(int? durationMinutes) =>
      _$this._durationMinutes = durationMinutes;

  int? _roundItemLimit;
  int? get roundItemLimit => _$this._roundItemLimit;
  set roundItemLimit(int? roundItemLimit) =>
      _$this._roundItemLimit = roundItemLimit;

  int? _roundIntervalMinutes;
  int? get roundIntervalMinutes => _$this._roundIntervalMinutes;
  set roundIntervalMinutes(int? roundIntervalMinutes) =>
      _$this._roundIntervalMinutes = roundIntervalMinutes;

  ListBuilder<BuffetTierItem>? _items;
  ListBuilder<BuffetTierItem> get items =>
      _$this._items ??= ListBuilder<BuffetTierItem>();
  set items(ListBuilder<BuffetTierItem>? items) => _$this._items = items;

  BuffetTierBuilder() {
    BuffetTier._defaults(this);
  }

  BuffetTierBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _name = $v.name;
      _status = $v.status;
      _productId = $v.productId;
      _productName = $v.productName;
      _variantId = $v.variantId;
      _durationMinutes = $v.durationMinutes;
      _roundItemLimit = $v.roundItemLimit;
      _roundIntervalMinutes = $v.roundIntervalMinutes;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuffetTier other) {
    _$v = other as _$BuffetTier;
  }

  @override
  void update(void Function(BuffetTierBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BuffetTier build() => _build();

  _$BuffetTier _build() {
    _$BuffetTier _$result;
    try {
      _$result = _$v ??
          _$BuffetTier._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'BuffetTier', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'BuffetTier', 'branchId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'BuffetTier', 'name'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'BuffetTier', 'status'),
            productId: BuiltValueNullFieldError.checkNotNull(
                productId, r'BuffetTier', 'productId'),
            productName: BuiltValueNullFieldError.checkNotNull(
                productName, r'BuffetTier', 'productName'),
            variantId: BuiltValueNullFieldError.checkNotNull(
                variantId, r'BuffetTier', 'variantId'),
            durationMinutes: BuiltValueNullFieldError.checkNotNull(
                durationMinutes, r'BuffetTier', 'durationMinutes'),
            roundItemLimit: roundItemLimit,
            roundIntervalMinutes: BuiltValueNullFieldError.checkNotNull(
                roundIntervalMinutes, r'BuffetTier', 'roundIntervalMinutes'),
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BuffetTier', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
