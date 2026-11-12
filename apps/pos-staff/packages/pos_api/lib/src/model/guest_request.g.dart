// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GuestRequestKindEnum _$guestRequestKindEnum_callStaff =
    const GuestRequestKindEnum._('callStaff');
const GuestRequestKindEnum _$guestRequestKindEnum_requestBill =
    const GuestRequestKindEnum._('requestBill');

GuestRequestKindEnum _$guestRequestKindEnumValueOf(String name) {
  switch (name) {
    case 'callStaff':
      return _$guestRequestKindEnum_callStaff;
    case 'requestBill':
      return _$guestRequestKindEnum_requestBill;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GuestRequestKindEnum> _$guestRequestKindEnumValues =
    BuiltSet<GuestRequestKindEnum>(const <GuestRequestKindEnum>[
  _$guestRequestKindEnum_callStaff,
  _$guestRequestKindEnum_requestBill,
]);

const GuestRequestStatusEnum _$guestRequestStatusEnum_open =
    const GuestRequestStatusEnum._('open');
const GuestRequestStatusEnum _$guestRequestStatusEnum_done =
    const GuestRequestStatusEnum._('done');

GuestRequestStatusEnum _$guestRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$guestRequestStatusEnum_open;
    case 'done':
      return _$guestRequestStatusEnum_done;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GuestRequestStatusEnum> _$guestRequestStatusEnumValues =
    BuiltSet<GuestRequestStatusEnum>(const <GuestRequestStatusEnum>[
  _$guestRequestStatusEnum_open,
  _$guestRequestStatusEnum_done,
]);

Serializer<GuestRequestKindEnum> _$guestRequestKindEnumSerializer =
    _$GuestRequestKindEnumSerializer();
Serializer<GuestRequestStatusEnum> _$guestRequestStatusEnumSerializer =
    _$GuestRequestStatusEnumSerializer();

class _$GuestRequestKindEnumSerializer
    implements PrimitiveSerializer<GuestRequestKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'callStaff': 'call_staff',
    'requestBill': 'request_bill',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'call_staff': 'callStaff',
    'request_bill': 'requestBill',
  };

  @override
  final Iterable<Type> types = const <Type>[GuestRequestKindEnum];
  @override
  final String wireName = 'GuestRequestKindEnum';

  @override
  Object serialize(Serializers serializers, GuestRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GuestRequestKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GuestRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GuestRequestStatusEnumSerializer
    implements PrimitiveSerializer<GuestRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'done': 'done',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'done': 'done',
  };

  @override
  final Iterable<Type> types = const <Type>[GuestRequestStatusEnum];
  @override
  final String wireName = 'GuestRequestStatusEnum';

  @override
  Object serialize(Serializers serializers, GuestRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GuestRequestStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GuestRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GuestRequest extends GuestRequest {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String resourceId;
  @override
  final String tableName;
  @override
  final String? areaId;
  @override
  final String? workspaceId;
  @override
  final GuestRequestKindEnum kind;
  @override
  final GuestRequestStatusEnum status;
  @override
  final String? handledByName;
  @override
  final DateTime? handledAt;
  @override
  final DateTime createdAt;

  factory _$GuestRequest([void Function(GuestRequestBuilder)? updates]) =>
      (GuestRequestBuilder()..update(updates))._build();

  _$GuestRequest._(
      {required this.id,
      required this.branchId,
      required this.resourceId,
      required this.tableName,
      this.areaId,
      this.workspaceId,
      required this.kind,
      required this.status,
      this.handledByName,
      this.handledAt,
      required this.createdAt})
      : super._();
  @override
  GuestRequest rebuild(void Function(GuestRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GuestRequestBuilder toBuilder() => GuestRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GuestRequest &&
        id == other.id &&
        branchId == other.branchId &&
        resourceId == other.resourceId &&
        tableName == other.tableName &&
        areaId == other.areaId &&
        workspaceId == other.workspaceId &&
        kind == other.kind &&
        status == other.status &&
        handledByName == other.handledByName &&
        handledAt == other.handledAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, tableName.hashCode);
    _$hash = $jc(_$hash, areaId.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, handledByName.hashCode);
    _$hash = $jc(_$hash, handledAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GuestRequest')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('resourceId', resourceId)
          ..add('tableName', tableName)
          ..add('areaId', areaId)
          ..add('workspaceId', workspaceId)
          ..add('kind', kind)
          ..add('status', status)
          ..add('handledByName', handledByName)
          ..add('handledAt', handledAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GuestRequestBuilder
    implements Builder<GuestRequest, GuestRequestBuilder> {
  _$GuestRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _tableName;
  String? get tableName => _$this._tableName;
  set tableName(String? tableName) => _$this._tableName = tableName;

  String? _areaId;
  String? get areaId => _$this._areaId;
  set areaId(String? areaId) => _$this._areaId = areaId;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  GuestRequestKindEnum? _kind;
  GuestRequestKindEnum? get kind => _$this._kind;
  set kind(GuestRequestKindEnum? kind) => _$this._kind = kind;

  GuestRequestStatusEnum? _status;
  GuestRequestStatusEnum? get status => _$this._status;
  set status(GuestRequestStatusEnum? status) => _$this._status = status;

  String? _handledByName;
  String? get handledByName => _$this._handledByName;
  set handledByName(String? handledByName) =>
      _$this._handledByName = handledByName;

  DateTime? _handledAt;
  DateTime? get handledAt => _$this._handledAt;
  set handledAt(DateTime? handledAt) => _$this._handledAt = handledAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  GuestRequestBuilder() {
    GuestRequest._defaults(this);
  }

  GuestRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _resourceId = $v.resourceId;
      _tableName = $v.tableName;
      _areaId = $v.areaId;
      _workspaceId = $v.workspaceId;
      _kind = $v.kind;
      _status = $v.status;
      _handledByName = $v.handledByName;
      _handledAt = $v.handledAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GuestRequest other) {
    _$v = other as _$GuestRequest;
  }

  @override
  void update(void Function(GuestRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GuestRequest build() => _build();

  _$GuestRequest _build() {
    final _$result = _$v ??
        _$GuestRequest._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'GuestRequest', 'id'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'GuestRequest', 'branchId'),
          resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId, r'GuestRequest', 'resourceId'),
          tableName: BuiltValueNullFieldError.checkNotNull(
              tableName, r'GuestRequest', 'tableName'),
          areaId: areaId,
          workspaceId: workspaceId,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'GuestRequest', 'kind'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'GuestRequest', 'status'),
          handledByName: handledByName,
          handledAt: handledAt,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'GuestRequest', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
