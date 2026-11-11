// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_report_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlatformReportRowPlatformEnum _$platformReportRowPlatformEnum_grabfood =
    const PlatformReportRowPlatformEnum._('grabfood');
const PlatformReportRowPlatformEnum _$platformReportRowPlatformEnum_shopeefood =
    const PlatformReportRowPlatformEnum._('shopeefood');

PlatformReportRowPlatformEnum _$platformReportRowPlatformEnumValueOf(
    String name) {
  switch (name) {
    case 'grabfood':
      return _$platformReportRowPlatformEnum_grabfood;
    case 'shopeefood':
      return _$platformReportRowPlatformEnum_shopeefood;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlatformReportRowPlatformEnum>
    _$platformReportRowPlatformEnumValues = BuiltSet<
        PlatformReportRowPlatformEnum>(const <PlatformReportRowPlatformEnum>[
  _$platformReportRowPlatformEnum_grabfood,
  _$platformReportRowPlatformEnum_shopeefood,
]);

Serializer<PlatformReportRowPlatformEnum>
    _$platformReportRowPlatformEnumSerializer =
    _$PlatformReportRowPlatformEnumSerializer();

class _$PlatformReportRowPlatformEnumSerializer
    implements PrimitiveSerializer<PlatformReportRowPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };

  @override
  final Iterable<Type> types = const <Type>[PlatformReportRowPlatformEnum];
  @override
  final String wireName = 'PlatformReportRowPlatformEnum';

  @override
  Object serialize(
          Serializers serializers, PlatformReportRowPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlatformReportRowPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlatformReportRowPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlatformReportRow extends PlatformReportRow {
  @override
  final Date businessDate;
  @override
  final PlatformReportRowPlatformEnum platform;
  @override
  final int orders;
  @override
  final String gross;
  @override
  final String commission;
  @override
  final String net;
  @override
  final String unsettled;
  @override
  final String commissionEstimated;
  @override
  final String commissionActual;

  factory _$PlatformReportRow(
          [void Function(PlatformReportRowBuilder)? updates]) =>
      (PlatformReportRowBuilder()..update(updates))._build();

  _$PlatformReportRow._(
      {required this.businessDate,
      required this.platform,
      required this.orders,
      required this.gross,
      required this.commission,
      required this.net,
      required this.unsettled,
      required this.commissionEstimated,
      required this.commissionActual})
      : super._();
  @override
  PlatformReportRow rebuild(void Function(PlatformReportRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformReportRowBuilder toBuilder() =>
      PlatformReportRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformReportRow &&
        businessDate == other.businessDate &&
        platform == other.platform &&
        orders == other.orders &&
        gross == other.gross &&
        commission == other.commission &&
        net == other.net &&
        unsettled == other.unsettled &&
        commissionEstimated == other.commissionEstimated &&
        commissionActual == other.commissionActual;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, orders.hashCode);
    _$hash = $jc(_$hash, gross.hashCode);
    _$hash = $jc(_$hash, commission.hashCode);
    _$hash = $jc(_$hash, net.hashCode);
    _$hash = $jc(_$hash, unsettled.hashCode);
    _$hash = $jc(_$hash, commissionEstimated.hashCode);
    _$hash = $jc(_$hash, commissionActual.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformReportRow')
          ..add('businessDate', businessDate)
          ..add('platform', platform)
          ..add('orders', orders)
          ..add('gross', gross)
          ..add('commission', commission)
          ..add('net', net)
          ..add('unsettled', unsettled)
          ..add('commissionEstimated', commissionEstimated)
          ..add('commissionActual', commissionActual))
        .toString();
  }
}

class PlatformReportRowBuilder
    implements Builder<PlatformReportRow, PlatformReportRowBuilder> {
  _$PlatformReportRow? _$v;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  PlatformReportRowPlatformEnum? _platform;
  PlatformReportRowPlatformEnum? get platform => _$this._platform;
  set platform(PlatformReportRowPlatformEnum? platform) =>
      _$this._platform = platform;

  int? _orders;
  int? get orders => _$this._orders;
  set orders(int? orders) => _$this._orders = orders;

  String? _gross;
  String? get gross => _$this._gross;
  set gross(String? gross) => _$this._gross = gross;

  String? _commission;
  String? get commission => _$this._commission;
  set commission(String? commission) => _$this._commission = commission;

  String? _net;
  String? get net => _$this._net;
  set net(String? net) => _$this._net = net;

  String? _unsettled;
  String? get unsettled => _$this._unsettled;
  set unsettled(String? unsettled) => _$this._unsettled = unsettled;

  String? _commissionEstimated;
  String? get commissionEstimated => _$this._commissionEstimated;
  set commissionEstimated(String? commissionEstimated) =>
      _$this._commissionEstimated = commissionEstimated;

  String? _commissionActual;
  String? get commissionActual => _$this._commissionActual;
  set commissionActual(String? commissionActual) =>
      _$this._commissionActual = commissionActual;

  PlatformReportRowBuilder() {
    PlatformReportRow._defaults(this);
  }

  PlatformReportRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _businessDate = $v.businessDate;
      _platform = $v.platform;
      _orders = $v.orders;
      _gross = $v.gross;
      _commission = $v.commission;
      _net = $v.net;
      _unsettled = $v.unsettled;
      _commissionEstimated = $v.commissionEstimated;
      _commissionActual = $v.commissionActual;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformReportRow other) {
    _$v = other as _$PlatformReportRow;
  }

  @override
  void update(void Function(PlatformReportRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformReportRow build() => _build();

  _$PlatformReportRow _build() {
    final _$result = _$v ??
        _$PlatformReportRow._(
          businessDate: BuiltValueNullFieldError.checkNotNull(
              businessDate, r'PlatformReportRow', 'businessDate'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'PlatformReportRow', 'platform'),
          orders: BuiltValueNullFieldError.checkNotNull(
              orders, r'PlatformReportRow', 'orders'),
          gross: BuiltValueNullFieldError.checkNotNull(
              gross, r'PlatformReportRow', 'gross'),
          commission: BuiltValueNullFieldError.checkNotNull(
              commission, r'PlatformReportRow', 'commission'),
          net: BuiltValueNullFieldError.checkNotNull(
              net, r'PlatformReportRow', 'net'),
          unsettled: BuiltValueNullFieldError.checkNotNull(
              unsettled, r'PlatformReportRow', 'unsettled'),
          commissionEstimated: BuiltValueNullFieldError.checkNotNull(
              commissionEstimated, r'PlatformReportRow', 'commissionEstimated'),
          commissionActual: BuiltValueNullFieldError.checkNotNull(
              commissionActual, r'PlatformReportRow', 'commissionActual'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
