// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EinvoiceRelationEnum _$einvoiceRelationEnum_original =
    const EinvoiceRelationEnum._('original');
const EinvoiceRelationEnum _$einvoiceRelationEnum_replacement =
    const EinvoiceRelationEnum._('replacement');

EinvoiceRelationEnum _$einvoiceRelationEnumValueOf(String name) {
  switch (name) {
    case 'original':
      return _$einvoiceRelationEnum_original;
    case 'replacement':
      return _$einvoiceRelationEnum_replacement;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoiceRelationEnum> _$einvoiceRelationEnumValues =
    BuiltSet<EinvoiceRelationEnum>(const <EinvoiceRelationEnum>[
  _$einvoiceRelationEnum_original,
  _$einvoiceRelationEnum_replacement,
]);

const EinvoiceInvoiceTypeEnum _$einvoiceInvoiceTypeEnum_cashRegister =
    const EinvoiceInvoiceTypeEnum._('cashRegister');
const EinvoiceInvoiceTypeEnum _$einvoiceInvoiceTypeEnum_coded =
    const EinvoiceInvoiceTypeEnum._('coded');

EinvoiceInvoiceTypeEnum _$einvoiceInvoiceTypeEnumValueOf(String name) {
  switch (name) {
    case 'cashRegister':
      return _$einvoiceInvoiceTypeEnum_cashRegister;
    case 'coded':
      return _$einvoiceInvoiceTypeEnum_coded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoiceInvoiceTypeEnum> _$einvoiceInvoiceTypeEnumValues =
    BuiltSet<EinvoiceInvoiceTypeEnum>(const <EinvoiceInvoiceTypeEnum>[
  _$einvoiceInvoiceTypeEnum_cashRegister,
  _$einvoiceInvoiceTypeEnum_coded,
]);

const EinvoiceStatusEnum _$einvoiceStatusEnum_pending =
    const EinvoiceStatusEnum._('pending');
const EinvoiceStatusEnum _$einvoiceStatusEnum_issuing =
    const EinvoiceStatusEnum._('issuing');
const EinvoiceStatusEnum _$einvoiceStatusEnum_issued =
    const EinvoiceStatusEnum._('issued');
const EinvoiceStatusEnum _$einvoiceStatusEnum_failed =
    const EinvoiceStatusEnum._('failed');
const EinvoiceStatusEnum _$einvoiceStatusEnum_canceled =
    const EinvoiceStatusEnum._('canceled');
const EinvoiceStatusEnum _$einvoiceStatusEnum_replaced =
    const EinvoiceStatusEnum._('replaced');
const EinvoiceStatusEnum _$einvoiceStatusEnum_adjusted =
    const EinvoiceStatusEnum._('adjusted');

EinvoiceStatusEnum _$einvoiceStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$einvoiceStatusEnum_pending;
    case 'issuing':
      return _$einvoiceStatusEnum_issuing;
    case 'issued':
      return _$einvoiceStatusEnum_issued;
    case 'failed':
      return _$einvoiceStatusEnum_failed;
    case 'canceled':
      return _$einvoiceStatusEnum_canceled;
    case 'replaced':
      return _$einvoiceStatusEnum_replaced;
    case 'adjusted':
      return _$einvoiceStatusEnum_adjusted;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoiceStatusEnum> _$einvoiceStatusEnumValues =
    BuiltSet<EinvoiceStatusEnum>(const <EinvoiceStatusEnum>[
  _$einvoiceStatusEnum_pending,
  _$einvoiceStatusEnum_issuing,
  _$einvoiceStatusEnum_issued,
  _$einvoiceStatusEnum_failed,
  _$einvoiceStatusEnum_canceled,
  _$einvoiceStatusEnum_replaced,
  _$einvoiceStatusEnum_adjusted,
]);

const EinvoicePaymentMethodEnum _$einvoicePaymentMethodEnum_TM =
    const EinvoicePaymentMethodEnum._('TM');
const EinvoicePaymentMethodEnum _$einvoicePaymentMethodEnum_CK =
    const EinvoicePaymentMethodEnum._('CK');
const EinvoicePaymentMethodEnum _$einvoicePaymentMethodEnum_tMSlashCK =
    const EinvoicePaymentMethodEnum._('tMSlashCK');

EinvoicePaymentMethodEnum _$einvoicePaymentMethodEnumValueOf(String name) {
  switch (name) {
    case 'TM':
      return _$einvoicePaymentMethodEnum_TM;
    case 'CK':
      return _$einvoicePaymentMethodEnum_CK;
    case 'tMSlashCK':
      return _$einvoicePaymentMethodEnum_tMSlashCK;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoicePaymentMethodEnum> _$einvoicePaymentMethodEnumValues =
    BuiltSet<EinvoicePaymentMethodEnum>(const <EinvoicePaymentMethodEnum>[
  _$einvoicePaymentMethodEnum_TM,
  _$einvoicePaymentMethodEnum_CK,
  _$einvoicePaymentMethodEnum_tMSlashCK,
]);

Serializer<EinvoiceRelationEnum> _$einvoiceRelationEnumSerializer =
    _$EinvoiceRelationEnumSerializer();
Serializer<EinvoiceInvoiceTypeEnum> _$einvoiceInvoiceTypeEnumSerializer =
    _$EinvoiceInvoiceTypeEnumSerializer();
Serializer<EinvoiceStatusEnum> _$einvoiceStatusEnumSerializer =
    _$EinvoiceStatusEnumSerializer();
Serializer<EinvoicePaymentMethodEnum> _$einvoicePaymentMethodEnumSerializer =
    _$EinvoicePaymentMethodEnumSerializer();

class _$EinvoiceRelationEnumSerializer
    implements PrimitiveSerializer<EinvoiceRelationEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'original': 'original',
    'replacement': 'replacement',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'original': 'original',
    'replacement': 'replacement',
  };

  @override
  final Iterable<Type> types = const <Type>[EinvoiceRelationEnum];
  @override
  final String wireName = 'EinvoiceRelationEnum';

  @override
  Object serialize(Serializers serializers, EinvoiceRelationEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoiceRelationEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoiceRelationEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EinvoiceInvoiceTypeEnumSerializer
    implements PrimitiveSerializer<EinvoiceInvoiceTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cashRegister': 'cash_register',
    'coded': 'coded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash_register': 'cashRegister',
    'coded': 'coded',
  };

  @override
  final Iterable<Type> types = const <Type>[EinvoiceInvoiceTypeEnum];
  @override
  final String wireName = 'EinvoiceInvoiceTypeEnum';

  @override
  Object serialize(Serializers serializers, EinvoiceInvoiceTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoiceInvoiceTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoiceInvoiceTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EinvoiceStatusEnumSerializer
    implements PrimitiveSerializer<EinvoiceStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'issuing': 'issuing',
    'issued': 'issued',
    'failed': 'failed',
    'canceled': 'canceled',
    'replaced': 'replaced',
    'adjusted': 'adjusted',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'issuing': 'issuing',
    'issued': 'issued',
    'failed': 'failed',
    'canceled': 'canceled',
    'replaced': 'replaced',
    'adjusted': 'adjusted',
  };

  @override
  final Iterable<Type> types = const <Type>[EinvoiceStatusEnum];
  @override
  final String wireName = 'EinvoiceStatusEnum';

  @override
  Object serialize(Serializers serializers, EinvoiceStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoiceStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoiceStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EinvoicePaymentMethodEnumSerializer
    implements PrimitiveSerializer<EinvoicePaymentMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'TM': 'TM',
    'CK': 'CK',
    'tMSlashCK': 'TM/CK',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'TM': 'TM',
    'CK': 'CK',
    'TM/CK': 'tMSlashCK',
  };

  @override
  final Iterable<Type> types = const <Type>[EinvoicePaymentMethodEnum];
  @override
  final String wireName = 'EinvoicePaymentMethodEnum';

  @override
  Object serialize(Serializers serializers, EinvoicePaymentMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoicePaymentMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoicePaymentMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Einvoice extends Einvoice {
  @override
  final String id;
  @override
  final String orderId;
  @override
  final String orderNumber;
  @override
  final String workspaceId;
  @override
  final String branchId;
  @override
  final String branchName;
  @override
  final EinvoiceRelationEnum relation;
  @override
  final String? originalEinvoiceId;
  @override
  final EinvoiceInvoiceTypeEnum invoiceType;
  @override
  final String? provider;
  @override
  final EinvoiceStatusEnum status;
  @override
  final EinvoiceBuyer buyer;
  @override
  final EinvoiceSeller seller;
  @override
  final BuiltList<EinvoiceLine> lines;
  @override
  final EinvoiceTotals totals;
  @override
  final EinvoicePaymentMethodEnum? paymentMethod;
  @override
  final String currency;
  @override
  final String? templateCode;
  @override
  final String? symbol;
  @override
  final String? number;
  @override
  final String? cqtCode;
  @override
  final String? lookupCode;
  @override
  final String? lookupUrl;
  @override
  final DateTime? issuedAt;
  @override
  final int attempts;
  @override
  final DateTime? nextAttemptAt;
  @override
  final String? lastError;
  @override
  final bool buyerLinkOpen;
  @override
  final DateTime? buyerTokenExpiresAt;
  @override
  final DateTime? buyerSubmittedAt;
  @override
  final DateTime? canceledAt;
  @override
  final String? cancelReason;
  @override
  final DateTime? completedAt;
  @override
  final String? total;
  @override
  final DateTime createdAt;

  factory _$Einvoice([void Function(EinvoiceBuilder)? updates]) =>
      (EinvoiceBuilder()..update(updates))._build();

  _$Einvoice._(
      {required this.id,
      required this.orderId,
      required this.orderNumber,
      required this.workspaceId,
      required this.branchId,
      required this.branchName,
      required this.relation,
      this.originalEinvoiceId,
      required this.invoiceType,
      this.provider,
      required this.status,
      required this.buyer,
      required this.seller,
      required this.lines,
      required this.totals,
      this.paymentMethod,
      required this.currency,
      this.templateCode,
      this.symbol,
      this.number,
      this.cqtCode,
      this.lookupCode,
      this.lookupUrl,
      this.issuedAt,
      required this.attempts,
      this.nextAttemptAt,
      this.lastError,
      required this.buyerLinkOpen,
      this.buyerTokenExpiresAt,
      this.buyerSubmittedAt,
      this.canceledAt,
      this.cancelReason,
      this.completedAt,
      this.total,
      required this.createdAt})
      : super._();
  @override
  Einvoice rebuild(void Function(EinvoiceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceBuilder toBuilder() => EinvoiceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Einvoice &&
        id == other.id &&
        orderId == other.orderId &&
        orderNumber == other.orderNumber &&
        workspaceId == other.workspaceId &&
        branchId == other.branchId &&
        branchName == other.branchName &&
        relation == other.relation &&
        originalEinvoiceId == other.originalEinvoiceId &&
        invoiceType == other.invoiceType &&
        provider == other.provider &&
        status == other.status &&
        buyer == other.buyer &&
        seller == other.seller &&
        lines == other.lines &&
        totals == other.totals &&
        paymentMethod == other.paymentMethod &&
        currency == other.currency &&
        templateCode == other.templateCode &&
        symbol == other.symbol &&
        number == other.number &&
        cqtCode == other.cqtCode &&
        lookupCode == other.lookupCode &&
        lookupUrl == other.lookupUrl &&
        issuedAt == other.issuedAt &&
        attempts == other.attempts &&
        nextAttemptAt == other.nextAttemptAt &&
        lastError == other.lastError &&
        buyerLinkOpen == other.buyerLinkOpen &&
        buyerTokenExpiresAt == other.buyerTokenExpiresAt &&
        buyerSubmittedAt == other.buyerSubmittedAt &&
        canceledAt == other.canceledAt &&
        cancelReason == other.cancelReason &&
        completedAt == other.completedAt &&
        total == other.total &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, orderId.hashCode);
    _$hash = $jc(_$hash, orderNumber.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, branchName.hashCode);
    _$hash = $jc(_$hash, relation.hashCode);
    _$hash = $jc(_$hash, originalEinvoiceId.hashCode);
    _$hash = $jc(_$hash, invoiceType.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, buyer.hashCode);
    _$hash = $jc(_$hash, seller.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jc(_$hash, totals.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, templateCode.hashCode);
    _$hash = $jc(_$hash, symbol.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jc(_$hash, cqtCode.hashCode);
    _$hash = $jc(_$hash, lookupCode.hashCode);
    _$hash = $jc(_$hash, lookupUrl.hashCode);
    _$hash = $jc(_$hash, issuedAt.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jc(_$hash, nextAttemptAt.hashCode);
    _$hash = $jc(_$hash, lastError.hashCode);
    _$hash = $jc(_$hash, buyerLinkOpen.hashCode);
    _$hash = $jc(_$hash, buyerTokenExpiresAt.hashCode);
    _$hash = $jc(_$hash, buyerSubmittedAt.hashCode);
    _$hash = $jc(_$hash, canceledAt.hashCode);
    _$hash = $jc(_$hash, cancelReason.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Einvoice')
          ..add('id', id)
          ..add('orderId', orderId)
          ..add('orderNumber', orderNumber)
          ..add('workspaceId', workspaceId)
          ..add('branchId', branchId)
          ..add('branchName', branchName)
          ..add('relation', relation)
          ..add('originalEinvoiceId', originalEinvoiceId)
          ..add('invoiceType', invoiceType)
          ..add('provider', provider)
          ..add('status', status)
          ..add('buyer', buyer)
          ..add('seller', seller)
          ..add('lines', lines)
          ..add('totals', totals)
          ..add('paymentMethod', paymentMethod)
          ..add('currency', currency)
          ..add('templateCode', templateCode)
          ..add('symbol', symbol)
          ..add('number', number)
          ..add('cqtCode', cqtCode)
          ..add('lookupCode', lookupCode)
          ..add('lookupUrl', lookupUrl)
          ..add('issuedAt', issuedAt)
          ..add('attempts', attempts)
          ..add('nextAttemptAt', nextAttemptAt)
          ..add('lastError', lastError)
          ..add('buyerLinkOpen', buyerLinkOpen)
          ..add('buyerTokenExpiresAt', buyerTokenExpiresAt)
          ..add('buyerSubmittedAt', buyerSubmittedAt)
          ..add('canceledAt', canceledAt)
          ..add('cancelReason', cancelReason)
          ..add('completedAt', completedAt)
          ..add('total', total)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class EinvoiceBuilder implements Builder<Einvoice, EinvoiceBuilder> {
  _$Einvoice? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _orderId;
  String? get orderId => _$this._orderId;
  set orderId(String? orderId) => _$this._orderId = orderId;

  String? _orderNumber;
  String? get orderNumber => _$this._orderNumber;
  set orderNumber(String? orderNumber) => _$this._orderNumber = orderNumber;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _branchName;
  String? get branchName => _$this._branchName;
  set branchName(String? branchName) => _$this._branchName = branchName;

  EinvoiceRelationEnum? _relation;
  EinvoiceRelationEnum? get relation => _$this._relation;
  set relation(EinvoiceRelationEnum? relation) => _$this._relation = relation;

  String? _originalEinvoiceId;
  String? get originalEinvoiceId => _$this._originalEinvoiceId;
  set originalEinvoiceId(String? originalEinvoiceId) =>
      _$this._originalEinvoiceId = originalEinvoiceId;

  EinvoiceInvoiceTypeEnum? _invoiceType;
  EinvoiceInvoiceTypeEnum? get invoiceType => _$this._invoiceType;
  set invoiceType(EinvoiceInvoiceTypeEnum? invoiceType) =>
      _$this._invoiceType = invoiceType;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  EinvoiceStatusEnum? _status;
  EinvoiceStatusEnum? get status => _$this._status;
  set status(EinvoiceStatusEnum? status) => _$this._status = status;

  EinvoiceBuyerBuilder? _buyer;
  EinvoiceBuyerBuilder get buyer => _$this._buyer ??= EinvoiceBuyerBuilder();
  set buyer(EinvoiceBuyerBuilder? buyer) => _$this._buyer = buyer;

  EinvoiceSellerBuilder? _seller;
  EinvoiceSellerBuilder get seller =>
      _$this._seller ??= EinvoiceSellerBuilder();
  set seller(EinvoiceSellerBuilder? seller) => _$this._seller = seller;

  ListBuilder<EinvoiceLine>? _lines;
  ListBuilder<EinvoiceLine> get lines =>
      _$this._lines ??= ListBuilder<EinvoiceLine>();
  set lines(ListBuilder<EinvoiceLine>? lines) => _$this._lines = lines;

  EinvoiceTotalsBuilder? _totals;
  EinvoiceTotalsBuilder get totals =>
      _$this._totals ??= EinvoiceTotalsBuilder();
  set totals(EinvoiceTotalsBuilder? totals) => _$this._totals = totals;

  EinvoicePaymentMethodEnum? _paymentMethod;
  EinvoicePaymentMethodEnum? get paymentMethod => _$this._paymentMethod;
  set paymentMethod(EinvoicePaymentMethodEnum? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  String? _templateCode;
  String? get templateCode => _$this._templateCode;
  set templateCode(String? templateCode) => _$this._templateCode = templateCode;

  String? _symbol;
  String? get symbol => _$this._symbol;
  set symbol(String? symbol) => _$this._symbol = symbol;

  String? _number;
  String? get number => _$this._number;
  set number(String? number) => _$this._number = number;

  String? _cqtCode;
  String? get cqtCode => _$this._cqtCode;
  set cqtCode(String? cqtCode) => _$this._cqtCode = cqtCode;

  String? _lookupCode;
  String? get lookupCode => _$this._lookupCode;
  set lookupCode(String? lookupCode) => _$this._lookupCode = lookupCode;

  String? _lookupUrl;
  String? get lookupUrl => _$this._lookupUrl;
  set lookupUrl(String? lookupUrl) => _$this._lookupUrl = lookupUrl;

  DateTime? _issuedAt;
  DateTime? get issuedAt => _$this._issuedAt;
  set issuedAt(DateTime? issuedAt) => _$this._issuedAt = issuedAt;

  int? _attempts;
  int? get attempts => _$this._attempts;
  set attempts(int? attempts) => _$this._attempts = attempts;

  DateTime? _nextAttemptAt;
  DateTime? get nextAttemptAt => _$this._nextAttemptAt;
  set nextAttemptAt(DateTime? nextAttemptAt) =>
      _$this._nextAttemptAt = nextAttemptAt;

  String? _lastError;
  String? get lastError => _$this._lastError;
  set lastError(String? lastError) => _$this._lastError = lastError;

  bool? _buyerLinkOpen;
  bool? get buyerLinkOpen => _$this._buyerLinkOpen;
  set buyerLinkOpen(bool? buyerLinkOpen) =>
      _$this._buyerLinkOpen = buyerLinkOpen;

  DateTime? _buyerTokenExpiresAt;
  DateTime? get buyerTokenExpiresAt => _$this._buyerTokenExpiresAt;
  set buyerTokenExpiresAt(DateTime? buyerTokenExpiresAt) =>
      _$this._buyerTokenExpiresAt = buyerTokenExpiresAt;

  DateTime? _buyerSubmittedAt;
  DateTime? get buyerSubmittedAt => _$this._buyerSubmittedAt;
  set buyerSubmittedAt(DateTime? buyerSubmittedAt) =>
      _$this._buyerSubmittedAt = buyerSubmittedAt;

  DateTime? _canceledAt;
  DateTime? get canceledAt => _$this._canceledAt;
  set canceledAt(DateTime? canceledAt) => _$this._canceledAt = canceledAt;

  String? _cancelReason;
  String? get cancelReason => _$this._cancelReason;
  set cancelReason(String? cancelReason) => _$this._cancelReason = cancelReason;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  EinvoiceBuilder() {
    Einvoice._defaults(this);
  }

  EinvoiceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _orderId = $v.orderId;
      _orderNumber = $v.orderNumber;
      _workspaceId = $v.workspaceId;
      _branchId = $v.branchId;
      _branchName = $v.branchName;
      _relation = $v.relation;
      _originalEinvoiceId = $v.originalEinvoiceId;
      _invoiceType = $v.invoiceType;
      _provider = $v.provider;
      _status = $v.status;
      _buyer = $v.buyer.toBuilder();
      _seller = $v.seller.toBuilder();
      _lines = $v.lines.toBuilder();
      _totals = $v.totals.toBuilder();
      _paymentMethod = $v.paymentMethod;
      _currency = $v.currency;
      _templateCode = $v.templateCode;
      _symbol = $v.symbol;
      _number = $v.number;
      _cqtCode = $v.cqtCode;
      _lookupCode = $v.lookupCode;
      _lookupUrl = $v.lookupUrl;
      _issuedAt = $v.issuedAt;
      _attempts = $v.attempts;
      _nextAttemptAt = $v.nextAttemptAt;
      _lastError = $v.lastError;
      _buyerLinkOpen = $v.buyerLinkOpen;
      _buyerTokenExpiresAt = $v.buyerTokenExpiresAt;
      _buyerSubmittedAt = $v.buyerSubmittedAt;
      _canceledAt = $v.canceledAt;
      _cancelReason = $v.cancelReason;
      _completedAt = $v.completedAt;
      _total = $v.total;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Einvoice other) {
    _$v = other as _$Einvoice;
  }

  @override
  void update(void Function(EinvoiceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Einvoice build() => _build();

  _$Einvoice _build() {
    _$Einvoice _$result;
    try {
      _$result = _$v ??
          _$Einvoice._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Einvoice', 'id'),
            orderId: BuiltValueNullFieldError.checkNotNull(
                orderId, r'Einvoice', 'orderId'),
            orderNumber: BuiltValueNullFieldError.checkNotNull(
                orderNumber, r'Einvoice', 'orderNumber'),
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'Einvoice', 'workspaceId'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'Einvoice', 'branchId'),
            branchName: BuiltValueNullFieldError.checkNotNull(
                branchName, r'Einvoice', 'branchName'),
            relation: BuiltValueNullFieldError.checkNotNull(
                relation, r'Einvoice', 'relation'),
            originalEinvoiceId: originalEinvoiceId,
            invoiceType: BuiltValueNullFieldError.checkNotNull(
                invoiceType, r'Einvoice', 'invoiceType'),
            provider: provider,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Einvoice', 'status'),
            buyer: buyer.build(),
            seller: seller.build(),
            lines: lines.build(),
            totals: totals.build(),
            paymentMethod: paymentMethod,
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'Einvoice', 'currency'),
            templateCode: templateCode,
            symbol: symbol,
            number: number,
            cqtCode: cqtCode,
            lookupCode: lookupCode,
            lookupUrl: lookupUrl,
            issuedAt: issuedAt,
            attempts: BuiltValueNullFieldError.checkNotNull(
                attempts, r'Einvoice', 'attempts'),
            nextAttemptAt: nextAttemptAt,
            lastError: lastError,
            buyerLinkOpen: BuiltValueNullFieldError.checkNotNull(
                buyerLinkOpen, r'Einvoice', 'buyerLinkOpen'),
            buyerTokenExpiresAt: buyerTokenExpiresAt,
            buyerSubmittedAt: buyerSubmittedAt,
            canceledAt: canceledAt,
            cancelReason: cancelReason,
            completedAt: completedAt,
            total: total,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Einvoice', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'buyer';
        buyer.build();
        _$failedField = 'seller';
        seller.build();
        _$failedField = 'lines';
        lines.build();
        _$failedField = 'totals';
        totals.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Einvoice', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
