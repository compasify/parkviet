// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_split_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableSplitInput extends TableSplitInput {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;
  @override
  final BuiltList<String> saleLineIds;
  @override
  final String? resourceId;
  @override
  final int? guestCount;

  factory _$TableSplitInput([void Function(TableSplitInputBuilder)? updates]) =>
      (TableSplitInputBuilder()..update(updates))._build();

  _$TableSplitInput._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId,
      required this.saleLineIds,
      this.resourceId,
      this.guestCount})
      : super._();
  @override
  TableSplitInput rebuild(void Function(TableSplitInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableSplitInputBuilder toBuilder() => TableSplitInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableSplitInput &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId &&
        saleLineIds == other.saleLineIds &&
        resourceId == other.resourceId &&
        guestCount == other.guestCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, saleLineIds.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableSplitInput')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId)
          ..add('saleLineIds', saleLineIds)
          ..add('resourceId', resourceId)
          ..add('guestCount', guestCount))
        .toString();
  }
}

class TableSplitInputBuilder
    implements Builder<TableSplitInput, TableSplitInputBuilder> {
  _$TableSplitInput? _$v;

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

  ListBuilder<String>? _saleLineIds;
  ListBuilder<String> get saleLineIds =>
      _$this._saleLineIds ??= ListBuilder<String>();
  set saleLineIds(ListBuilder<String>? saleLineIds) =>
      _$this._saleLineIds = saleLineIds;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  TableSplitInputBuilder() {
    TableSplitInput._defaults(this);
  }

  TableSplitInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _saleLineIds = $v.saleLineIds.toBuilder();
      _resourceId = $v.resourceId;
      _guestCount = $v.guestCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableSplitInput other) {
    _$v = other as _$TableSplitInput;
  }

  @override
  void update(void Function(TableSplitInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableSplitInput build() => _build();

  _$TableSplitInput _build() {
    _$TableSplitInput _$result;
    try {
      _$result = _$v ??
          _$TableSplitInput._(
            expectedRevision: BuiltValueNullFieldError.checkNotNull(
                expectedRevision, r'TableSplitInput', 'expectedRevision'),
            leaseGeneration: BuiltValueNullFieldError.checkNotNull(
                leaseGeneration, r'TableSplitInput', 'leaseGeneration'),
            editorId: BuiltValueNullFieldError.checkNotNull(
                editorId, r'TableSplitInput', 'editorId'),
            saleLineIds: saleLineIds.build(),
            resourceId: resourceId,
            guestCount: guestCount,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'saleLineIds';
        saleLineIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableSplitInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
