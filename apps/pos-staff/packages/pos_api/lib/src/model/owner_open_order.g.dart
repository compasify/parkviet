// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_open_order.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OwnerOpenOrderStatusEnum _$ownerOpenOrderStatusEnum_editing =
    const OwnerOpenOrderStatusEnum._('editing');
const OwnerOpenOrderStatusEnum _$ownerOpenOrderStatusEnum_parked =
    const OwnerOpenOrderStatusEnum._('parked');

OwnerOpenOrderStatusEnum _$ownerOpenOrderStatusEnumValueOf(String name) {
  switch (name) {
    case 'editing':
      return _$ownerOpenOrderStatusEnum_editing;
    case 'parked':
      return _$ownerOpenOrderStatusEnum_parked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OwnerOpenOrderStatusEnum> _$ownerOpenOrderStatusEnumValues =
    BuiltSet<OwnerOpenOrderStatusEnum>(const <OwnerOpenOrderStatusEnum>[
  _$ownerOpenOrderStatusEnum_editing,
  _$ownerOpenOrderStatusEnum_parked,
]);

Serializer<OwnerOpenOrderStatusEnum> _$ownerOpenOrderStatusEnumSerializer =
    _$OwnerOpenOrderStatusEnumSerializer();

class _$OwnerOpenOrderStatusEnumSerializer
    implements PrimitiveSerializer<OwnerOpenOrderStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'editing': 'editing',
    'parked': 'parked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'editing': 'editing',
    'parked': 'parked',
  };

  @override
  final Iterable<Type> types = const <Type>[OwnerOpenOrderStatusEnum];
  @override
  final String wireName = 'OwnerOpenOrderStatusEnum';

  @override
  Object serialize(Serializers serializers, OwnerOpenOrderStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OwnerOpenOrderStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OwnerOpenOrderStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OwnerOpenOrder extends OwnerOpenOrder {
  @override
  final String workspaceId;
  @override
  final String? label;
  @override
  final String? orderNumber;
  @override
  final String orderSource;
  @override
  final String? serviceMode;
  @override
  final OwnerOpenOrderStatusEnum status;
  @override
  final int? guestCount;
  @override
  final DateTime openedAt;
  @override
  final int minutesOpen;
  @override
  final String total;
  @override
  final String currency;
  @override
  final BuiltList<OwnerOpenOrderLine> lines;

  factory _$OwnerOpenOrder([void Function(OwnerOpenOrderBuilder)? updates]) =>
      (OwnerOpenOrderBuilder()..update(updates))._build();

  _$OwnerOpenOrder._(
      {required this.workspaceId,
      this.label,
      this.orderNumber,
      required this.orderSource,
      this.serviceMode,
      required this.status,
      this.guestCount,
      required this.openedAt,
      required this.minutesOpen,
      required this.total,
      required this.currency,
      required this.lines})
      : super._();
  @override
  OwnerOpenOrder rebuild(void Function(OwnerOpenOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerOpenOrderBuilder toBuilder() => OwnerOpenOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerOpenOrder &&
        workspaceId == other.workspaceId &&
        label == other.label &&
        orderNumber == other.orderNumber &&
        orderSource == other.orderSource &&
        serviceMode == other.serviceMode &&
        status == other.status &&
        guestCount == other.guestCount &&
        openedAt == other.openedAt &&
        minutesOpen == other.minutesOpen &&
        total == other.total &&
        currency == other.currency &&
        lines == other.lines;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, orderNumber.hashCode);
    _$hash = $jc(_$hash, orderSource.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jc(_$hash, openedAt.hashCode);
    _$hash = $jc(_$hash, minutesOpen.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnerOpenOrder')
          ..add('workspaceId', workspaceId)
          ..add('label', label)
          ..add('orderNumber', orderNumber)
          ..add('orderSource', orderSource)
          ..add('serviceMode', serviceMode)
          ..add('status', status)
          ..add('guestCount', guestCount)
          ..add('openedAt', openedAt)
          ..add('minutesOpen', minutesOpen)
          ..add('total', total)
          ..add('currency', currency)
          ..add('lines', lines))
        .toString();
  }
}

class OwnerOpenOrderBuilder
    implements Builder<OwnerOpenOrder, OwnerOpenOrderBuilder> {
  _$OwnerOpenOrder? _$v;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _orderNumber;
  String? get orderNumber => _$this._orderNumber;
  set orderNumber(String? orderNumber) => _$this._orderNumber = orderNumber;

  String? _orderSource;
  String? get orderSource => _$this._orderSource;
  set orderSource(String? orderSource) => _$this._orderSource = orderSource;

  String? _serviceMode;
  String? get serviceMode => _$this._serviceMode;
  set serviceMode(String? serviceMode) => _$this._serviceMode = serviceMode;

  OwnerOpenOrderStatusEnum? _status;
  OwnerOpenOrderStatusEnum? get status => _$this._status;
  set status(OwnerOpenOrderStatusEnum? status) => _$this._status = status;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  DateTime? _openedAt;
  DateTime? get openedAt => _$this._openedAt;
  set openedAt(DateTime? openedAt) => _$this._openedAt = openedAt;

  int? _minutesOpen;
  int? get minutesOpen => _$this._minutesOpen;
  set minutesOpen(int? minutesOpen) => _$this._minutesOpen = minutesOpen;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  ListBuilder<OwnerOpenOrderLine>? _lines;
  ListBuilder<OwnerOpenOrderLine> get lines =>
      _$this._lines ??= ListBuilder<OwnerOpenOrderLine>();
  set lines(ListBuilder<OwnerOpenOrderLine>? lines) => _$this._lines = lines;

  OwnerOpenOrderBuilder() {
    OwnerOpenOrder._defaults(this);
  }

  OwnerOpenOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspaceId = $v.workspaceId;
      _label = $v.label;
      _orderNumber = $v.orderNumber;
      _orderSource = $v.orderSource;
      _serviceMode = $v.serviceMode;
      _status = $v.status;
      _guestCount = $v.guestCount;
      _openedAt = $v.openedAt;
      _minutesOpen = $v.minutesOpen;
      _total = $v.total;
      _currency = $v.currency;
      _lines = $v.lines.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerOpenOrder other) {
    _$v = other as _$OwnerOpenOrder;
  }

  @override
  void update(void Function(OwnerOpenOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerOpenOrder build() => _build();

  _$OwnerOpenOrder _build() {
    _$OwnerOpenOrder _$result;
    try {
      _$result = _$v ??
          _$OwnerOpenOrder._(
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'OwnerOpenOrder', 'workspaceId'),
            label: label,
            orderNumber: orderNumber,
            orderSource: BuiltValueNullFieldError.checkNotNull(
                orderSource, r'OwnerOpenOrder', 'orderSource'),
            serviceMode: serviceMode,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OwnerOpenOrder', 'status'),
            guestCount: guestCount,
            openedAt: BuiltValueNullFieldError.checkNotNull(
                openedAt, r'OwnerOpenOrder', 'openedAt'),
            minutesOpen: BuiltValueNullFieldError.checkNotNull(
                minutesOpen, r'OwnerOpenOrder', 'minutesOpen'),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'OwnerOpenOrder', 'total'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'OwnerOpenOrder', 'currency'),
            lines: lines.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lines';
        lines.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OwnerOpenOrder', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
