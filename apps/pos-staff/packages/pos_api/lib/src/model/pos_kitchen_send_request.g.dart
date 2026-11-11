// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kitchen_send_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKitchenSendRequest extends PosKitchenSendRequest {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;

  factory _$PosKitchenSendRequest(
          [void Function(PosKitchenSendRequestBuilder)? updates]) =>
      (PosKitchenSendRequestBuilder()..update(updates))._build();

  _$PosKitchenSendRequest._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId})
      : super._();
  @override
  PosKitchenSendRequest rebuild(
          void Function(PosKitchenSendRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKitchenSendRequestBuilder toBuilder() =>
      PosKitchenSendRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKitchenSendRequest &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosKitchenSendRequest')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId))
        .toString();
  }
}

class PosKitchenSendRequestBuilder
    implements Builder<PosKitchenSendRequest, PosKitchenSendRequestBuilder> {
  _$PosKitchenSendRequest? _$v;

  int? _expectedRevision;
  int? get expectedRevision => _$this._expectedRevision;
  set expectedRevision(int? expectedRevision) =>
      _$this._expectedRevision = expectedRevision;

  int? _leaseGeneration;
  int? get leaseGeneration => _$this._leaseGeneration;
  set leaseGeneration(int? leaseGeneration) =>
      _$this._leaseGeneration = leaseGeneration;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  PosKitchenSendRequestBuilder() {
    PosKitchenSendRequest._defaults(this);
  }

  PosKitchenSendRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKitchenSendRequest other) {
    _$v = other as _$PosKitchenSendRequest;
  }

  @override
  void update(void Function(PosKitchenSendRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKitchenSendRequest build() => _build();

  _$PosKitchenSendRequest _build() {
    final _$result = _$v ??
        _$PosKitchenSendRequest._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision, r'PosKitchenSendRequest', 'expectedRevision'),
          leaseGeneration: BuiltValueNullFieldError.checkNotNull(
              leaseGeneration, r'PosKitchenSendRequest', 'leaseGeneration'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'PosKitchenSendRequest', 'editorId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
