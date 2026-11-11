// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_summary_revenue.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EinvoiceSummaryRevenueLevelEnum _$einvoiceSummaryRevenueLevelEnum_ok =
    const EinvoiceSummaryRevenueLevelEnum._('ok');
const EinvoiceSummaryRevenueLevelEnum
    _$einvoiceSummaryRevenueLevelEnum_warning =
    const EinvoiceSummaryRevenueLevelEnum._('warning');
const EinvoiceSummaryRevenueLevelEnum
    _$einvoiceSummaryRevenueLevelEnum_reached =
    const EinvoiceSummaryRevenueLevelEnum._('reached');

EinvoiceSummaryRevenueLevelEnum _$einvoiceSummaryRevenueLevelEnumValueOf(
    String name) {
  switch (name) {
    case 'ok':
      return _$einvoiceSummaryRevenueLevelEnum_ok;
    case 'warning':
      return _$einvoiceSummaryRevenueLevelEnum_warning;
    case 'reached':
      return _$einvoiceSummaryRevenueLevelEnum_reached;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoiceSummaryRevenueLevelEnum>
    _$einvoiceSummaryRevenueLevelEnumValues = BuiltSet<
        EinvoiceSummaryRevenueLevelEnum>(const <EinvoiceSummaryRevenueLevelEnum>[
  _$einvoiceSummaryRevenueLevelEnum_ok,
  _$einvoiceSummaryRevenueLevelEnum_warning,
  _$einvoiceSummaryRevenueLevelEnum_reached,
]);

Serializer<EinvoiceSummaryRevenueLevelEnum>
    _$einvoiceSummaryRevenueLevelEnumSerializer =
    _$EinvoiceSummaryRevenueLevelEnumSerializer();

class _$EinvoiceSummaryRevenueLevelEnumSerializer
    implements PrimitiveSerializer<EinvoiceSummaryRevenueLevelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'warning': 'warning',
    'reached': 'reached',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'warning': 'warning',
    'reached': 'reached',
  };

  @override
  final Iterable<Type> types = const <Type>[EinvoiceSummaryRevenueLevelEnum];
  @override
  final String wireName = 'EinvoiceSummaryRevenueLevelEnum';

  @override
  Object serialize(
          Serializers serializers, EinvoiceSummaryRevenueLevelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoiceSummaryRevenueLevelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoiceSummaryRevenueLevelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EinvoiceSummaryRevenue extends EinvoiceSummaryRevenue {
  @override
  final int year;
  @override
  final String total;
  @override
  final String threshold;
  @override
  final String share;
  @override
  final EinvoiceSummaryRevenueLevelEnum level;

  factory _$EinvoiceSummaryRevenue(
          [void Function(EinvoiceSummaryRevenueBuilder)? updates]) =>
      (EinvoiceSummaryRevenueBuilder()..update(updates))._build();

  _$EinvoiceSummaryRevenue._(
      {required this.year,
      required this.total,
      required this.threshold,
      required this.share,
      required this.level})
      : super._();
  @override
  EinvoiceSummaryRevenue rebuild(
          void Function(EinvoiceSummaryRevenueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceSummaryRevenueBuilder toBuilder() =>
      EinvoiceSummaryRevenueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceSummaryRevenue &&
        year == other.year &&
        total == other.total &&
        threshold == other.threshold &&
        share == other.share &&
        level == other.level;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, year.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, threshold.hashCode);
    _$hash = $jc(_$hash, share.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceSummaryRevenue')
          ..add('year', year)
          ..add('total', total)
          ..add('threshold', threshold)
          ..add('share', share)
          ..add('level', level))
        .toString();
  }
}

class EinvoiceSummaryRevenueBuilder
    implements Builder<EinvoiceSummaryRevenue, EinvoiceSummaryRevenueBuilder> {
  _$EinvoiceSummaryRevenue? _$v;

  int? _year;
  int? get year => _$this._year;
  set year(int? year) => _$this._year = year;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  String? _threshold;
  String? get threshold => _$this._threshold;
  set threshold(String? threshold) => _$this._threshold = threshold;

  String? _share;
  String? get share => _$this._share;
  set share(String? share) => _$this._share = share;

  EinvoiceSummaryRevenueLevelEnum? _level;
  EinvoiceSummaryRevenueLevelEnum? get level => _$this._level;
  set level(EinvoiceSummaryRevenueLevelEnum? level) => _$this._level = level;

  EinvoiceSummaryRevenueBuilder() {
    EinvoiceSummaryRevenue._defaults(this);
  }

  EinvoiceSummaryRevenueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _year = $v.year;
      _total = $v.total;
      _threshold = $v.threshold;
      _share = $v.share;
      _level = $v.level;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceSummaryRevenue other) {
    _$v = other as _$EinvoiceSummaryRevenue;
  }

  @override
  void update(void Function(EinvoiceSummaryRevenueBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceSummaryRevenue build() => _build();

  _$EinvoiceSummaryRevenue _build() {
    final _$result = _$v ??
        _$EinvoiceSummaryRevenue._(
          year: BuiltValueNullFieldError.checkNotNull(
              year, r'EinvoiceSummaryRevenue', 'year'),
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'EinvoiceSummaryRevenue', 'total'),
          threshold: BuiltValueNullFieldError.checkNotNull(
              threshold, r'EinvoiceSummaryRevenue', 'threshold'),
          share: BuiltValueNullFieldError.checkNotNull(
              share, r'EinvoiceSummaryRevenue', 'share'),
          level: BuiltValueNullFieldError.checkNotNull(
              level, r'EinvoiceSummaryRevenue', 'level'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
