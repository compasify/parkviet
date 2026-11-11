// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_sample.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EinvoiceSample extends EinvoiceSample {
  @override
  final String provider;
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

  factory _$EinvoiceSample([void Function(EinvoiceSampleBuilder)? updates]) =>
      (EinvoiceSampleBuilder()..update(updates))._build();

  _$EinvoiceSample._(
      {required this.provider,
      this.templateCode,
      this.symbol,
      this.number,
      this.cqtCode,
      this.lookupCode})
      : super._();
  @override
  EinvoiceSample rebuild(void Function(EinvoiceSampleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceSampleBuilder toBuilder() => EinvoiceSampleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceSample &&
        provider == other.provider &&
        templateCode == other.templateCode &&
        symbol == other.symbol &&
        number == other.number &&
        cqtCode == other.cqtCode &&
        lookupCode == other.lookupCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, templateCode.hashCode);
    _$hash = $jc(_$hash, symbol.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jc(_$hash, cqtCode.hashCode);
    _$hash = $jc(_$hash, lookupCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceSample')
          ..add('provider', provider)
          ..add('templateCode', templateCode)
          ..add('symbol', symbol)
          ..add('number', number)
          ..add('cqtCode', cqtCode)
          ..add('lookupCode', lookupCode))
        .toString();
  }
}

class EinvoiceSampleBuilder
    implements Builder<EinvoiceSample, EinvoiceSampleBuilder> {
  _$EinvoiceSample? _$v;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

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

  EinvoiceSampleBuilder() {
    EinvoiceSample._defaults(this);
  }

  EinvoiceSampleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _provider = $v.provider;
      _templateCode = $v.templateCode;
      _symbol = $v.symbol;
      _number = $v.number;
      _cqtCode = $v.cqtCode;
      _lookupCode = $v.lookupCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceSample other) {
    _$v = other as _$EinvoiceSample;
  }

  @override
  void update(void Function(EinvoiceSampleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceSample build() => _build();

  _$EinvoiceSample _build() {
    final _$result = _$v ??
        _$EinvoiceSample._(
          provider: BuiltValueNullFieldError.checkNotNull(
              provider, r'EinvoiceSample', 'provider'),
          templateCode: templateCode,
          symbol: symbol,
          number: number,
          cqtCode: cqtCode,
          lookupCode: lookupCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
