// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_sample_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceSampleRequest extends PosEinvoiceSampleRequest {
  @override
  final String? branchId;

  factory _$PosEinvoiceSampleRequest(
          [void Function(PosEinvoiceSampleRequestBuilder)? updates]) =>
      (PosEinvoiceSampleRequestBuilder()..update(updates))._build();

  _$PosEinvoiceSampleRequest._({this.branchId}) : super._();
  @override
  PosEinvoiceSampleRequest rebuild(
          void Function(PosEinvoiceSampleRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceSampleRequestBuilder toBuilder() =>
      PosEinvoiceSampleRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceSampleRequest && branchId == other.branchId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosEinvoiceSampleRequest')
          ..add('branchId', branchId))
        .toString();
  }
}

class PosEinvoiceSampleRequestBuilder
    implements
        Builder<PosEinvoiceSampleRequest, PosEinvoiceSampleRequestBuilder> {
  _$PosEinvoiceSampleRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  PosEinvoiceSampleRequestBuilder() {
    PosEinvoiceSampleRequest._defaults(this);
  }

  PosEinvoiceSampleRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceSampleRequest other) {
    _$v = other as _$PosEinvoiceSampleRequest;
  }

  @override
  void update(void Function(PosEinvoiceSampleRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceSampleRequest build() => _build();

  _$PosEinvoiceSampleRequest _build() {
    final _$result = _$v ??
        _$PosEinvoiceSampleRequest._(
          branchId: branchId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
