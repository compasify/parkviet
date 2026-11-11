// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_print_job_reprint_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrintJobReprintRequest extends PosPrintJobReprintRequest {
  @override
  final String? approvalId;

  factory _$PosPrintJobReprintRequest(
          [void Function(PosPrintJobReprintRequestBuilder)? updates]) =>
      (PosPrintJobReprintRequestBuilder()..update(updates))._build();

  _$PosPrintJobReprintRequest._({this.approvalId}) : super._();
  @override
  PosPrintJobReprintRequest rebuild(
          void Function(PosPrintJobReprintRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrintJobReprintRequestBuilder toBuilder() =>
      PosPrintJobReprintRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrintJobReprintRequest && approvalId == other.approvalId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosPrintJobReprintRequest')
          ..add('approvalId', approvalId))
        .toString();
  }
}

class PosPrintJobReprintRequestBuilder
    implements
        Builder<PosPrintJobReprintRequest, PosPrintJobReprintRequestBuilder> {
  _$PosPrintJobReprintRequest? _$v;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  PosPrintJobReprintRequestBuilder() {
    PosPrintJobReprintRequest._defaults(this);
  }

  PosPrintJobReprintRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _approvalId = $v.approvalId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrintJobReprintRequest other) {
    _$v = other as _$PosPrintJobReprintRequest;
  }

  @override
  void update(void Function(PosPrintJobReprintRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrintJobReprintRequest build() => _build();

  _$PosPrintJobReprintRequest _build() {
    final _$result = _$v ??
        _$PosPrintJobReprintRequest._(
          approvalId: approvalId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
