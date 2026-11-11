// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const EinvoiceSummaryEinvoiceTypeEnum _$einvoiceSummaryEinvoiceTypeEnum_none =
    const EinvoiceSummaryEinvoiceTypeEnum._('none');
const EinvoiceSummaryEinvoiceTypeEnum
    _$einvoiceSummaryEinvoiceTypeEnum_cashRegister =
    const EinvoiceSummaryEinvoiceTypeEnum._('cashRegister');
const EinvoiceSummaryEinvoiceTypeEnum _$einvoiceSummaryEinvoiceTypeEnum_coded =
    const EinvoiceSummaryEinvoiceTypeEnum._('coded');

EinvoiceSummaryEinvoiceTypeEnum _$einvoiceSummaryEinvoiceTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'none':
      return _$einvoiceSummaryEinvoiceTypeEnum_none;
    case 'cashRegister':
      return _$einvoiceSummaryEinvoiceTypeEnum_cashRegister;
    case 'coded':
      return _$einvoiceSummaryEinvoiceTypeEnum_coded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<EinvoiceSummaryEinvoiceTypeEnum>
    _$einvoiceSummaryEinvoiceTypeEnumValues = BuiltSet<
        EinvoiceSummaryEinvoiceTypeEnum>(const <EinvoiceSummaryEinvoiceTypeEnum>[
  _$einvoiceSummaryEinvoiceTypeEnum_none,
  _$einvoiceSummaryEinvoiceTypeEnum_cashRegister,
  _$einvoiceSummaryEinvoiceTypeEnum_coded,
]);

Serializer<EinvoiceSummaryEinvoiceTypeEnum>
    _$einvoiceSummaryEinvoiceTypeEnumSerializer =
    _$EinvoiceSummaryEinvoiceTypeEnumSerializer();

class _$EinvoiceSummaryEinvoiceTypeEnumSerializer
    implements PrimitiveSerializer<EinvoiceSummaryEinvoiceTypeEnum> {
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
  final Iterable<Type> types = const <Type>[EinvoiceSummaryEinvoiceTypeEnum];
  @override
  final String wireName = 'EinvoiceSummaryEinvoiceTypeEnum';

  @override
  Object serialize(
          Serializers serializers, EinvoiceSummaryEinvoiceTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  EinvoiceSummaryEinvoiceTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      EinvoiceSummaryEinvoiceTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$EinvoiceSummary extends EinvoiceSummary {
  @override
  final EinvoiceSummaryEinvoiceTypeEnum einvoiceType;
  @override
  final int outstanding;
  @override
  final BuiltMap<String, int> counts;
  @override
  final DateTime? oldestOutstandingAt;
  @override
  final EinvoiceSummaryRevenue revenue;

  factory _$EinvoiceSummary([void Function(EinvoiceSummaryBuilder)? updates]) =>
      (EinvoiceSummaryBuilder()..update(updates))._build();

  _$EinvoiceSummary._(
      {required this.einvoiceType,
      required this.outstanding,
      required this.counts,
      this.oldestOutstandingAt,
      required this.revenue})
      : super._();
  @override
  EinvoiceSummary rebuild(void Function(EinvoiceSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceSummaryBuilder toBuilder() => EinvoiceSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceSummary &&
        einvoiceType == other.einvoiceType &&
        outstanding == other.outstanding &&
        counts == other.counts &&
        oldestOutstandingAt == other.oldestOutstandingAt &&
        revenue == other.revenue;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, einvoiceType.hashCode);
    _$hash = $jc(_$hash, outstanding.hashCode);
    _$hash = $jc(_$hash, counts.hashCode);
    _$hash = $jc(_$hash, oldestOutstandingAt.hashCode);
    _$hash = $jc(_$hash, revenue.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceSummary')
          ..add('einvoiceType', einvoiceType)
          ..add('outstanding', outstanding)
          ..add('counts', counts)
          ..add('oldestOutstandingAt', oldestOutstandingAt)
          ..add('revenue', revenue))
        .toString();
  }
}

class EinvoiceSummaryBuilder
    implements Builder<EinvoiceSummary, EinvoiceSummaryBuilder> {
  _$EinvoiceSummary? _$v;

  EinvoiceSummaryEinvoiceTypeEnum? _einvoiceType;
  EinvoiceSummaryEinvoiceTypeEnum? get einvoiceType => _$this._einvoiceType;
  set einvoiceType(EinvoiceSummaryEinvoiceTypeEnum? einvoiceType) =>
      _$this._einvoiceType = einvoiceType;

  int? _outstanding;
  int? get outstanding => _$this._outstanding;
  set outstanding(int? outstanding) => _$this._outstanding = outstanding;

  MapBuilder<String, int>? _counts;
  MapBuilder<String, int> get counts =>
      _$this._counts ??= MapBuilder<String, int>();
  set counts(MapBuilder<String, int>? counts) => _$this._counts = counts;

  DateTime? _oldestOutstandingAt;
  DateTime? get oldestOutstandingAt => _$this._oldestOutstandingAt;
  set oldestOutstandingAt(DateTime? oldestOutstandingAt) =>
      _$this._oldestOutstandingAt = oldestOutstandingAt;

  EinvoiceSummaryRevenueBuilder? _revenue;
  EinvoiceSummaryRevenueBuilder get revenue =>
      _$this._revenue ??= EinvoiceSummaryRevenueBuilder();
  set revenue(EinvoiceSummaryRevenueBuilder? revenue) =>
      _$this._revenue = revenue;

  EinvoiceSummaryBuilder() {
    EinvoiceSummary._defaults(this);
  }

  EinvoiceSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _einvoiceType = $v.einvoiceType;
      _outstanding = $v.outstanding;
      _counts = $v.counts.toBuilder();
      _oldestOutstandingAt = $v.oldestOutstandingAt;
      _revenue = $v.revenue.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceSummary other) {
    _$v = other as _$EinvoiceSummary;
  }

  @override
  void update(void Function(EinvoiceSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceSummary build() => _build();

  _$EinvoiceSummary _build() {
    _$EinvoiceSummary _$result;
    try {
      _$result = _$v ??
          _$EinvoiceSummary._(
            einvoiceType: BuiltValueNullFieldError.checkNotNull(
                einvoiceType, r'EinvoiceSummary', 'einvoiceType'),
            outstanding: BuiltValueNullFieldError.checkNotNull(
                outstanding, r'EinvoiceSummary', 'outstanding'),
            counts: counts.build(),
            oldestOutstandingAt: oldestOutstandingAt,
            revenue: revenue.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'counts';
        counts.build();

        _$failedField = 'revenue';
        revenue.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EinvoiceSummary', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
