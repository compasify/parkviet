// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_approval_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosApprovalCreate201Response extends PosApprovalCreate201Response {
  @override
  final Approval data;

  factory _$PosApprovalCreate201Response(
          [void Function(PosApprovalCreate201ResponseBuilder)? updates]) =>
      (PosApprovalCreate201ResponseBuilder()..update(updates))._build();

  _$PosApprovalCreate201Response._({required this.data}) : super._();
  @override
  PosApprovalCreate201Response rebuild(
          void Function(PosApprovalCreate201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosApprovalCreate201ResponseBuilder toBuilder() =>
      PosApprovalCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosApprovalCreate201Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosApprovalCreate201Response')
          ..add('data', data))
        .toString();
  }
}

class PosApprovalCreate201ResponseBuilder
    implements
        Builder<PosApprovalCreate201Response,
            PosApprovalCreate201ResponseBuilder> {
  _$PosApprovalCreate201Response? _$v;

  ApprovalBuilder? _data;
  ApprovalBuilder get data => _$this._data ??= ApprovalBuilder();
  set data(ApprovalBuilder? data) => _$this._data = data;

  PosApprovalCreate201ResponseBuilder() {
    PosApprovalCreate201Response._defaults(this);
  }

  PosApprovalCreate201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosApprovalCreate201Response other) {
    _$v = other as _$PosApprovalCreate201Response;
  }

  @override
  void update(void Function(PosApprovalCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosApprovalCreate201Response build() => _build();

  _$PosApprovalCreate201Response _build() {
    _$PosApprovalCreate201Response _$result;
    try {
      _$result = _$v ??
          _$PosApprovalCreate201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosApprovalCreate201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
