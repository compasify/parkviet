// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_code.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TableCodeStatusEnum _$tableCodeStatusEnum_active =
    const TableCodeStatusEnum._('active');
const TableCodeStatusEnum _$tableCodeStatusEnum_revoked =
    const TableCodeStatusEnum._('revoked');

TableCodeStatusEnum _$tableCodeStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$tableCodeStatusEnum_active;
    case 'revoked':
      return _$tableCodeStatusEnum_revoked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TableCodeStatusEnum> _$tableCodeStatusEnumValues =
    BuiltSet<TableCodeStatusEnum>(const <TableCodeStatusEnum>[
  _$tableCodeStatusEnum_active,
  _$tableCodeStatusEnum_revoked,
]);

Serializer<TableCodeStatusEnum> _$tableCodeStatusEnumSerializer =
    _$TableCodeStatusEnumSerializer();

class _$TableCodeStatusEnumSerializer
    implements PrimitiveSerializer<TableCodeStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'revoked': 'revoked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'revoked': 'revoked',
  };

  @override
  final Iterable<Type> types = const <Type>[TableCodeStatusEnum];
  @override
  final String wireName = 'TableCodeStatusEnum';

  @override
  Object serialize(Serializers serializers, TableCodeStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TableCodeStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TableCodeStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TableCode extends TableCode {
  @override
  final String id;
  @override
  final String resourceId;
  @override
  final TableCodeStatusEnum status;
  @override
  final DateTime rotatedAt;
  @override
  final DateTime? revokedAt;

  factory _$TableCode([void Function(TableCodeBuilder)? updates]) =>
      (TableCodeBuilder()..update(updates))._build();

  _$TableCode._(
      {required this.id,
      required this.resourceId,
      required this.status,
      required this.rotatedAt,
      this.revokedAt})
      : super._();
  @override
  TableCode rebuild(void Function(TableCodeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableCodeBuilder toBuilder() => TableCodeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableCode &&
        id == other.id &&
        resourceId == other.resourceId &&
        status == other.status &&
        rotatedAt == other.rotatedAt &&
        revokedAt == other.revokedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, rotatedAt.hashCode);
    _$hash = $jc(_$hash, revokedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableCode')
          ..add('id', id)
          ..add('resourceId', resourceId)
          ..add('status', status)
          ..add('rotatedAt', rotatedAt)
          ..add('revokedAt', revokedAt))
        .toString();
  }
}

class TableCodeBuilder implements Builder<TableCode, TableCodeBuilder> {
  _$TableCode? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  TableCodeStatusEnum? _status;
  TableCodeStatusEnum? get status => _$this._status;
  set status(TableCodeStatusEnum? status) => _$this._status = status;

  DateTime? _rotatedAt;
  DateTime? get rotatedAt => _$this._rotatedAt;
  set rotatedAt(DateTime? rotatedAt) => _$this._rotatedAt = rotatedAt;

  DateTime? _revokedAt;
  DateTime? get revokedAt => _$this._revokedAt;
  set revokedAt(DateTime? revokedAt) => _$this._revokedAt = revokedAt;

  TableCodeBuilder() {
    TableCode._defaults(this);
  }

  TableCodeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _resourceId = $v.resourceId;
      _status = $v.status;
      _rotatedAt = $v.rotatedAt;
      _revokedAt = $v.revokedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableCode other) {
    _$v = other as _$TableCode;
  }

  @override
  void update(void Function(TableCodeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableCode build() => _build();

  _$TableCode _build() {
    final _$result = _$v ??
        _$TableCode._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'TableCode', 'id'),
          resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId, r'TableCode', 'resourceId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'TableCode', 'status'),
          rotatedAt: BuiltValueNullFieldError.checkNotNull(
              rotatedAt, r'TableCode', 'rotatedAt'),
          revokedAt: revokedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
