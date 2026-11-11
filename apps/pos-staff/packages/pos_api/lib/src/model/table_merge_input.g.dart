// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_merge_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableMergeInput extends TableMergeInput {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;
  @override
  final String targetWorkspaceId;

  factory _$TableMergeInput([void Function(TableMergeInputBuilder)? updates]) =>
      (TableMergeInputBuilder()..update(updates))._build();

  _$TableMergeInput._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId,
      required this.targetWorkspaceId})
      : super._();
  @override
  TableMergeInput rebuild(void Function(TableMergeInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableMergeInputBuilder toBuilder() => TableMergeInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableMergeInput &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId &&
        targetWorkspaceId == other.targetWorkspaceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, targetWorkspaceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableMergeInput')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId)
          ..add('targetWorkspaceId', targetWorkspaceId))
        .toString();
  }
}

class TableMergeInputBuilder
    implements Builder<TableMergeInput, TableMergeInputBuilder> {
  _$TableMergeInput? _$v;

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

  String? _targetWorkspaceId;
  String? get targetWorkspaceId => _$this._targetWorkspaceId;
  set targetWorkspaceId(String? targetWorkspaceId) =>
      _$this._targetWorkspaceId = targetWorkspaceId;

  TableMergeInputBuilder() {
    TableMergeInput._defaults(this);
  }

  TableMergeInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _targetWorkspaceId = $v.targetWorkspaceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableMergeInput other) {
    _$v = other as _$TableMergeInput;
  }

  @override
  void update(void Function(TableMergeInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableMergeInput build() => _build();

  _$TableMergeInput _build() {
    final _$result = _$v ??
        _$TableMergeInput._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision, r'TableMergeInput', 'expectedRevision'),
          leaseGeneration: BuiltValueNullFieldError.checkNotNull(
              leaseGeneration, r'TableMergeInput', 'leaseGeneration'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'TableMergeInput', 'editorId'),
          targetWorkspaceId: BuiltValueNullFieldError.checkNotNull(
              targetWorkspaceId, r'TableMergeInput', 'targetWorkspaceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
