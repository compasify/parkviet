// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendant_assignment_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AttendantAssignmentList extends AttendantAssignmentList {
  @override
  final BuiltList<AttendantAssignment> data;
  @override
  final WorkspacePageMeta meta;

  factory _$AttendantAssignmentList(
          [void Function(AttendantAssignmentListBuilder)? updates]) =>
      (AttendantAssignmentListBuilder()..update(updates))._build();

  _$AttendantAssignmentList._({required this.data, required this.meta})
      : super._();
  @override
  AttendantAssignmentList rebuild(
          void Function(AttendantAssignmentListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AttendantAssignmentListBuilder toBuilder() =>
      AttendantAssignmentListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AttendantAssignmentList &&
        data == other.data &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AttendantAssignmentList')
          ..add('data', data)
          ..add('meta', meta))
        .toString();
  }
}

class AttendantAssignmentListBuilder
    implements
        Builder<AttendantAssignmentList, AttendantAssignmentListBuilder> {
  _$AttendantAssignmentList? _$v;

  ListBuilder<AttendantAssignment>? _data;
  ListBuilder<AttendantAssignment> get data =>
      _$this._data ??= ListBuilder<AttendantAssignment>();
  set data(ListBuilder<AttendantAssignment>? data) => _$this._data = data;

  WorkspacePageMetaBuilder? _meta;
  WorkspacePageMetaBuilder get meta =>
      _$this._meta ??= WorkspacePageMetaBuilder();
  set meta(WorkspacePageMetaBuilder? meta) => _$this._meta = meta;

  AttendantAssignmentListBuilder() {
    AttendantAssignmentList._defaults(this);
  }

  AttendantAssignmentListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _meta = $v.meta.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AttendantAssignmentList other) {
    _$v = other as _$AttendantAssignmentList;
  }

  @override
  void update(void Function(AttendantAssignmentListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AttendantAssignmentList build() => _build();

  _$AttendantAssignmentList _build() {
    _$AttendantAssignmentList _$result;
    try {
      _$result = _$v ??
          _$AttendantAssignmentList._(
            data: data.build(),
            meta: meta.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'meta';
        meta.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AttendantAssignmentList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
