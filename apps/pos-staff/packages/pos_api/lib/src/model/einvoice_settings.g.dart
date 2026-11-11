// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EinvoiceSettingsEinvoiceTypeEnum _$einvoiceSettingsEinvoiceTypeEnum_none =
    const EinvoiceSettingsEinvoiceTypeEnum._('none');
const EinvoiceSettingsEinvoiceTypeEnum
    _$einvoiceSettingsEinvoiceTypeEnum_cashRegister =
    const EinvoiceSettingsEinvoiceTypeEnum._('cashRegister');
const EinvoiceSettingsEinvoiceTypeEnum
    _$einvoiceSettingsEinvoiceTypeEnum_coded =
    const EinvoiceSettingsEinvoiceTypeEnum._('coded');

EinvoiceSettingsEinvoiceTypeEnum _$einvoiceSettingsEinvoiceTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'none':
      return _$einvoiceSettingsEinvoiceTypeEnum_none;
    case 'cashRegister':
      return _$einvoiceSettingsEinvoiceTypeEnum_cashRegister;
    case 'coded':
      return _$einvoiceSettingsEinvoiceTypeEnum_coded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoiceSettingsEinvoiceTypeEnum>
    _$einvoiceSettingsEinvoiceTypeEnumValues = BuiltSet<
        EinvoiceSettingsEinvoiceTypeEnum>(const <EinvoiceSettingsEinvoiceTypeEnum>[
  _$einvoiceSettingsEinvoiceTypeEnum_none,
  _$einvoiceSettingsEinvoiceTypeEnum_cashRegister,
  _$einvoiceSettingsEinvoiceTypeEnum_coded,
]);

Serializer<EinvoiceSettingsEinvoiceTypeEnum>
    _$einvoiceSettingsEinvoiceTypeEnumSerializer =
    _$EinvoiceSettingsEinvoiceTypeEnumSerializer();

class _$EinvoiceSettingsEinvoiceTypeEnumSerializer
    implements PrimitiveSerializer<EinvoiceSettingsEinvoiceTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'none': 'none',
    'cashRegister': 'cash_register',
    'coded': 'coded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'none': 'none',
    'cash_register': 'cashRegister',
    'coded': 'coded',
  };

  @override
  final Iterable<Type> types = const <Type>[EinvoiceSettingsEinvoiceTypeEnum];
  @override
  final String wireName = 'EinvoiceSettingsEinvoiceTypeEnum';

  @override
  Object serialize(
          Serializers serializers, EinvoiceSettingsEinvoiceTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoiceSettingsEinvoiceTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoiceSettingsEinvoiceTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EinvoiceSettings extends EinvoiceSettings {
  @override
  final EinvoiceSettingsEinvoiceTypeEnum einvoiceType;
  @override
  final BuiltList<EinvoiceSettingsProvidersInner> providers;
  @override
  final BuiltList<EinvoiceSetting> settings;
  @override
  final bool publicLink;

  factory _$EinvoiceSettings(
          [void Function(EinvoiceSettingsBuilder)? updates]) =>
      (EinvoiceSettingsBuilder()..update(updates))._build();

  _$EinvoiceSettings._(
      {required this.einvoiceType,
      required this.providers,
      required this.settings,
      required this.publicLink})
      : super._();
  @override
  EinvoiceSettings rebuild(void Function(EinvoiceSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceSettingsBuilder toBuilder() =>
      EinvoiceSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceSettings &&
        einvoiceType == other.einvoiceType &&
        providers == other.providers &&
        settings == other.settings &&
        publicLink == other.publicLink;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, einvoiceType.hashCode);
    _$hash = $jc(_$hash, providers.hashCode);
    _$hash = $jc(_$hash, settings.hashCode);
    _$hash = $jc(_$hash, publicLink.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceSettings')
          ..add('einvoiceType', einvoiceType)
          ..add('providers', providers)
          ..add('settings', settings)
          ..add('publicLink', publicLink))
        .toString();
  }
}

class EinvoiceSettingsBuilder
    implements Builder<EinvoiceSettings, EinvoiceSettingsBuilder> {
  _$EinvoiceSettings? _$v;

  EinvoiceSettingsEinvoiceTypeEnum? _einvoiceType;
  EinvoiceSettingsEinvoiceTypeEnum? get einvoiceType => _$this._einvoiceType;
  set einvoiceType(EinvoiceSettingsEinvoiceTypeEnum? einvoiceType) =>
      _$this._einvoiceType = einvoiceType;

  ListBuilder<EinvoiceSettingsProvidersInner>? _providers;
  ListBuilder<EinvoiceSettingsProvidersInner> get providers =>
      _$this._providers ??= ListBuilder<EinvoiceSettingsProvidersInner>();
  set providers(ListBuilder<EinvoiceSettingsProvidersInner>? providers) =>
      _$this._providers = providers;

  ListBuilder<EinvoiceSetting>? _settings;
  ListBuilder<EinvoiceSetting> get settings =>
      _$this._settings ??= ListBuilder<EinvoiceSetting>();
  set settings(ListBuilder<EinvoiceSetting>? settings) =>
      _$this._settings = settings;

  bool? _publicLink;
  bool? get publicLink => _$this._publicLink;
  set publicLink(bool? publicLink) => _$this._publicLink = publicLink;

  EinvoiceSettingsBuilder() {
    EinvoiceSettings._defaults(this);
  }

  EinvoiceSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _einvoiceType = $v.einvoiceType;
      _providers = $v.providers.toBuilder();
      _settings = $v.settings.toBuilder();
      _publicLink = $v.publicLink;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceSettings other) {
    _$v = other as _$EinvoiceSettings;
  }

  @override
  void update(void Function(EinvoiceSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceSettings build() => _build();

  _$EinvoiceSettings _build() {
    _$EinvoiceSettings _$result;
    try {
      _$result = _$v ??
          _$EinvoiceSettings._(
            einvoiceType: BuiltValueNullFieldError.checkNotNull(
                einvoiceType, r'EinvoiceSettings', 'einvoiceType'),
            providers: providers.build(),
            settings: settings.build(),
            publicLink: BuiltValueNullFieldError.checkNotNull(
                publicLink, r'EinvoiceSettings', 'publicLink'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'providers';
        providers.build();
        _$failedField = 'settings';
        settings.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EinvoiceSettings', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
