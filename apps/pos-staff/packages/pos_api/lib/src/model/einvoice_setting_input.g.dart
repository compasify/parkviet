// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_setting_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EinvoiceSettingInputStatusEnum _$einvoiceSettingInputStatusEnum_active =
    const EinvoiceSettingInputStatusEnum._('active');
const EinvoiceSettingInputStatusEnum _$einvoiceSettingInputStatusEnum_disabled =
    const EinvoiceSettingInputStatusEnum._('disabled');

EinvoiceSettingInputStatusEnum _$einvoiceSettingInputStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'active':
      return _$einvoiceSettingInputStatusEnum_active;
    case 'disabled':
      return _$einvoiceSettingInputStatusEnum_disabled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoiceSettingInputStatusEnum>
    _$einvoiceSettingInputStatusEnumValues = BuiltSet<
        EinvoiceSettingInputStatusEnum>(const <EinvoiceSettingInputStatusEnum>[
  _$einvoiceSettingInputStatusEnum_active,
  _$einvoiceSettingInputStatusEnum_disabled,
]);

Serializer<EinvoiceSettingInputStatusEnum>
    _$einvoiceSettingInputStatusEnumSerializer =
    _$EinvoiceSettingInputStatusEnumSerializer();

class _$EinvoiceSettingInputStatusEnumSerializer
    implements PrimitiveSerializer<EinvoiceSettingInputStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'disabled': 'disabled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'disabled': 'disabled',
  };

  @override
  final Iterable<Type> types = const <Type>[EinvoiceSettingInputStatusEnum];
  @override
  final String wireName = 'EinvoiceSettingInputStatusEnum';

  @override
  Object serialize(
          Serializers serializers, EinvoiceSettingInputStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoiceSettingInputStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoiceSettingInputStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EinvoiceSettingInput extends EinvoiceSettingInput {
  @override
  final String? provider;
  @override
  final BuiltMap<String, String>? credentials;
  @override
  final String? templateCode;
  @override
  final String? symbol;
  @override
  final String? sellerName;
  @override
  final String? sellerTaxCode;
  @override
  final String? sellerAddress;
  @override
  final String? consumerLabel;
  @override
  final String? lookupUrl;
  @override
  final int? buyerLinkHours;
  @override
  final EinvoiceSettingInputStatusEnum? status;

  factory _$EinvoiceSettingInput(
          [void Function(EinvoiceSettingInputBuilder)? updates]) =>
      (EinvoiceSettingInputBuilder()..update(updates))._build();

  _$EinvoiceSettingInput._(
      {this.provider,
      this.credentials,
      this.templateCode,
      this.symbol,
      this.sellerName,
      this.sellerTaxCode,
      this.sellerAddress,
      this.consumerLabel,
      this.lookupUrl,
      this.buyerLinkHours,
      this.status})
      : super._();
  @override
  EinvoiceSettingInput rebuild(
          void Function(EinvoiceSettingInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceSettingInputBuilder toBuilder() =>
      EinvoiceSettingInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceSettingInput &&
        provider == other.provider &&
        credentials == other.credentials &&
        templateCode == other.templateCode &&
        symbol == other.symbol &&
        sellerName == other.sellerName &&
        sellerTaxCode == other.sellerTaxCode &&
        sellerAddress == other.sellerAddress &&
        consumerLabel == other.consumerLabel &&
        lookupUrl == other.lookupUrl &&
        buyerLinkHours == other.buyerLinkHours &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, credentials.hashCode);
    _$hash = $jc(_$hash, templateCode.hashCode);
    _$hash = $jc(_$hash, symbol.hashCode);
    _$hash = $jc(_$hash, sellerName.hashCode);
    _$hash = $jc(_$hash, sellerTaxCode.hashCode);
    _$hash = $jc(_$hash, sellerAddress.hashCode);
    _$hash = $jc(_$hash, consumerLabel.hashCode);
    _$hash = $jc(_$hash, lookupUrl.hashCode);
    _$hash = $jc(_$hash, buyerLinkHours.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceSettingInput')
          ..add('provider', provider)
          ..add('credentials', credentials)
          ..add('templateCode', templateCode)
          ..add('symbol', symbol)
          ..add('sellerName', sellerName)
          ..add('sellerTaxCode', sellerTaxCode)
          ..add('sellerAddress', sellerAddress)
          ..add('consumerLabel', consumerLabel)
          ..add('lookupUrl', lookupUrl)
          ..add('buyerLinkHours', buyerLinkHours)
          ..add('status', status))
        .toString();
  }
}

class EinvoiceSettingInputBuilder
    implements Builder<EinvoiceSettingInput, EinvoiceSettingInputBuilder> {
  _$EinvoiceSettingInput? _$v;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  MapBuilder<String, String>? _credentials;
  MapBuilder<String, String> get credentials =>
      _$this._credentials ??= MapBuilder<String, String>();
  set credentials(MapBuilder<String, String>? credentials) =>
      _$this._credentials = credentials;

  String? _templateCode;
  String? get templateCode => _$this._templateCode;
  set templateCode(String? templateCode) => _$this._templateCode = templateCode;

  String? _symbol;
  String? get symbol => _$this._symbol;
  set symbol(String? symbol) => _$this._symbol = symbol;

  String? _sellerName;
  String? get sellerName => _$this._sellerName;
  set sellerName(String? sellerName) => _$this._sellerName = sellerName;

  String? _sellerTaxCode;
  String? get sellerTaxCode => _$this._sellerTaxCode;
  set sellerTaxCode(String? sellerTaxCode) =>
      _$this._sellerTaxCode = sellerTaxCode;

  String? _sellerAddress;
  String? get sellerAddress => _$this._sellerAddress;
  set sellerAddress(String? sellerAddress) =>
      _$this._sellerAddress = sellerAddress;

  String? _consumerLabel;
  String? get consumerLabel => _$this._consumerLabel;
  set consumerLabel(String? consumerLabel) =>
      _$this._consumerLabel = consumerLabel;

  String? _lookupUrl;
  String? get lookupUrl => _$this._lookupUrl;
  set lookupUrl(String? lookupUrl) => _$this._lookupUrl = lookupUrl;

  int? _buyerLinkHours;
  int? get buyerLinkHours => _$this._buyerLinkHours;
  set buyerLinkHours(int? buyerLinkHours) =>
      _$this._buyerLinkHours = buyerLinkHours;

  EinvoiceSettingInputStatusEnum? _status;
  EinvoiceSettingInputStatusEnum? get status => _$this._status;
  set status(EinvoiceSettingInputStatusEnum? status) => _$this._status = status;

  EinvoiceSettingInputBuilder() {
    EinvoiceSettingInput._defaults(this);
  }

  EinvoiceSettingInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _provider = $v.provider;
      _credentials = $v.credentials?.toBuilder();
      _templateCode = $v.templateCode;
      _symbol = $v.symbol;
      _sellerName = $v.sellerName;
      _sellerTaxCode = $v.sellerTaxCode;
      _sellerAddress = $v.sellerAddress;
      _consumerLabel = $v.consumerLabel;
      _lookupUrl = $v.lookupUrl;
      _buyerLinkHours = $v.buyerLinkHours;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceSettingInput other) {
    _$v = other as _$EinvoiceSettingInput;
  }

  @override
  void update(void Function(EinvoiceSettingInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceSettingInput build() => _build();

  _$EinvoiceSettingInput _build() {
    _$EinvoiceSettingInput _$result;
    try {
      _$result = _$v ??
          _$EinvoiceSettingInput._(
            provider: provider,
            credentials: _credentials?.build(),
            templateCode: templateCode,
            symbol: symbol,
            sellerName: sellerName,
            sellerTaxCode: sellerTaxCode,
            sellerAddress: sellerAddress,
            consumerLabel: consumerLabel,
            lookupUrl: lookupUrl,
            buyerLinkHours: buyerLinkHours,
            status: status,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'credentials';
        _credentials?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EinvoiceSettingInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
