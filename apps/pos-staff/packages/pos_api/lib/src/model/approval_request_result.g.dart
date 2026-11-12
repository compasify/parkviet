// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_request_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApprovalRequestResult extends ApprovalRequestResult {
  @override
  final ApprovalRequest data;

  factory _$ApprovalRequestResult(
          [void Function(ApprovalRequestResultBuilder)? updates]) =>
      (ApprovalRequestResultBuilder()..update(updates))._build();

  _$ApprovalRequestResult._({required this.data}) : super._();
  @override
  ApprovalRequestResult rebuild(
          void Function(ApprovalRequestResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApprovalRequestResultBuilder toBuilder() =>
      ApprovalRequestResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApprovalRequestResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ApprovalRequestResult')
          ..add('data', data))
        .toString();
  }
}

class ApprovalRequestResultBuilder
    implements Builder<ApprovalRequestResult, ApprovalRequestResultBuilder> {
  _$ApprovalRequestResult? _$v;

  ApprovalRequestBuilder? _data;
  ApprovalRequestBuilder get data => _$this._data ??= ApprovalRequestBuilder();
  set data(ApprovalRequestBuilder? data) => _$this._data = data;

  ApprovalRequestResultBuilder() {
    ApprovalRequestResult._defaults(this);
  }

  ApprovalRequestResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApprovalRequestResult other) {
    _$v = other as _$ApprovalRequestResult;
  }

  @override
  void update(void Function(ApprovalRequestResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApprovalRequestResult build() => _build();

  _$ApprovalRequestResult _build() {
    _$ApprovalRequestResult _$result;
    try {
      _$result = _$v ??
          _$ApprovalRequestResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ApprovalRequestResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
