// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_move_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableMoveInput extends TableMoveInput {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;
  @override
  final String resourceId;

  factory _$TableMoveInput([void Function(TableMoveInputBuilder)? updates]) =>
      (TableMoveInputBuilder()..update(updates))._build();

  _$TableMoveInput._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId,
      required this.resourceId})
      : super._();
  @override
  TableMoveInput rebuild(void Function(TableMoveInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableMoveInputBuilder toBuilder() => TableMoveInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableMoveInput &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId &&
        resourceId == other.resourceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableMoveInput')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId)
          ..add('resourceId', resourceId))
        .toString();
  }
}

class TableMoveInputBuilder
    implements Builder<TableMoveInput, TableMoveInputBuilder> {
  _$TableMoveInput? _$v;

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

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  TableMoveInputBuilder() {
    TableMoveInput._defaults(this);
  }

  TableMoveInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _resourceId = $v.resourceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableMoveInput other) {
    _$v = other as _$TableMoveInput;
  }

  @override
  void update(void Function(TableMoveInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableMoveInput build() => _build();

  _$TableMoveInput _build() {
    final _$result = _$v ??
        _$TableMoveInput._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision, r'TableMoveInput', 'expectedRevision'),
          leaseGeneration: BuiltValueNullFieldError.checkNotNull(
              leaseGeneration, r'TableMoveInput', 'leaseGeneration'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'TableMoveInput', 'editorId'),
          resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId, r'TableMoveInput', 'resourceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
