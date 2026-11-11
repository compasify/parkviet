// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_workspace_cup_labels_reprint_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosWorkspaceCupLabelsReprintRequest
    extends PosWorkspaceCupLabelsReprintRequest {
  @override
  final String? saleLineId;

  factory _$PosWorkspaceCupLabelsReprintRequest(
          [void Function(PosWorkspaceCupLabelsReprintRequestBuilder)?
              updates]) =>
      (PosWorkspaceCupLabelsReprintRequestBuilder()..update(updates))._build();

  _$PosWorkspaceCupLabelsReprintRequest._({this.saleLineId}) : super._();
  @override
  PosWorkspaceCupLabelsReprintRequest rebuild(
          void Function(PosWorkspaceCupLabelsReprintRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosWorkspaceCupLabelsReprintRequestBuilder toBuilder() =>
      PosWorkspaceCupLabelsReprintRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosWorkspaceCupLabelsReprintRequest &&
        saleLineId == other.saleLineId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, saleLineId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosWorkspaceCupLabelsReprintRequest')
          ..add('saleLineId', saleLineId))
        .toString();
  }
}

class PosWorkspaceCupLabelsReprintRequestBuilder
    implements
        Builder<PosWorkspaceCupLabelsReprintRequest,
            PosWorkspaceCupLabelsReprintRequestBuilder> {
  _$PosWorkspaceCupLabelsReprintRequest? _$v;

  String? _saleLineId;
  String? get saleLineId => _$this._saleLineId;
  set saleLineId(String? saleLineId) => _$this._saleLineId = saleLineId;

  PosWorkspaceCupLabelsReprintRequestBuilder() {
    PosWorkspaceCupLabelsReprintRequest._defaults(this);
  }

  PosWorkspaceCupLabelsReprintRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _saleLineId = $v.saleLineId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosWorkspaceCupLabelsReprintRequest other) {
    _$v = other as _$PosWorkspaceCupLabelsReprintRequest;
  }

  @override
  void update(
      void Function(PosWorkspaceCupLabelsReprintRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosWorkspaceCupLabelsReprintRequest build() => _build();

  _$PosWorkspaceCupLabelsReprintRequest _build() {
    final _$result = _$v ??
        _$PosWorkspaceCupLabelsReprintRequest._(
          saleLineId: saleLineId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
