// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sale.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OfflineSaleStatusEnum _$offlineSaleStatusEnum_completed =
    const OfflineSaleStatusEnum._('completed');
const OfflineSaleStatusEnum _$offlineSaleStatusEnum_needsReview =
    const OfflineSaleStatusEnum._('needsReview');
const OfflineSaleStatusEnum _$offlineSaleStatusEnum_rejected =
    const OfflineSaleStatusEnum._('rejected');

OfflineSaleStatusEnum _$offlineSaleStatusEnumValueOf(String name) {
  switch (name) {
    case 'completed':
      return _$offlineSaleStatusEnum_completed;
    case 'needsReview':
      return _$offlineSaleStatusEnum_needsReview;
    case 'rejected':
      return _$offlineSaleStatusEnum_rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OfflineSaleStatusEnum> _$offlineSaleStatusEnumValues =
    BuiltSet<OfflineSaleStatusEnum>(const <OfflineSaleStatusEnum>[
  _$offlineSaleStatusEnum_completed,
  _$offlineSaleStatusEnum_needsReview,
  _$offlineSaleStatusEnum_rejected,
]);

const OfflineSaleReviewReasonEnum _$offlineSaleReviewReasonEnum_priceChanged =
    const OfflineSaleReviewReasonEnum._('priceChanged');
const OfflineSaleReviewReasonEnum
    _$offlineSaleReviewReasonEnum_itemUnavailable =
    const OfflineSaleReviewReasonEnum._('itemUnavailable');
const OfflineSaleReviewReasonEnum _$offlineSaleReviewReasonEnum_itemSoldOut =
    const OfflineSaleReviewReasonEnum._('itemSoldOut');
const OfflineSaleReviewReasonEnum _$offlineSaleReviewReasonEnum_shiftClosed =
    const OfflineSaleReviewReasonEnum._('shiftClosed');
const OfflineSaleReviewReasonEnum _$offlineSaleReviewReasonEnum_shiftMismatch =
    const OfflineSaleReviewReasonEnum._('shiftMismatch');
const OfflineSaleReviewReasonEnum _$offlineSaleReviewReasonEnum_saleRefused =
    const OfflineSaleReviewReasonEnum._('saleRefused');

OfflineSaleReviewReasonEnum _$offlineSaleReviewReasonEnumValueOf(String name) {
  switch (name) {
    case 'priceChanged':
      return _$offlineSaleReviewReasonEnum_priceChanged;
    case 'itemUnavailable':
      return _$offlineSaleReviewReasonEnum_itemUnavailable;
    case 'itemSoldOut':
      return _$offlineSaleReviewReasonEnum_itemSoldOut;
    case 'shiftClosed':
      return _$offlineSaleReviewReasonEnum_shiftClosed;
    case 'shiftMismatch':
      return _$offlineSaleReviewReasonEnum_shiftMismatch;
    case 'saleRefused':
      return _$offlineSaleReviewReasonEnum_saleRefused;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OfflineSaleReviewReasonEnum>
    _$offlineSaleReviewReasonEnumValues =
    BuiltSet<OfflineSaleReviewReasonEnum>(const <OfflineSaleReviewReasonEnum>[
  _$offlineSaleReviewReasonEnum_priceChanged,
  _$offlineSaleReviewReasonEnum_itemUnavailable,
  _$offlineSaleReviewReasonEnum_itemSoldOut,
  _$offlineSaleReviewReasonEnum_shiftClosed,
  _$offlineSaleReviewReasonEnum_shiftMismatch,
  _$offlineSaleReviewReasonEnum_saleRefused,
]);

const OfflineSaleResolutionEnum _$offlineSaleResolutionEnum_acceptCollected =
    const OfflineSaleResolutionEnum._('acceptCollected');
const OfflineSaleResolutionEnum _$offlineSaleResolutionEnum_currentPrice =
    const OfflineSaleResolutionEnum._('currentPrice');
const OfflineSaleResolutionEnum _$offlineSaleResolutionEnum_edited =
    const OfflineSaleResolutionEnum._('edited');
const OfflineSaleResolutionEnum _$offlineSaleResolutionEnum_rejected =
    const OfflineSaleResolutionEnum._('rejected');

OfflineSaleResolutionEnum _$offlineSaleResolutionEnumValueOf(String name) {
  switch (name) {
    case 'acceptCollected':
      return _$offlineSaleResolutionEnum_acceptCollected;
    case 'currentPrice':
      return _$offlineSaleResolutionEnum_currentPrice;
    case 'edited':
      return _$offlineSaleResolutionEnum_edited;
    case 'rejected':
      return _$offlineSaleResolutionEnum_rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OfflineSaleResolutionEnum> _$offlineSaleResolutionEnumValues =
    BuiltSet<OfflineSaleResolutionEnum>(const <OfflineSaleResolutionEnum>[
  _$offlineSaleResolutionEnum_acceptCollected,
  _$offlineSaleResolutionEnum_currentPrice,
  _$offlineSaleResolutionEnum_edited,
  _$offlineSaleResolutionEnum_rejected,
]);

Serializer<OfflineSaleStatusEnum> _$offlineSaleStatusEnumSerializer =
    _$OfflineSaleStatusEnumSerializer();
Serializer<OfflineSaleReviewReasonEnum>
    _$offlineSaleReviewReasonEnumSerializer =
    _$OfflineSaleReviewReasonEnumSerializer();
Serializer<OfflineSaleResolutionEnum> _$offlineSaleResolutionEnumSerializer =
    _$OfflineSaleResolutionEnumSerializer();

class _$OfflineSaleStatusEnumSerializer
    implements PrimitiveSerializer<OfflineSaleStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'completed': 'completed',
    'needsReview': 'needs_review',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'completed': 'completed',
    'needs_review': 'needsReview',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[OfflineSaleStatusEnum];
  @override
  final String wireName = 'OfflineSaleStatusEnum';

  @override
  Object serialize(Serializers serializers, OfflineSaleStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OfflineSaleStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OfflineSaleStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OfflineSaleReviewReasonEnumSerializer
    implements PrimitiveSerializer<OfflineSaleReviewReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'priceChanged': 'price_changed',
    'itemUnavailable': 'item_unavailable',
    'itemSoldOut': 'item_sold_out',
    'shiftClosed': 'shift_closed',
    'shiftMismatch': 'shift_mismatch',
    'saleRefused': 'sale_refused',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'price_changed': 'priceChanged',
    'item_unavailable': 'itemUnavailable',
    'item_sold_out': 'itemSoldOut',
    'shift_closed': 'shiftClosed',
    'shift_mismatch': 'shiftMismatch',
    'sale_refused': 'saleRefused',
  };

  @override
  final Iterable<Type> types = const <Type>[OfflineSaleReviewReasonEnum];
  @override
  final String wireName = 'OfflineSaleReviewReasonEnum';

  @override
  Object serialize(Serializers serializers, OfflineSaleReviewReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OfflineSaleReviewReasonEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OfflineSaleReviewReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OfflineSaleResolutionEnumSerializer
    implements PrimitiveSerializer<OfflineSaleResolutionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'acceptCollected': 'accept_collected',
    'currentPrice': 'current_price',
    'edited': 'edited',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'accept_collected': 'acceptCollected',
    'current_price': 'currentPrice',
    'edited': 'edited',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[OfflineSaleResolutionEnum];
  @override
  final String wireName = 'OfflineSaleResolutionEnum';

  @override
  Object serialize(Serializers serializers, OfflineSaleResolutionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OfflineSaleResolutionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OfflineSaleResolutionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OfflineSale extends OfflineSale {
  @override
  final String id;
  @override
  final String offlineId;
  @override
  final String provisionalNumber;
  @override
  final OfflineSaleStatusEnum status;
  @override
  final String branchId;
  @override
  final String registerId;
  @override
  final String shiftId;
  @override
  final OfflineSaleStaff staff;
  @override
  final DateTime clientSoldAt;
  @override
  final bool clockCheck;
  @override
  final int clockSkewSeconds;
  @override
  final String collectedTotal;
  @override
  final String handedAmount;
  @override
  final String currency;
  @override
  final BuiltList<OfflineSaleLine> lines;
  @override
  final OfflineSaleReviewReasonEnum? reviewReason;
  @override
  final BuiltMap<String, JsonObject?> reviewDetails;
  @override
  final String? workspaceId;
  @override
  final String? orderNumber;
  @override
  final int? callNumber;
  @override
  final String? currentTotal;
  @override
  final OfflineSaleResolutionEnum? resolution;
  @override
  final String? resolutionNote;
  @override
  final DateTime? resolvedAt;
  @override
  final OfflineSaleStaff? resolvedBy;
  @override
  final DateTime createdAt;

  factory _$OfflineSale([void Function(OfflineSaleBuilder)? updates]) =>
      (OfflineSaleBuilder()..update(updates))._build();

  _$OfflineSale._(
      {required this.id,
      required this.offlineId,
      required this.provisionalNumber,
      required this.status,
      required this.branchId,
      required this.registerId,
      required this.shiftId,
      required this.staff,
      required this.clientSoldAt,
      required this.clockCheck,
      required this.clockSkewSeconds,
      required this.collectedTotal,
      required this.handedAmount,
      required this.currency,
      required this.lines,
      this.reviewReason,
      required this.reviewDetails,
      this.workspaceId,
      this.orderNumber,
      this.callNumber,
      this.currentTotal,
      this.resolution,
      this.resolutionNote,
      this.resolvedAt,
      this.resolvedBy,
      required this.createdAt})
      : super._();
  @override
  OfflineSale rebuild(void Function(OfflineSaleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSaleBuilder toBuilder() => OfflineSaleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSale &&
        id == other.id &&
        offlineId == other.offlineId &&
        provisionalNumber == other.provisionalNumber &&
        status == other.status &&
        branchId == other.branchId &&
        registerId == other.registerId &&
        shiftId == other.shiftId &&
        staff == other.staff &&
        clientSoldAt == other.clientSoldAt &&
        clockCheck == other.clockCheck &&
        clockSkewSeconds == other.clockSkewSeconds &&
        collectedTotal == other.collectedTotal &&
        handedAmount == other.handedAmount &&
        currency == other.currency &&
        lines == other.lines &&
        reviewReason == other.reviewReason &&
        reviewDetails == other.reviewDetails &&
        workspaceId == other.workspaceId &&
        orderNumber == other.orderNumber &&
        callNumber == other.callNumber &&
        currentTotal == other.currentTotal &&
        resolution == other.resolution &&
        resolutionNote == other.resolutionNote &&
        resolvedAt == other.resolvedAt &&
        resolvedBy == other.resolvedBy &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, offlineId.hashCode);
    _$hash = $jc(_$hash, provisionalNumber.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, registerId.hashCode);
    _$hash = $jc(_$hash, shiftId.hashCode);
    _$hash = $jc(_$hash, staff.hashCode);
    _$hash = $jc(_$hash, clientSoldAt.hashCode);
    _$hash = $jc(_$hash, clockCheck.hashCode);
    _$hash = $jc(_$hash, clockSkewSeconds.hashCode);
    _$hash = $jc(_$hash, collectedTotal.hashCode);
    _$hash = $jc(_$hash, handedAmount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jc(_$hash, reviewReason.hashCode);
    _$hash = $jc(_$hash, reviewDetails.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, orderNumber.hashCode);
    _$hash = $jc(_$hash, callNumber.hashCode);
    _$hash = $jc(_$hash, currentTotal.hashCode);
    _$hash = $jc(_$hash, resolution.hashCode);
    _$hash = $jc(_$hash, resolutionNote.hashCode);
    _$hash = $jc(_$hash, resolvedAt.hashCode);
    _$hash = $jc(_$hash, resolvedBy.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSale')
          ..add('id', id)
          ..add('offlineId', offlineId)
          ..add('provisionalNumber', provisionalNumber)
          ..add('status', status)
          ..add('branchId', branchId)
          ..add('registerId', registerId)
          ..add('shiftId', shiftId)
          ..add('staff', staff)
          ..add('clientSoldAt', clientSoldAt)
          ..add('clockCheck', clockCheck)
          ..add('clockSkewSeconds', clockSkewSeconds)
          ..add('collectedTotal', collectedTotal)
          ..add('handedAmount', handedAmount)
          ..add('currency', currency)
          ..add('lines', lines)
          ..add('reviewReason', reviewReason)
          ..add('reviewDetails', reviewDetails)
          ..add('workspaceId', workspaceId)
          ..add('orderNumber', orderNumber)
          ..add('callNumber', callNumber)
          ..add('currentTotal', currentTotal)
          ..add('resolution', resolution)
          ..add('resolutionNote', resolutionNote)
          ..add('resolvedAt', resolvedAt)
          ..add('resolvedBy', resolvedBy)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class OfflineSaleBuilder implements Builder<OfflineSale, OfflineSaleBuilder> {
  _$OfflineSale? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _offlineId;
  String? get offlineId => _$this._offlineId;
  set offlineId(String? offlineId) => _$this._offlineId = offlineId;

  String? _provisionalNumber;
  String? get provisionalNumber => _$this._provisionalNumber;
  set provisionalNumber(String? provisionalNumber) =>
      _$this._provisionalNumber = provisionalNumber;

  OfflineSaleStatusEnum? _status;
  OfflineSaleStatusEnum? get status => _$this._status;
  set status(OfflineSaleStatusEnum? status) => _$this._status = status;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _registerId;
  String? get registerId => _$this._registerId;
  set registerId(String? registerId) => _$this._registerId = registerId;

  String? _shiftId;
  String? get shiftId => _$this._shiftId;
  set shiftId(String? shiftId) => _$this._shiftId = shiftId;

  OfflineSaleStaffBuilder? _staff;
  OfflineSaleStaffBuilder get staff =>
      _$this._staff ??= OfflineSaleStaffBuilder();
  set staff(OfflineSaleStaffBuilder? staff) => _$this._staff = staff;

  DateTime? _clientSoldAt;
  DateTime? get clientSoldAt => _$this._clientSoldAt;
  set clientSoldAt(DateTime? clientSoldAt) =>
      _$this._clientSoldAt = clientSoldAt;

  bool? _clockCheck;
  bool? get clockCheck => _$this._clockCheck;
  set clockCheck(bool? clockCheck) => _$this._clockCheck = clockCheck;

  int? _clockSkewSeconds;
  int? get clockSkewSeconds => _$this._clockSkewSeconds;
  set clockSkewSeconds(int? clockSkewSeconds) =>
      _$this._clockSkewSeconds = clockSkewSeconds;

  String? _collectedTotal;
  String? get collectedTotal => _$this._collectedTotal;
  set collectedTotal(String? collectedTotal) =>
      _$this._collectedTotal = collectedTotal;

  String? _handedAmount;
  String? get handedAmount => _$this._handedAmount;
  set handedAmount(String? handedAmount) => _$this._handedAmount = handedAmount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  ListBuilder<OfflineSaleLine>? _lines;
  ListBuilder<OfflineSaleLine> get lines =>
      _$this._lines ??= ListBuilder<OfflineSaleLine>();
  set lines(ListBuilder<OfflineSaleLine>? lines) => _$this._lines = lines;

  OfflineSaleReviewReasonEnum? _reviewReason;
  OfflineSaleReviewReasonEnum? get reviewReason => _$this._reviewReason;
  set reviewReason(OfflineSaleReviewReasonEnum? reviewReason) =>
      _$this._reviewReason = reviewReason;

  MapBuilder<String, JsonObject?>? _reviewDetails;
  MapBuilder<String, JsonObject?> get reviewDetails =>
      _$this._reviewDetails ??= MapBuilder<String, JsonObject?>();
  set reviewDetails(MapBuilder<String, JsonObject?>? reviewDetails) =>
      _$this._reviewDetails = reviewDetails;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _orderNumber;
  String? get orderNumber => _$this._orderNumber;
  set orderNumber(String? orderNumber) => _$this._orderNumber = orderNumber;

  int? _callNumber;
  int? get callNumber => _$this._callNumber;
  set callNumber(int? callNumber) => _$this._callNumber = callNumber;

  String? _currentTotal;
  String? get currentTotal => _$this._currentTotal;
  set currentTotal(String? currentTotal) => _$this._currentTotal = currentTotal;

  OfflineSaleResolutionEnum? _resolution;
  OfflineSaleResolutionEnum? get resolution => _$this._resolution;
  set resolution(OfflineSaleResolutionEnum? resolution) =>
      _$this._resolution = resolution;

  String? _resolutionNote;
  String? get resolutionNote => _$this._resolutionNote;
  set resolutionNote(String? resolutionNote) =>
      _$this._resolutionNote = resolutionNote;

  DateTime? _resolvedAt;
  DateTime? get resolvedAt => _$this._resolvedAt;
  set resolvedAt(DateTime? resolvedAt) => _$this._resolvedAt = resolvedAt;

  OfflineSaleStaffBuilder? _resolvedBy;
  OfflineSaleStaffBuilder get resolvedBy =>
      _$this._resolvedBy ??= OfflineSaleStaffBuilder();
  set resolvedBy(OfflineSaleStaffBuilder? resolvedBy) =>
      _$this._resolvedBy = resolvedBy;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  OfflineSaleBuilder() {
    OfflineSale._defaults(this);
  }

  OfflineSaleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _offlineId = $v.offlineId;
      _provisionalNumber = $v.provisionalNumber;
      _status = $v.status;
      _branchId = $v.branchId;
      _registerId = $v.registerId;
      _shiftId = $v.shiftId;
      _staff = $v.staff.toBuilder();
      _clientSoldAt = $v.clientSoldAt;
      _clockCheck = $v.clockCheck;
      _clockSkewSeconds = $v.clockSkewSeconds;
      _collectedTotal = $v.collectedTotal;
      _handedAmount = $v.handedAmount;
      _currency = $v.currency;
      _lines = $v.lines.toBuilder();
      _reviewReason = $v.reviewReason;
      _reviewDetails = $v.reviewDetails.toBuilder();
      _workspaceId = $v.workspaceId;
      _orderNumber = $v.orderNumber;
      _callNumber = $v.callNumber;
      _currentTotal = $v.currentTotal;
      _resolution = $v.resolution;
      _resolutionNote = $v.resolutionNote;
      _resolvedAt = $v.resolvedAt;
      _resolvedBy = $v.resolvedBy?.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSale other) {
    _$v = other as _$OfflineSale;
  }

  @override
  void update(void Function(OfflineSaleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSale build() => _build();

  _$OfflineSale _build() {
    _$OfflineSale _$result;
    try {
      _$result = _$v ??
          _$OfflineSale._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'OfflineSale', 'id'),
            offlineId: BuiltValueNullFieldError.checkNotNull(
                offlineId, r'OfflineSale', 'offlineId'),
            provisionalNumber: BuiltValueNullFieldError.checkNotNull(
                provisionalNumber, r'OfflineSale', 'provisionalNumber'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OfflineSale', 'status'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'OfflineSale', 'branchId'),
            registerId: BuiltValueNullFieldError.checkNotNull(
                registerId, r'OfflineSale', 'registerId'),
            shiftId: BuiltValueNullFieldError.checkNotNull(
                shiftId, r'OfflineSale', 'shiftId'),
            staff: staff.build(),
            clientSoldAt: BuiltValueNullFieldError.checkNotNull(
                clientSoldAt, r'OfflineSale', 'clientSoldAt'),
            clockCheck: BuiltValueNullFieldError.checkNotNull(
                clockCheck, r'OfflineSale', 'clockCheck'),
            clockSkewSeconds: BuiltValueNullFieldError.checkNotNull(
                clockSkewSeconds, r'OfflineSale', 'clockSkewSeconds'),
            collectedTotal: BuiltValueNullFieldError.checkNotNull(
                collectedTotal, r'OfflineSale', 'collectedTotal'),
            handedAmount: BuiltValueNullFieldError.checkNotNull(
                handedAmount, r'OfflineSale', 'handedAmount'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'OfflineSale', 'currency'),
            lines: lines.build(),
            reviewReason: reviewReason,
            reviewDetails: reviewDetails.build(),
            workspaceId: workspaceId,
            orderNumber: orderNumber,
            callNumber: callNumber,
            currentTotal: currentTotal,
            resolution: resolution,
            resolutionNote: resolutionNote,
            resolvedAt: resolvedAt,
            resolvedBy: _resolvedBy?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'OfflineSale', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'staff';
        staff.build();

        _$failedField = 'lines';
        lines.build();

        _$failedField = 'reviewDetails';
        reviewDetails.build();

        _$failedField = 'resolvedBy';
        _resolvedBy?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OfflineSale', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
