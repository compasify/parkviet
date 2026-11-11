// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_setting_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlatformSettingInputPlatformEnum
    _$platformSettingInputPlatformEnum_grabfood =
    const PlatformSettingInputPlatformEnum._('grabfood');
const PlatformSettingInputPlatformEnum
    _$platformSettingInputPlatformEnum_shopeefood =
    const PlatformSettingInputPlatformEnum._('shopeefood');

PlatformSettingInputPlatformEnum _$platformSettingInputPlatformEnumValueOf(
    String name) {
  switch (name) {
    case 'grabfood':
      return _$platformSettingInputPlatformEnum_grabfood;
    case 'shopeefood':
      return _$platformSettingInputPlatformEnum_shopeefood;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlatformSettingInputPlatformEnum>
    _$platformSettingInputPlatformEnumValues = BuiltSet<
        PlatformSettingInputPlatformEnum>(const <PlatformSettingInputPlatformEnum>[
  _$platformSettingInputPlatformEnum_grabfood,
  _$platformSettingInputPlatformEnum_shopeefood,
]);

const PlatformSettingInputStatusEnum _$platformSettingInputStatusEnum_active =
    const PlatformSettingInputStatusEnum._('active');
const PlatformSettingInputStatusEnum _$platformSettingInputStatusEnum_disabled =
    const PlatformSettingInputStatusEnum._('disabled');

PlatformSettingInputStatusEnum _$platformSettingInputStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'active':
      return _$platformSettingInputStatusEnum_active;
    case 'disabled':
      return _$platformSettingInputStatusEnum_disabled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlatformSettingInputStatusEnum>
    _$platformSettingInputStatusEnumValues = BuiltSet<
        PlatformSettingInputStatusEnum>(const <PlatformSettingInputStatusEnum>[
  _$platformSettingInputStatusEnum_active,
  _$platformSettingInputStatusEnum_disabled,
]);

Serializer<PlatformSettingInputPlatformEnum>
    _$platformSettingInputPlatformEnumSerializer =
    _$PlatformSettingInputPlatformEnumSerializer();
Serializer<PlatformSettingInputStatusEnum>
    _$platformSettingInputStatusEnumSerializer =
    _$PlatformSettingInputStatusEnumSerializer();

class _$PlatformSettingInputPlatformEnumSerializer
    implements PrimitiveSerializer<PlatformSettingInputPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };

  @override
  final Iterable<Type> types = const <Type>[PlatformSettingInputPlatformEnum];
  @override
  final String wireName = 'PlatformSettingInputPlatformEnum';

  @override
  Object serialize(
          Serializers serializers, PlatformSettingInputPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlatformSettingInputPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlatformSettingInputPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlatformSettingInputStatusEnumSerializer
    implements PrimitiveSerializer<PlatformSettingInputStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'disabled': 'disabled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'disabled': 'disabled',
  };

  @override
  final Iterable<Type> types = const <Type>[PlatformSettingInputStatusEnum];
  @override
  final String wireName = 'PlatformSettingInputStatusEnum';

  @override
  Object serialize(
          Serializers serializers, PlatformSettingInputStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlatformSettingInputStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlatformSettingInputStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlatformSettingInput extends PlatformSettingInput {
  @override
  final String branchId;
  @override
  final PlatformSettingInputPlatformEnum platform;
  @override
  final PlatformSettingInputStatusEnum status;
  @override
  final String commissionRate;

  factory _$PlatformSettingInput(
          [void Function(PlatformSettingInputBuilder)? updates]) =>
      (PlatformSettingInputBuilder()..update(updates))._build();

  _$PlatformSettingInput._(
      {required this.branchId,
      required this.platform,
      required this.status,
      required this.commissionRate})
      : super._();
  @override
  PlatformSettingInput rebuild(
          void Function(PlatformSettingInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformSettingInputBuilder toBuilder() =>
      PlatformSettingInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformSettingInput &&
        branchId == other.branchId &&
        platform == other.platform &&
        status == other.status &&
        commissionRate == other.commissionRate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, commissionRate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformSettingInput')
          ..add('branchId', branchId)
          ..add('platform', platform)
          ..add('status', status)
          ..add('commissionRate', commissionRate))
        .toString();
  }
}

class PlatformSettingInputBuilder
    implements Builder<PlatformSettingInput, PlatformSettingInputBuilder> {
  _$PlatformSettingInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  PlatformSettingInputPlatformEnum? _platform;
  PlatformSettingInputPlatformEnum? get platform => _$this._platform;
  set platform(PlatformSettingInputPlatformEnum? platform) =>
      _$this._platform = platform;

  PlatformSettingInputStatusEnum? _status;
  PlatformSettingInputStatusEnum? get status => _$this._status;
  set status(PlatformSettingInputStatusEnum? status) => _$this._status = status;

  String? _commissionRate;
  String? get commissionRate => _$this._commissionRate;
  set commissionRate(String? commissionRate) =>
      _$this._commissionRate = commissionRate;

  PlatformSettingInputBuilder() {
    PlatformSettingInput._defaults(this);
  }

  PlatformSettingInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _platform = $v.platform;
      _status = $v.status;
      _commissionRate = $v.commissionRate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformSettingInput other) {
    _$v = other as _$PlatformSettingInput;
  }

  @override
  void update(void Function(PlatformSettingInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformSettingInput build() => _build();

  _$PlatformSettingInput _build() {
    final _$result = _$v ??
        _$PlatformSettingInput._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'PlatformSettingInput', 'branchId'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'PlatformSettingInput', 'platform'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PlatformSettingInput', 'status'),
          commissionRate: BuiltValueNullFieldError.checkNotNull(
              commissionRate, r'PlatformSettingInput', 'commissionRate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
