// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sale_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSaleInput extends OfflineSaleInput {
  @override
  final String offlineId;
  @override
  final String provisionalNumber;
  @override
  final String registerId;
  @override
  final String shiftId;
  @override
  final DateTime clientSoldAt;
  @override
  final DateTime? clientNow;
  @override
  final String total;
  @override
  final String handedAmount;
  @override
  final BuiltList<OfflineSaleLine> lines;

  factory _$OfflineSaleInput(
          [void Function(OfflineSaleInputBuilder)? updates]) =>
      (OfflineSaleInputBuilder()..update(updates))._build();

  _$OfflineSaleInput._(
      {required this.offlineId,
      required this.provisionalNumber,
      required this.registerId,
      required this.shiftId,
      required this.clientSoldAt,
      this.clientNow,
      required this.total,
      required this.handedAmount,
      required this.lines})
      : super._();
  @override
  OfflineSaleInput rebuild(void Function(OfflineSaleInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSaleInputBuilder toBuilder() =>
      OfflineSaleInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSaleInput &&
        offlineId == other.offlineId &&
        provisionalNumber == other.provisionalNumber &&
        registerId == other.registerId &&
        shiftId == other.shiftId &&
        clientSoldAt == other.clientSoldAt &&
        clientNow == other.clientNow &&
        total == other.total &&
        handedAmount == other.handedAmount &&
        lines == other.lines;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, offlineId.hashCode);
    _$hash = $jc(_$hash, provisionalNumber.hashCode);
    _$hash = $jc(_$hash, registerId.hashCode);
    _$hash = $jc(_$hash, shiftId.hashCode);
    _$hash = $jc(_$hash, clientSoldAt.hashCode);
    _$hash = $jc(_$hash, clientNow.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, handedAmount.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSaleInput')
          ..add('offlineId', offlineId)
          ..add('provisionalNumber', provisionalNumber)
          ..add('registerId', registerId)
          ..add('shiftId', shiftId)
          ..add('clientSoldAt', clientSoldAt)
          ..add('clientNow', clientNow)
          ..add('total', total)
          ..add('handedAmount', handedAmount)
          ..add('lines', lines))
        .toString();
  }
}

class OfflineSaleInputBuilder
    implements Builder<OfflineSaleInput, OfflineSaleInputBuilder> {
  _$OfflineSaleInput? _$v;

  String? _offlineId;
  String? get offlineId => _$this._offlineId;
  set offlineId(String? offlineId) => _$this._offlineId = offlineId;

  String? _provisionalNumber;
  String? get provisionalNumber => _$this._provisionalNumber;
  set provisionalNumber(String? provisionalNumber) =>
      _$this._provisionalNumber = provisionalNumber;

  String? _registerId;
  String? get registerId => _$this._registerId;
  set registerId(String? registerId) => _$this._registerId = registerId;

  String? _shiftId;
  String? get shiftId => _$this._shiftId;
  set shiftId(String? shiftId) => _$this._shiftId = shiftId;

  DateTime? _clientSoldAt;
  DateTime? get clientSoldAt => _$this._clientSoldAt;
  set clientSoldAt(DateTime? clientSoldAt) =>
      _$this._clientSoldAt = clientSoldAt;

  DateTime? _clientNow;
  DateTime? get clientNow => _$this._clientNow;
  set clientNow(DateTime? clientNow) => _$this._clientNow = clientNow;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  String? _handedAmount;
  String? get handedAmount => _$this._handedAmount;
  set handedAmount(String? handedAmount) => _$this._handedAmount = handedAmount;

  ListBuilder<OfflineSaleLine>? _lines;
  ListBuilder<OfflineSaleLine> get lines =>
      _$this._lines ??= ListBuilder<OfflineSaleLine>();
  set lines(ListBuilder<OfflineSaleLine>? lines) => _$this._lines = lines;

  OfflineSaleInputBuilder() {
    OfflineSaleInput._defaults(this);
  }

  OfflineSaleInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _offlineId = $v.offlineId;
      _provisionalNumber = $v.provisionalNumber;
      _registerId = $v.registerId;
      _shiftId = $v.shiftId;
      _clientSoldAt = $v.clientSoldAt;
      _clientNow = $v.clientNow;
      _total = $v.total;
      _handedAmount = $v.handedAmount;
      _lines = $v.lines.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSaleInput other) {
    _$v = other as _$OfflineSaleInput;
  }

  @override
  void update(void Function(OfflineSaleInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSaleInput build() => _build();

  _$OfflineSaleInput _build() {
    _$OfflineSaleInput _$result;
    try {
      _$result = _$v ??
          _$OfflineSaleInput._(
            offlineId: BuiltValueNullFieldError.checkNotNull(
                offlineId, r'OfflineSaleInput', 'offlineId'),
            provisionalNumber: BuiltValueNullFieldError.checkNotNull(
                provisionalNumber, r'OfflineSaleInput', 'provisionalNumber'),
            registerId: BuiltValueNullFieldError.checkNotNull(
                registerId, r'OfflineSaleInput', 'registerId'),
            shiftId: BuiltValueNullFieldError.checkNotNull(
                shiftId, r'OfflineSaleInput', 'shiftId'),
            clientSoldAt: BuiltValueNullFieldError.checkNotNull(
                clientSoldAt, r'OfflineSaleInput', 'clientSoldAt'),
            clientNow: clientNow,
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'OfflineSaleInput', 'total'),
            handedAmount: BuiltValueNullFieldError.checkNotNull(
                handedAmount, r'OfflineSaleInput', 'handedAmount'),
            lines: lines.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lines';
        lines.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OfflineSaleInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
