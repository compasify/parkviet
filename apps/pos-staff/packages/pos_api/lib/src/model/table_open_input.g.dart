// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_open_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TableOpenInput extends TableOpenInput {
  @override
  final String branchId;
  @override
  final String editorId;
  @override
  final int? guestCount;
  @override
  final bool? addOrder;

  factory _$TableOpenInput([void Function(TableOpenInputBuilder)? updates]) =>
      (TableOpenInputBuilder()..update(updates))._build();

  _$TableOpenInput._(
      {required this.branchId,
      required this.editorId,
      this.guestCount,
      this.addOrder})
      : super._();
  @override
  TableOpenInput rebuild(void Function(TableOpenInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TableOpenInputBuilder toBuilder() => TableOpenInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TableOpenInput &&
        branchId == other.branchId &&
        editorId == other.editorId &&
        guestCount == other.guestCount &&
        addOrder == other.addOrder;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, guestCount.hashCode);
    _$hash = $jc(_$hash, addOrder.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TableOpenInput')
          ..add('branchId', branchId)
          ..add('editorId', editorId)
          ..add('guestCount', guestCount)
          ..add('addOrder', addOrder))
        .toString();
  }
}

class TableOpenInputBuilder
    implements Builder<TableOpenInput, TableOpenInputBuilder> {
  _$TableOpenInput? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  int? _guestCount;
  int? get guestCount => _$this._guestCount;
  set guestCount(int? guestCount) => _$this._guestCount = guestCount;

  bool? _addOrder;
  bool? get addOrder => _$this._addOrder;
  set addOrder(bool? addOrder) => _$this._addOrder = addOrder;

  TableOpenInputBuilder() {
    TableOpenInput._defaults(this);
  }

  TableOpenInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _editorId = $v.editorId;
      _guestCount = $v.guestCount;
      _addOrder = $v.addOrder;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TableOpenInput other) {
    _$v = other as _$TableOpenInput;
  }

  @override
  void update(void Function(TableOpenInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TableOpenInput build() => _build();

  _$TableOpenInput _build() {
    final _$result = _$v ??
        _$TableOpenInput._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'TableOpenInput', 'branchId'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'TableOpenInput', 'editorId'),
          guestCount: guestCount,
          addOrder: addOrder,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
