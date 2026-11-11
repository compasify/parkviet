// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lease_claim_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LeaseClaimInput extends LeaseClaimInput {
  @override
  final String editorId;
  @override
  final bool? takeover;

  factory _$LeaseClaimInput([void Function(LeaseClaimInputBuilder)? updates]) =>
      (LeaseClaimInputBuilder()..update(updates))._build();

  _$LeaseClaimInput._({required this.editorId, this.takeover}) : super._();
  @override
  LeaseClaimInput rebuild(void Function(LeaseClaimInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LeaseClaimInputBuilder toBuilder() => LeaseClaimInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LeaseClaimInput &&
        editorId == other.editorId &&
        takeover == other.takeover;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, takeover.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LeaseClaimInput')
          ..add('editorId', editorId)
          ..add('takeover', takeover))
        .toString();
  }
}

class LeaseClaimInputBuilder
    implements Builder<LeaseClaimInput, LeaseClaimInputBuilder> {
  _$LeaseClaimInput? _$v;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  bool? _takeover;
  bool? get takeover => _$this._takeover;
  set takeover(bool? takeover) => _$this._takeover = takeover;

  LeaseClaimInputBuilder() {
    LeaseClaimInput._defaults(this);
  }

  LeaseClaimInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _editorId = $v.editorId;
      _takeover = $v.takeover;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LeaseClaimInput other) {
    _$v = other as _$LeaseClaimInput;
  }

  @override
  void update(void Function(LeaseClaimInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LeaseClaimInput build() => _build();

  _$LeaseClaimInput _build() {
    final _$result = _$v ??
        _$LeaseClaimInput._(
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'LeaseClaimInput', 'editorId'),
          takeover: takeover,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
