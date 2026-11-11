// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response_error_details.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ErrorResponseErrorDetails extends ErrorResponseErrorDetails {
  @override
  final String? reason;
  @override
  final int? currentRevision;
  @override
  final int? retryAfterSeconds;

  factory _$ErrorResponseErrorDetails(
          [void Function(ErrorResponseErrorDetailsBuilder)? updates]) =>
      (ErrorResponseErrorDetailsBuilder()..update(updates))._build();

  _$ErrorResponseErrorDetails._(
      {this.reason, this.currentRevision, this.retryAfterSeconds})
      : super._();
  @override
  ErrorResponseErrorDetails rebuild(
          void Function(ErrorResponseErrorDetailsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorResponseErrorDetailsBuilder toBuilder() =>
      ErrorResponseErrorDetailsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ErrorResponseErrorDetails &&
        reason == other.reason &&
        currentRevision == other.currentRevision &&
        retryAfterSeconds == other.retryAfterSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, currentRevision.hashCode);
    _$hash = $jc(_$hash, retryAfterSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ErrorResponseErrorDetails')
          ..add('reason', reason)
          ..add('currentRevision', currentRevision)
          ..add('retryAfterSeconds', retryAfterSeconds))
        .toString();
  }
}

class ErrorResponseErrorDetailsBuilder
    implements
        Builder<ErrorResponseErrorDetails, ErrorResponseErrorDetailsBuilder> {
  _$ErrorResponseErrorDetails? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  int? _currentRevision;
  int? get currentRevision => _$this._currentRevision;
  set currentRevision(int? currentRevision) =>
      _$this._currentRevision = currentRevision;

  int? _retryAfterSeconds;
  int? get retryAfterSeconds => _$this._retryAfterSeconds;
  set retryAfterSeconds(int? retryAfterSeconds) =>
      _$this._retryAfterSeconds = retryAfterSeconds;

  ErrorResponseErrorDetailsBuilder() {
    ErrorResponseErrorDetails._defaults(this);
  }

  ErrorResponseErrorDetailsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _currentRevision = $v.currentRevision;
      _retryAfterSeconds = $v.retryAfterSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ErrorResponseErrorDetails other) {
    _$v = other as _$ErrorResponseErrorDetails;
  }

  @override
  void update(void Function(ErrorResponseErrorDetailsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ErrorResponseErrorDetails build() => _build();

  _$ErrorResponseErrorDetails _build() {
    final _$result = _$v ??
        _$ErrorResponseErrorDetails._(
          reason: reason,
          currentRevision: currentRevision,
          retryAfterSeconds: retryAfterSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
