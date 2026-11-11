// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_setting.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EinvoiceSettingStatusEnum _$einvoiceSettingStatusEnum_active =
    const EinvoiceSettingStatusEnum._('active');
const EinvoiceSettingStatusEnum _$einvoiceSettingStatusEnum_disabled =
    const EinvoiceSettingStatusEnum._('disabled');

EinvoiceSettingStatusEnum _$einvoiceSettingStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$einvoiceSettingStatusEnum_active;
    case 'disabled':
      return _$einvoiceSettingStatusEnum_disabled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoiceSettingStatusEnum> _$einvoiceSettingStatusEnumValues =
    BuiltSet<EinvoiceSettingStatusEnum>(const <EinvoiceSettingStatusEnum>[
  _$einvoiceSettingStatusEnum_active,
  _$einvoiceSettingStatusEnum_disabled,
]);

Serializer<EinvoiceSettingStatusEnum> _$einvoiceSettingStatusEnumSerializer =
    _$EinvoiceSettingStatusEnumSerializer();

class _$EinvoiceSettingStatusEnumSerializer
    implements PrimitiveSerializer<EinvoiceSettingStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'disabled': 'disabled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'disabled': 'disabled',
  };

  @override
  final Iterable<Type> types = const <Type>[EinvoiceSettingStatusEnum];
  @override
  final String wireName = 'EinvoiceSettingStatusEnum';

  @override
  Object serialize(Serializers serializers, EinvoiceSettingStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoiceSettingStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoiceSettingStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EinvoiceSetting extends EinvoiceSetting {
  @override
  final String id;
  @override
  final String? branchId;
  @override
  final String? branchName;
  @override
  final String provider;
  @override
  final EinvoiceSettingStatusEnum status;
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
  final BuiltList<String> credentialFields;
  @override
  final DateTime? updatedAt;

  factory _$EinvoiceSetting([void Function(EinvoiceSettingBuilder)? updates]) =>
      (EinvoiceSettingBuilder()..update(updates))._build();

  _$EinvoiceSetting._(
      {required this.id,
      this.branchId,
      this.branchName,
      required this.provider,
      required this.status,
      this.templateCode,
      this.symbol,
      this.sellerName,
      this.sellerTaxCode,
      this.sellerAddress,
      this.consumerLabel,
      this.lookupUrl,
      this.buyerLinkHours,
      required this.credentialFields,
      this.updatedAt})
      : super._();
  @override
  EinvoiceSetting rebuild(void Function(EinvoiceSettingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceSettingBuilder toBuilder() => EinvoiceSettingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceSetting &&
        id == other.id &&
        branchId == other.branchId &&
        branchName == other.branchName &&
        provider == other.provider &&
        status == other.status &&
        templateCode == other.templateCode &&
        symbol == other.symbol &&
        sellerName == other.sellerName &&
        sellerTaxCode == other.sellerTaxCode &&
        sellerAddress == other.sellerAddress &&
        consumerLabel == other.consumerLabel &&
        lookupUrl == other.lookupUrl &&
        buyerLinkHours == other.buyerLinkHours &&
        credentialFields == other.credentialFields &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, branchName.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, templateCode.hashCode);
    _$hash = $jc(_$hash, symbol.hashCode);
    _$hash = $jc(_$hash, sellerName.hashCode);
    _$hash = $jc(_$hash, sellerTaxCode.hashCode);
    _$hash = $jc(_$hash, sellerAddress.hashCode);
    _$hash = $jc(_$hash, consumerLabel.hashCode);
    _$hash = $jc(_$hash, lookupUrl.hashCode);
    _$hash = $jc(_$hash, buyerLinkHours.hashCode);
    _$hash = $jc(_$hash, credentialFields.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceSetting')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('branchName', branchName)
          ..add('provider', provider)
          ..add('status', status)
          ..add('templateCode', templateCode)
          ..add('symbol', symbol)
          ..add('sellerName', sellerName)
          ..add('sellerTaxCode', sellerTaxCode)
          ..add('sellerAddress', sellerAddress)
          ..add('consumerLabel', consumerLabel)
          ..add('lookupUrl', lookupUrl)
          ..add('buyerLinkHours', buyerLinkHours)
          ..add('credentialFields', credentialFields)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class EinvoiceSettingBuilder
    implements Builder<EinvoiceSetting, EinvoiceSettingBuilder> {
  _$EinvoiceSetting? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _branchName;
  String? get branchName => _$this._branchName;
  set branchName(String? branchName) => _$this._branchName = branchName;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  EinvoiceSettingStatusEnum? _status;
  EinvoiceSettingStatusEnum? get status => _$this._status;
  set status(EinvoiceSettingStatusEnum? status) => _$this._status = status;

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

  ListBuilder<String>? _credentialFields;
  ListBuilder<String> get credentialFields =>
      _$this._credentialFields ??= ListBuilder<String>();
  set credentialFields(ListBuilder<String>? credentialFields) =>
      _$this._credentialFields = credentialFields;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  EinvoiceSettingBuilder() {
    EinvoiceSetting._defaults(this);
  }

  EinvoiceSettingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _branchName = $v.branchName;
      _provider = $v.provider;
      _status = $v.status;
      _templateCode = $v.templateCode;
      _symbol = $v.symbol;
      _sellerName = $v.sellerName;
      _sellerTaxCode = $v.sellerTaxCode;
      _sellerAddress = $v.sellerAddress;
      _consumerLabel = $v.consumerLabel;
      _lookupUrl = $v.lookupUrl;
      _buyerLinkHours = $v.buyerLinkHours;
      _credentialFields = $v.credentialFields.toBuilder();
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceSetting other) {
    _$v = other as _$EinvoiceSetting;
  }

  @override
  void update(void Function(EinvoiceSettingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceSetting build() => _build();

  _$EinvoiceSetting _build() {
    _$EinvoiceSetting _$result;
    try {
      _$result = _$v ??
          _$EinvoiceSetting._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'EinvoiceSetting', 'id'),
            branchId: branchId,
            branchName: branchName,
            provider: BuiltValueNullFieldError.checkNotNull(
                provider, r'EinvoiceSetting', 'provider'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'EinvoiceSetting', 'status'),
            templateCode: templateCode,
            symbol: symbol,
            sellerName: sellerName,
            sellerTaxCode: sellerTaxCode,
            sellerAddress: sellerAddress,
            consumerLabel: consumerLabel,
            lookupUrl: lookupUrl,
            buyerLinkHours: buyerLinkHours,
            credentialFields: credentialFields.build(),
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'credentialFields';
        credentialFields.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EinvoiceSetting', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
