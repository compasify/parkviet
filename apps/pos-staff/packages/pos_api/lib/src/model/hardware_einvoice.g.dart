// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hardware_einvoice.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HardwareEinvoiceTypeEnum _$hardwareEinvoiceTypeEnum_none =
    const HardwareEinvoiceTypeEnum._('none');
const HardwareEinvoiceTypeEnum _$hardwareEinvoiceTypeEnum_cashRegister =
    const HardwareEinvoiceTypeEnum._('cashRegister');
const HardwareEinvoiceTypeEnum _$hardwareEinvoiceTypeEnum_coded =
    const HardwareEinvoiceTypeEnum._('coded');

HardwareEinvoiceTypeEnum _$hardwareEinvoiceTypeEnumValueOf(String name) {
  switch (name) {
    case 'none':
      return _$hardwareEinvoiceTypeEnum_none;
    case 'cashRegister':
      return _$hardwareEinvoiceTypeEnum_cashRegister;
    case 'coded':
      return _$hardwareEinvoiceTypeEnum_coded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HardwareEinvoiceTypeEnum> _$hardwareEinvoiceTypeEnumValues =
    BuiltSet<HardwareEinvoiceTypeEnum>(const <HardwareEinvoiceTypeEnum>[
  _$hardwareEinvoiceTypeEnum_none,
  _$hardwareEinvoiceTypeEnum_cashRegister,
  _$hardwareEinvoiceTypeEnum_coded,
]);

Serializer<HardwareEinvoiceTypeEnum> _$hardwareEinvoiceTypeEnumSerializer =
    _$HardwareEinvoiceTypeEnumSerializer();

class _$HardwareEinvoiceTypeEnumSerializer
    implements PrimitiveSerializer<HardwareEinvoiceTypeEnum> {
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
  final Iterable<Type> types = const <Type>[HardwareEinvoiceTypeEnum];
  @override
  final String wireName = 'HardwareEinvoiceTypeEnum';

  @override
  Object serialize(Serializers serializers, HardwareEinvoiceTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  HardwareEinvoiceTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      HardwareEinvoiceTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$HardwareEinvoice extends HardwareEinvoice {
  @override
  final HardwareEinvoiceTypeEnum type;
  @override
  final String provider;
  @override
  final bool configured;
  @override
  final BuiltList<String> missingFields;

  factory _$HardwareEinvoice(
          [void Function(HardwareEinvoiceBuilder)? updates]) =>
      (HardwareEinvoiceBuilder()..update(updates))._build();

  _$HardwareEinvoice._(
      {required this.type,
      required this.provider,
      required this.configured,
      required this.missingFields})
      : super._();
  @override
  HardwareEinvoice rebuild(void Function(HardwareEinvoiceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HardwareEinvoiceBuilder toBuilder() =>
      HardwareEinvoiceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HardwareEinvoice &&
        type == other.type &&
        provider == other.provider &&
        configured == other.configured &&
        missingFields == other.missingFields;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, configured.hashCode);
    _$hash = $jc(_$hash, missingFields.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HardwareEinvoice')
          ..add('type', type)
          ..add('provider', provider)
          ..add('configured', configured)
          ..add('missingFields', missingFields))
        .toString();
  }
}

class HardwareEinvoiceBuilder
    implements Builder<HardwareEinvoice, HardwareEinvoiceBuilder> {
  _$HardwareEinvoice? _$v;

  HardwareEinvoiceTypeEnum? _type;
  HardwareEinvoiceTypeEnum? get type => _$this._type;
  set type(HardwareEinvoiceTypeEnum? type) => _$this._type = type;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  bool? _configured;
  bool? get configured => _$this._configured;
  set configured(bool? configured) => _$this._configured = configured;

  ListBuilder<String>? _missingFields;
  ListBuilder<String> get missingFields =>
      _$this._missingFields ??= ListBuilder<String>();
  set missingFields(ListBuilder<String>? missingFields) =>
      _$this._missingFields = missingFields;

  HardwareEinvoiceBuilder() {
    HardwareEinvoice._defaults(this);
  }

  HardwareEinvoiceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _provider = $v.provider;
      _configured = $v.configured;
      _missingFields = $v.missingFields.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HardwareEinvoice other) {
    _$v = other as _$HardwareEinvoice;
  }

  @override
  void update(void Function(HardwareEinvoiceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HardwareEinvoice build() => _build();

  _$HardwareEinvoice _build() {
    _$HardwareEinvoice _$result;
    try {
      _$result = _$v ??
          _$HardwareEinvoice._(
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'HardwareEinvoice', 'type'),
            provider: BuiltValueNullFieldError.checkNotNull(
                provider, r'HardwareEinvoice', 'provider'),
            configured: BuiltValueNullFieldError.checkNotNull(
                configured, r'HardwareEinvoice', 'configured'),
            missingFields: missingFields.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'missingFields';
        missingFields.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'HardwareEinvoice', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
