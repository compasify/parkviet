// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_register_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KioskRegisterRefKindEnum _$kioskRegisterRefKindEnum_counter =
    const KioskRegisterRefKindEnum._('counter');
const KioskRegisterRefKindEnum _$kioskRegisterRefKindEnum_kiosk =
    const KioskRegisterRefKindEnum._('kiosk');

KioskRegisterRefKindEnum _$kioskRegisterRefKindEnumValueOf(String name) {
  switch (name) {
    case 'counter':
      return _$kioskRegisterRefKindEnum_counter;
    case 'kiosk':
      return _$kioskRegisterRefKindEnum_kiosk;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KioskRegisterRefKindEnum> _$kioskRegisterRefKindEnumValues =
    BuiltSet<KioskRegisterRefKindEnum>(const <KioskRegisterRefKindEnum>[
  _$kioskRegisterRefKindEnum_counter,
  _$kioskRegisterRefKindEnum_kiosk,
]);

Serializer<KioskRegisterRefKindEnum> _$kioskRegisterRefKindEnumSerializer =
    _$KioskRegisterRefKindEnumSerializer();

class _$KioskRegisterRefKindEnumSerializer
    implements PrimitiveSerializer<KioskRegisterRefKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'counter': 'counter',
    'kiosk': 'kiosk',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'counter': 'counter',
    'kiosk': 'kiosk',
  };

  @override
  final Iterable<Type> types = const <Type>[KioskRegisterRefKindEnum];
  @override
  final String wireName = 'KioskRegisterRefKindEnum';

  @override
  Object serialize(Serializers serializers, KioskRegisterRefKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KioskRegisterRefKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KioskRegisterRefKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KioskRegisterRef extends KioskRegisterRef {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String name;
  @override
  final String code;
  @override
  final KioskRegisterRefKindEnum kind;
  @override
  final String status;

  factory _$KioskRegisterRef(
          [void Function(KioskRegisterRefBuilder)? updates]) =>
      (KioskRegisterRefBuilder()..update(updates))._build();

  _$KioskRegisterRef._(
      {required this.id,
      required this.branchId,
      required this.name,
      required this.code,
      required this.kind,
      required this.status})
      : super._();
  @override
  KioskRegisterRef rebuild(void Function(KioskRegisterRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskRegisterRefBuilder toBuilder() =>
      KioskRegisterRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskRegisterRef &&
        id == other.id &&
        branchId == other.branchId &&
        name == other.name &&
        code == other.code &&
        kind == other.kind &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskRegisterRef')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('name', name)
          ..add('code', code)
          ..add('kind', kind)
          ..add('status', status))
        .toString();
  }
}

class KioskRegisterRefBuilder
    implements Builder<KioskRegisterRef, KioskRegisterRefBuilder> {
  _$KioskRegisterRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  KioskRegisterRefKindEnum? _kind;
  KioskRegisterRefKindEnum? get kind => _$this._kind;
  set kind(KioskRegisterRefKindEnum? kind) => _$this._kind = kind;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  KioskRegisterRefBuilder() {
    KioskRegisterRef._defaults(this);
  }

  KioskRegisterRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _name = $v.name;
      _code = $v.code;
      _kind = $v.kind;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskRegisterRef other) {
    _$v = other as _$KioskRegisterRef;
  }

  @override
  void update(void Function(KioskRegisterRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskRegisterRef build() => _build();

  _$KioskRegisterRef _build() {
    final _$result = _$v ??
        _$KioskRegisterRef._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'KioskRegisterRef', 'id'),
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'KioskRegisterRef', 'branchId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KioskRegisterRef', 'name'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'KioskRegisterRef', 'code'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'KioskRegisterRef', 'kind'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'KioskRegisterRef', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
