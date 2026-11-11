// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_workspace_line_modifiers_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosWorkspaceLineModifiersRequest
    extends PosWorkspaceLineModifiersRequest {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;
  @override
  final BuiltList<ModifierSelection> modifiers;
  @override
  final String? note;

  factory _$PosWorkspaceLineModifiersRequest(
          [void Function(PosWorkspaceLineModifiersRequestBuilder)? updates]) =>
      (PosWorkspaceLineModifiersRequestBuilder()..update(updates))._build();

  _$PosWorkspaceLineModifiersRequest._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId,
      required this.modifiers,
      this.note})
      : super._();
  @override
  PosWorkspaceLineModifiersRequest rebuild(
          void Function(PosWorkspaceLineModifiersRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosWorkspaceLineModifiersRequestBuilder toBuilder() =>
      PosWorkspaceLineModifiersRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosWorkspaceLineModifiersRequest &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId &&
        modifiers == other.modifiers &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosWorkspaceLineModifiersRequest')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId)
          ..add('modifiers', modifiers)
          ..add('note', note))
        .toString();
  }
}

class PosWorkspaceLineModifiersRequestBuilder
    implements
        Builder<PosWorkspaceLineModifiersRequest,
            PosWorkspaceLineModifiersRequestBuilder> {
  _$PosWorkspaceLineModifiersRequest? _$v;

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

  ListBuilder<ModifierSelection>? _modifiers;
  ListBuilder<ModifierSelection> get modifiers =>
      _$this._modifiers ??= ListBuilder<ModifierSelection>();
  set modifiers(ListBuilder<ModifierSelection>? modifiers) =>
      _$this._modifiers = modifiers;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  PosWorkspaceLineModifiersRequestBuilder() {
    PosWorkspaceLineModifiersRequest._defaults(this);
  }

  PosWorkspaceLineModifiersRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _modifiers = $v.modifiers.toBuilder();
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosWorkspaceLineModifiersRequest other) {
    _$v = other as _$PosWorkspaceLineModifiersRequest;
  }

  @override
  void update(void Function(PosWorkspaceLineModifiersRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosWorkspaceLineModifiersRequest build() => _build();

  _$PosWorkspaceLineModifiersRequest _build() {
    _$PosWorkspaceLineModifiersRequest _$result;
    try {
      _$result = _$v ??
          _$PosWorkspaceLineModifiersRequest._(
            expectedRevision: BuiltValueNullFieldError.checkNotNull(
                expectedRevision,
                r'PosWorkspaceLineModifiersRequest',
                'expectedRevision'),
            leaseGeneration: BuiltValueNullFieldError.checkNotNull(
                leaseGeneration,
                r'PosWorkspaceLineModifiersRequest',
                'leaseGeneration'),
            editorId: BuiltValueNullFieldError.checkNotNull(
                editorId, r'PosWorkspaceLineModifiersRequest', 'editorId'),
            modifiers: modifiers.build(),
            note: note,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        modifiers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosWorkspaceLineModifiersRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
