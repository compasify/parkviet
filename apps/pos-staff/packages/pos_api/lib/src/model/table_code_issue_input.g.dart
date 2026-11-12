// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_code_issue_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableCodeIssueInput extends TableCodeIssueInput {
  @override
  final String resourceId;
  @override
  final String? printerId;

  factory _$TableCodeIssueInput(
          [void Function(TableCodeIssueInputBuilder)? updates]) =>
      (TableCodeIssueInputBuilder()..update(updates))._build();

  _$TableCodeIssueInput._({required this.resourceId, this.printerId})
      : super._();
  @override
  TableCodeIssueInput rebuild(
          void Function(TableCodeIssueInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableCodeIssueInputBuilder toBuilder() =>
      TableCodeIssueInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableCodeIssueInput &&
        resourceId == other.resourceId &&
        printerId == other.printerId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, printerId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableCodeIssueInput')
          ..add('resourceId', resourceId)
          ..add('printerId', printerId))
        .toString();
  }
}

class TableCodeIssueInputBuilder
    implements Builder<TableCodeIssueInput, TableCodeIssueInputBuilder> {
  _$TableCodeIssueInput? _$v;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(String? printerId) => _$this._printerId = printerId;

  TableCodeIssueInputBuilder() {
    TableCodeIssueInput._defaults(this);
  }

  TableCodeIssueInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _resourceId = $v.resourceId;
      _printerId = $v.printerId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableCodeIssueInput other) {
    _$v = other as _$TableCodeIssueInput;
  }

  @override
  void update(void Function(TableCodeIssueInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableCodeIssueInput build() => _build();

  _$TableCodeIssueInput _build() {
    final _$result = _$v ??
        _$TableCodeIssueInput._(
          resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId, r'TableCodeIssueInput', 'resourceId'),
          printerId: printerId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
