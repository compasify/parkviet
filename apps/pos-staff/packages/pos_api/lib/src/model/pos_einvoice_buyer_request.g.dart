// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_buyer_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceBuyerRequest extends PosEinvoiceBuyerRequest {
  @override
  final EinvoiceBuyer buyer;

  factory _$PosEinvoiceBuyerRequest(
          [void Function(PosEinvoiceBuyerRequestBuilder)? updates]) =>
      (PosEinvoiceBuyerRequestBuilder()..update(updates))._build();

  _$PosEinvoiceBuyerRequest._({required this.buyer}) : super._();
  @override
  PosEinvoiceBuyerRequest rebuild(
          void Function(PosEinvoiceBuyerRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceBuyerRequestBuilder toBuilder() =>
      PosEinvoiceBuyerRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceBuyerRequest && buyer == other.buyer;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, buyer.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosEinvoiceBuyerRequest')
          ..add('buyer', buyer))
        .toString();
  }
}

class PosEinvoiceBuyerRequestBuilder
    implements
        Builder<PosEinvoiceBuyerRequest, PosEinvoiceBuyerRequestBuilder> {
  _$PosEinvoiceBuyerRequest? _$v;

  EinvoiceBuyerBuilder? _buyer;
  EinvoiceBuyerBuilder get buyer => _$this._buyer ??= EinvoiceBuyerBuilder();
  set buyer(EinvoiceBuyerBuilder? buyer) => _$this._buyer = buyer;

  PosEinvoiceBuyerRequestBuilder() {
    PosEinvoiceBuyerRequest._defaults(this);
  }

  PosEinvoiceBuyerRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _buyer = $v.buyer.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceBuyerRequest other) {
    _$v = other as _$PosEinvoiceBuyerRequest;
  }

  @override
  void update(void Function(PosEinvoiceBuyerRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceBuyerRequest build() => _build();

  _$PosEinvoiceBuyerRequest _build() {
    _$PosEinvoiceBuyerRequest _$result;
    try {
      _$result = _$v ??
          _$PosEinvoiceBuyerRequest._(
            buyer: buyer.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'buyer';
        buyer.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoiceBuyerRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
