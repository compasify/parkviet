// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_split_orders.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableSplitOrders extends TableSplitOrders {
  @override
  final Workspace workspace;
  @override
  final Workspace newWorkspace;

  factory _$TableSplitOrders(
          [void Function(TableSplitOrdersBuilder)? updates]) =>
      (TableSplitOrdersBuilder()..update(updates))._build();

  _$TableSplitOrders._({required this.workspace, required this.newWorkspace})
      : super._();
  @override
  TableSplitOrders rebuild(void Function(TableSplitOrdersBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableSplitOrdersBuilder toBuilder() =>
      TableSplitOrdersBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableSplitOrders &&
        workspace == other.workspace &&
        newWorkspace == other.newWorkspace;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspace.hashCode);
    _$hash = $jc(_$hash, newWorkspace.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableSplitOrders')
          ..add('workspace', workspace)
          ..add('newWorkspace', newWorkspace))
        .toString();
  }
}

class TableSplitOrdersBuilder
    implements Builder<TableSplitOrders, TableSplitOrdersBuilder> {
  _$TableSplitOrders? _$v;

  WorkspaceBuilder? _workspace;
  WorkspaceBuilder get workspace => _$this._workspace ??= WorkspaceBuilder();
  set workspace(WorkspaceBuilder? workspace) => _$this._workspace = workspace;

  WorkspaceBuilder? _newWorkspace;
  WorkspaceBuilder get newWorkspace =>
      _$this._newWorkspace ??= WorkspaceBuilder();
  set newWorkspace(WorkspaceBuilder? newWorkspace) =>
      _$this._newWorkspace = newWorkspace;

  TableSplitOrdersBuilder() {
    TableSplitOrders._defaults(this);
  }

  TableSplitOrdersBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspace = $v.workspace.toBuilder();
      _newWorkspace = $v.newWorkspace.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableSplitOrders other) {
    _$v = other as _$TableSplitOrders;
  }

  @override
  void update(void Function(TableSplitOrdersBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableSplitOrders build() => _build();

  _$TableSplitOrders _build() {
    _$TableSplitOrders _$result;
    try {
      _$result = _$v ??
          _$TableSplitOrders._(
            workspace: workspace.build(),
            newWorkspace: newWorkspace.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'workspace';
        workspace.build();
        _$failedField = 'newWorkspace';
        newWorkspace.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TableSplitOrders', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
