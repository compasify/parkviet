// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_revision.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApprovalRevision extends ApprovalRevision {
  @override
  final AnyOf anyOf;

  factory _$ApprovalRevision(
          [void Function(ApprovalRevisionBuilder)? updates]) =>
      (ApprovalRevisionBuilder()..update(updates))._build();

  _$ApprovalRevision._({required this.anyOf}) : super._();
  @override
  ApprovalRevision rebuild(void Function(ApprovalRevisionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApprovalRevisionBuilder toBuilder() =>
      ApprovalRevisionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApprovalRevision && anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApprovalRevision')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class ApprovalRevisionBuilder
    implements Builder<ApprovalRevision, ApprovalRevisionBuilder> {
  _$ApprovalRevision? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  ApprovalRevisionBuilder() {
    ApprovalRevision._defaults(this);
  }

  ApprovalRevisionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApprovalRevision other) {
    _$v = other as _$ApprovalRevision;
  }

  @override
  void update(void Function(ApprovalRevisionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApprovalRevision build() => _build();

  _$ApprovalRevision _build() {
    final _$result = _$v ??
        _$ApprovalRevision._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'ApprovalRevision', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
