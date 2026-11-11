// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_setting.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlatformSettingPlatformEnum _$platformSettingPlatformEnum_grabfood =
    const PlatformSettingPlatformEnum._('grabfood');
const PlatformSettingPlatformEnum _$platformSettingPlatformEnum_shopeefood =
    const PlatformSettingPlatformEnum._('shopeefood');

PlatformSettingPlatformEnum _$platformSettingPlatformEnumValueOf(String name) {
  switch (name) {
    case 'grabfood':
      return _$platformSettingPlatformEnum_grabfood;
    case 'shopeefood':
      return _$platformSettingPlatformEnum_shopeefood;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlatformSettingPlatformEnum>
    _$platformSettingPlatformEnumValues =
    BuiltSet<PlatformSettingPlatformEnum>(const <PlatformSettingPlatformEnum>[
  _$platformSettingPlatformEnum_grabfood,
  _$platformSettingPlatformEnum_shopeefood,
]);

const PlatformSettingStatusEnum _$platformSettingStatusEnum_active =
    const PlatformSettingStatusEnum._('active');
const PlatformSettingStatusEnum _$platformSettingStatusEnum_disabled =
    const PlatformSettingStatusEnum._('disabled');

PlatformSettingStatusEnum _$platformSettingStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$platformSettingStatusEnum_active;
    case 'disabled':
      return _$platformSettingStatusEnum_disabled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlatformSettingStatusEnum> _$platformSettingStatusEnumValues =
    BuiltSet<PlatformSettingStatusEnum>(const <PlatformSettingStatusEnum>[
  _$platformSettingStatusEnum_active,
  _$platformSettingStatusEnum_disabled,
]);

Serializer<PlatformSettingPlatformEnum>
    _$platformSettingPlatformEnumSerializer =
    _$PlatformSettingPlatformEnumSerializer();
Serializer<PlatformSettingStatusEnum> _$platformSettingStatusEnumSerializer =
    _$PlatformSettingStatusEnumSerializer();

class _$PlatformSettingPlatformEnumSerializer
    implements PrimitiveSerializer<PlatformSettingPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };

  @override
  final Iterable<Type> types = const <Type>[PlatformSettingPlatformEnum];
  @override
  final String wireName = 'PlatformSettingPlatformEnum';

  @override
  Object serialize(Serializers serializers, PlatformSettingPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlatformSettingPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlatformSettingPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlatformSettingStatusEnumSerializer
    implements PrimitiveSerializer<PlatformSettingStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'disabled': 'disabled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'disabled': 'disabled',
  };

  @override
  final Iterable<Type> types = const <Type>[PlatformSettingStatusEnum];
  @override
  final String wireName = 'PlatformSettingStatusEnum';

  @override
  Object serialize(Serializers serializers, PlatformSettingStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlatformSettingStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlatformSettingStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlatformSetting extends PlatformSetting {
  @override
  final PlatformSettingPlatformEnum platform;
  @override
  final PlatformSettingStatusEnum status;
  @override
  final String commissionRate;
  @override
  final DateTime? updatedAt;

  factory _$PlatformSetting([void Function(PlatformSettingBuilder)? updates]) =>
      (PlatformSettingBuilder()..update(updates))._build();

  _$PlatformSetting._(
      {required this.platform,
      required this.status,
      required this.commissionRate,
      this.updatedAt})
      : super._();
  @override
  PlatformSetting rebuild(void Function(PlatformSettingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformSettingBuilder toBuilder() => PlatformSettingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformSetting &&
        platform == other.platform &&
        status == other.status &&
        commissionRate == other.commissionRate &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, commissionRate.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformSetting')
          ..add('platform', platform)
          ..add('status', status)
          ..add('commissionRate', commissionRate)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PlatformSettingBuilder
    implements Builder<PlatformSetting, PlatformSettingBuilder> {
  _$PlatformSetting? _$v;

  PlatformSettingPlatformEnum? _platform;
  PlatformSettingPlatformEnum? get platform => _$this._platform;
  set platform(PlatformSettingPlatformEnum? platform) =>
      _$this._platform = platform;

  PlatformSettingStatusEnum? _status;
  PlatformSettingStatusEnum? get status => _$this._status;
  set status(PlatformSettingStatusEnum? status) => _$this._status = status;

  String? _commissionRate;
  String? get commissionRate => _$this._commissionRate;
  set commissionRate(String? commissionRate) =>
      _$this._commissionRate = commissionRate;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PlatformSettingBuilder() {
    PlatformSetting._defaults(this);
  }

  PlatformSettingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _platform = $v.platform;
      _status = $v.status;
      _commissionRate = $v.commissionRate;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformSetting other) {
    _$v = other as _$PlatformSetting;
  }

  @override
  void update(void Function(PlatformSettingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformSetting build() => _build();

  _$PlatformSetting _build() {
    final _$result = _$v ??
        _$PlatformSetting._(
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'PlatformSetting', 'platform'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PlatformSetting', 'status'),
          commissionRate: BuiltValueNullFieldError.checkNotNull(
              commissionRate, r'PlatformSetting', 'commissionRate'),
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
