// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_retry_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceRetryRequest extends PosEinvoiceRetryRequest {
  @override
  final BuiltList<String>? ids;
  @override
  final String? branchId;

  factory _$PosEinvoiceRetryRequest(
          [void Function(PosEinvoiceRetryRequestBuilder)? updates]) =>
      (PosEinvoiceRetryRequestBuilder()..update(updates))._build();

  _$PosEinvoiceRetryRequest._({this.ids, this.branchId}) : super._();
  @override
  PosEinvoiceRetryRequest rebuild(
          void Function(PosEinvoiceRetryRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceRetryRequestBuilder toBuilder() =>
      PosEinvoiceRetryRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceRetryRequest &&
        ids == other.ids &&
        branchId == other.branchId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ids.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosEinvoiceRetryRequest')
          ..add('ids', ids)
          ..add('branchId', branchId))
        .toString();
  }
}

class PosEinvoiceRetryRequestBuilder
    implements
        Builder<PosEinvoiceRetryRequest, PosEinvoiceRetryRequestBuilder> {
  _$PosEinvoiceRetryRequest? _$v;

  ListBuilder<String>? _ids;
  ListBuilder<String> get ids => _$this._ids ??= ListBuilder<String>();
  set ids(ListBuilder<String>? ids) => _$this._ids = ids;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  PosEinvoiceRetryRequestBuilder() {
    PosEinvoiceRetryRequest._defaults(this);
  }

  PosEinvoiceRetryRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ids = $v.ids?.toBuilder();
      _branchId = $v.branchId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceRetryRequest other) {
    _$v = other as _$PosEinvoiceRetryRequest;
  }

  @override
  void update(void Function(PosEinvoiceRetryRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceRetryRequest build() => _build();

  _$PosEinvoiceRetryRequest _build() {
    _$PosEinvoiceRetryRequest _$result;
    try {
      _$result = _$v ??
          _$PosEinvoiceRetryRequest._(
            ids: _ids?.build(),
            branchId: branchId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ids';
        _ids?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoiceRetryRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
