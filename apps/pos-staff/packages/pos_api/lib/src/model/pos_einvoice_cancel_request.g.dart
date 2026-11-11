// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_cancel_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosEinvoiceCancelRequest extends PosEinvoiceCancelRequest {
  @override
  final String reason;

  factory _$PosEinvoiceCancelRequest(
          [void Function(PosEinvoiceCancelRequestBuilder)? updates]) =>
      (PosEinvoiceCancelRequestBuilder()..update(updates))._build();

  _$PosEinvoiceCancelRequest._({required this.reason}) : super._();
  @override
  PosEinvoiceCancelRequest rebuild(
          void Function(PosEinvoiceCancelRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceCancelRequestBuilder toBuilder() =>
      PosEinvoiceCancelRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceCancelRequest && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosEinvoiceCancelRequest')
          ..add('reason', reason))
        .toString();
  }
}

class PosEinvoiceCancelRequestBuilder
    implements
        Builder<PosEinvoiceCancelRequest, PosEinvoiceCancelRequestBuilder> {
  _$PosEinvoiceCancelRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PosEinvoiceCancelRequestBuilder() {
    PosEinvoiceCancelRequest._defaults(this);
  }

  PosEinvoiceCancelRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceCancelRequest other) {
    _$v = other as _$PosEinvoiceCancelRequest;
  }

  @override
  void update(void Function(PosEinvoiceCancelRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceCancelRequest build() => _build();

  _$PosEinvoiceCancelRequest _build() {
    final _$result = _$v ??
        _$PosEinvoiceCancelRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PosEinvoiceCancelRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
