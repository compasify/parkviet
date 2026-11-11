// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job_reprint.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintJobReprint extends PrintJobReprint {
  @override
  final int workspaceRevision;
  @override
  final String? approvalId;
  @override
  final String? requesterId;
  @override
  final bool canApprove;

  factory _$PrintJobReprint([void Function(PrintJobReprintBuilder)? updates]) =>
      (PrintJobReprintBuilder()..update(updates))._build();

  _$PrintJobReprint._(
      {required this.workspaceRevision,
      this.approvalId,
      this.requesterId,
      required this.canApprove})
      : super._();
  @override
  PrintJobReprint rebuild(void Function(PrintJobReprintBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintJobReprintBuilder toBuilder() => PrintJobReprintBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintJobReprint &&
        workspaceRevision == other.workspaceRevision &&
        approvalId == other.approvalId &&
        requesterId == other.requesterId &&
        canApprove == other.canApprove;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspaceRevision.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, requesterId.hashCode);
    _$hash = $jc(_$hash, canApprove.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintJobReprint')
          ..add('workspaceRevision', workspaceRevision)
          ..add('approvalId', approvalId)
          ..add('requesterId', requesterId)
          ..add('canApprove', canApprove))
        .toString();
  }
}

class PrintJobReprintBuilder
    implements Builder<PrintJobReprint, PrintJobReprintBuilder> {
  _$PrintJobReprint? _$v;

  int? _workspaceRevision;
  int? get workspaceRevision => _$this._workspaceRevision;
  set workspaceRevision(int? workspaceRevision) =>
      _$this._workspaceRevision = workspaceRevision;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  String? _requesterId;
  String? get requesterId => _$this._requesterId;
  set requesterId(String? requesterId) => _$this._requesterId = requesterId;

  bool? _canApprove;
  bool? get canApprove => _$this._canApprove;
  set canApprove(bool? canApprove) => _$this._canApprove = canApprove;

  PrintJobReprintBuilder() {
    PrintJobReprint._defaults(this);
  }

  PrintJobReprintBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspaceRevision = $v.workspaceRevision;
      _approvalId = $v.approvalId;
      _requesterId = $v.requesterId;
      _canApprove = $v.canApprove;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintJobReprint other) {
    _$v = other as _$PrintJobReprint;
  }

  @override
  void update(void Function(PrintJobReprintBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintJobReprint build() => _build();

  _$PrintJobReprint _build() {
    final _$result = _$v ??
        _$PrintJobReprint._(
          workspaceRevision: BuiltValueNullFieldError.checkNotNull(
              workspaceRevision, r'PrintJobReprint', 'workspaceRevision'),
          approvalId: approvalId,
          requesterId: requesterId,
          canApprove: BuiltValueNullFieldError.checkNotNull(
              canApprove, r'PrintJobReprint', 'canApprove'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
