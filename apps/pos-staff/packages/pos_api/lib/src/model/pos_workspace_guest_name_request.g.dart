// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_workspace_guest_name_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosWorkspaceGuestNameRequest extends PosWorkspaceGuestNameRequest {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;
  @override
  final String? guestName;

  factory _$PosWorkspaceGuestNameRequest(
          [void Function(PosWorkspaceGuestNameRequestBuilder)? updates]) =>
      (PosWorkspaceGuestNameRequestBuilder()..update(updates))._build();

  _$PosWorkspaceGuestNameRequest._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId,
      this.guestName})
      : super._();
  @override
  PosWorkspaceGuestNameRequest rebuild(
          void Function(PosWorkspaceGuestNameRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosWorkspaceGuestNameRequestBuilder toBuilder() =>
      PosWorkspaceGuestNameRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosWorkspaceGuestNameRequest &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId &&
        guestName == other.guestName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, guestName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosWorkspaceGuestNameRequest')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId)
          ..add('guestName', guestName))
        .toString();
  }
}

class PosWorkspaceGuestNameRequestBuilder
    implements
        Builder<PosWorkspaceGuestNameRequest,
            PosWorkspaceGuestNameRequestBuilder> {
  _$PosWorkspaceGuestNameRequest? _$v;

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

  String? _guestName;
  String? get guestName => _$this._guestName;
  set guestName(String? guestName) => _$this._guestName = guestName;

  PosWorkspaceGuestNameRequestBuilder() {
    PosWorkspaceGuestNameRequest._defaults(this);
  }

  PosWorkspaceGuestNameRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _guestName = $v.guestName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosWorkspaceGuestNameRequest other) {
    _$v = other as _$PosWorkspaceGuestNameRequest;
  }

  @override
  void update(void Function(PosWorkspaceGuestNameRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosWorkspaceGuestNameRequest build() => _build();

  _$PosWorkspaceGuestNameRequest _build() {
    final _$result = _$v ??
        _$PosWorkspaceGuestNameRequest._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision,
              r'PosWorkspaceGuestNameRequest',
              'expectedRevision'),
          leaseGeneration: BuiltValueNullFieldError.checkNotNull(
              leaseGeneration,
              r'PosWorkspaceGuestNameRequest',
              'leaseGeneration'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'PosWorkspaceGuestNameRequest', 'editorId'),
          guestName: guestName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
