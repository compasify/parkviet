// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_replace_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceReplaceRequest extends PosEinvoiceReplaceRequest {
  @override
  final EinvoiceBuyer buyer;
  @override
  final String reason;

  factory _$PosEinvoiceReplaceRequest(
          [void Function(PosEinvoiceReplaceRequestBuilder)? updates]) =>
      (PosEinvoiceReplaceRequestBuilder()..update(updates))._build();

  _$PosEinvoiceReplaceRequest._({required this.buyer, required this.reason})
      : super._();
  @override
  PosEinvoiceReplaceRequest rebuild(
          void Function(PosEinvoiceReplaceRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceReplaceRequestBuilder toBuilder() =>
      PosEinvoiceReplaceRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceReplaceRequest &&
        buyer == other.buyer &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, buyer.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosEinvoiceReplaceRequest')
          ..add('buyer', buyer)
          ..add('reason', reason))
        .toString();
  }
}

class PosEinvoiceReplaceRequestBuilder
    implements
        Builder<PosEinvoiceReplaceRequest, PosEinvoiceReplaceRequestBuilder> {
  _$PosEinvoiceReplaceRequest? _$v;

  EinvoiceBuyerBuilder? _buyer;
  EinvoiceBuyerBuilder get buyer => _$this._buyer ??= EinvoiceBuyerBuilder();
  set buyer(EinvoiceBuyerBuilder? buyer) => _$this._buyer = buyer;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PosEinvoiceReplaceRequestBuilder() {
    PosEinvoiceReplaceRequest._defaults(this);
  }

  PosEinvoiceReplaceRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _buyer = $v.buyer.toBuilder();
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceReplaceRequest other) {
    _$v = other as _$PosEinvoiceReplaceRequest;
  }

  @override
  void update(void Function(PosEinvoiceReplaceRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceReplaceRequest build() => _build();

  _$PosEinvoiceReplaceRequest _build() {
    _$PosEinvoiceReplaceRequest _$result;
    try {
      _$result = _$v ??
          _$PosEinvoiceReplaceRequest._(
            buyer: buyer.build(),
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'PosEinvoiceReplaceRequest', 'reason'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'buyer';
        buyer.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoiceReplaceRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
