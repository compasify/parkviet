// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_retry200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceRetry200ResponseData
    extends PosEinvoiceRetry200ResponseData {
  @override
  final BuiltList<String> queued;
  @override
  final int skipped;

  factory _$PosEinvoiceRetry200ResponseData(
          [void Function(PosEinvoiceRetry200ResponseDataBuilder)? updates]) =>
      (PosEinvoiceRetry200ResponseDataBuilder()..update(updates))._build();

  _$PosEinvoiceRetry200ResponseData._(
      {required this.queued, required this.skipped})
      : super._();
  @override
  PosEinvoiceRetry200ResponseData rebuild(
          void Function(PosEinvoiceRetry200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceRetry200ResponseDataBuilder toBuilder() =>
      PosEinvoiceRetry200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceRetry200ResponseData &&
        queued == other.queued &&
        skipped == other.skipped;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, queued.hashCode);
    _$hash = $jc(_$hash, skipped.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosEinvoiceRetry200ResponseData')
          ..add('queued', queued)
          ..add('skipped', skipped))
        .toString();
  }
}

class PosEinvoiceRetry200ResponseDataBuilder
    implements
        Builder<PosEinvoiceRetry200ResponseData,
            PosEinvoiceRetry200ResponseDataBuilder> {
  _$PosEinvoiceRetry200ResponseData? _$v;

  ListBuilder<String>? _queued;
  ListBuilder<String> get queued => _$this._queued ??= ListBuilder<String>();
  set queued(ListBuilder<String>? queued) => _$this._queued = queued;

  int? _skipped;
  int? get skipped => _$this._skipped;
  set skipped(int? skipped) => _$this._skipped = skipped;

  PosEinvoiceRetry200ResponseDataBuilder() {
    PosEinvoiceRetry200ResponseData._defaults(this);
  }

  PosEinvoiceRetry200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _queued = $v.queued.toBuilder();
      _skipped = $v.skipped;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceRetry200ResponseData other) {
    _$v = other as _$PosEinvoiceRetry200ResponseData;
  }

  @override
  void update(void Function(PosEinvoiceRetry200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceRetry200ResponseData build() => _build();

  _$PosEinvoiceRetry200ResponseData _build() {
    _$PosEinvoiceRetry200ResponseData _$result;
    try {
      _$result = _$v ??
          _$PosEinvoiceRetry200ResponseData._(
            queued: queued.build(),
            skipped: BuiltValueNullFieldError.checkNotNull(
                skipped, r'PosEinvoiceRetry200ResponseData', 'skipped'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'queued';
        queued.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoiceRetry200ResponseData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
