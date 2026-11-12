// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_vehicle_visit_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceVehicleVisitInput extends WorkspaceVehicleVisitInput {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;
  @override
  final String? visitId;

  factory _$WorkspaceVehicleVisitInput(
          [void Function(WorkspaceVehicleVisitInputBuilder)? updates]) =>
      (WorkspaceVehicleVisitInputBuilder()..update(updates))._build();

  _$WorkspaceVehicleVisitInput._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId,
      this.visitId})
      : super._();
  @override
  WorkspaceVehicleVisitInput rebuild(
          void Function(WorkspaceVehicleVisitInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceVehicleVisitInputBuilder toBuilder() =>
      WorkspaceVehicleVisitInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceVehicleVisitInput &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId &&
        visitId == other.visitId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, visitId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceVehicleVisitInput')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId)
          ..add('visitId', visitId))
        .toString();
  }
}

class WorkspaceVehicleVisitInputBuilder
    implements
        Builder<WorkspaceVehicleVisitInput, WorkspaceVehicleVisitInputBuilder> {
  _$WorkspaceVehicleVisitInput? _$v;

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

  String? _visitId;
  String? get visitId => _$this._visitId;
  set visitId(String? visitId) => _$this._visitId = visitId;

  WorkspaceVehicleVisitInputBuilder() {
    WorkspaceVehicleVisitInput._defaults(this);
  }

  WorkspaceVehicleVisitInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _visitId = $v.visitId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceVehicleVisitInput other) {
    _$v = other as _$WorkspaceVehicleVisitInput;
  }

  @override
  void update(void Function(WorkspaceVehicleVisitInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceVehicleVisitInput build() => _build();

  _$WorkspaceVehicleVisitInput _build() {
    final _$result = _$v ??
        _$WorkspaceVehicleVisitInput._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision,
              r'WorkspaceVehicleVisitInput',
              'expectedRevision'),
          leaseGeneration: BuiltValueNullFieldError.checkNotNull(
              leaseGeneration,
              r'WorkspaceVehicleVisitInput',
              'leaseGeneration'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'WorkspaceVehicleVisitInput', 'editorId'),
          visitId: visitId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
