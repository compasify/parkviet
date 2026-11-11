// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_send_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenSendInput extends KitchenSendInput {
  @override
  final int? expectedRevision;
  @override
  final int? leaseGeneration;
  @override
  final String? editorId;

  factory _$KitchenSendInput(
          [void Function(KitchenSendInputBuilder)? updates]) =>
      (KitchenSendInputBuilder()..update(updates))._build();

  _$KitchenSendInput._(
      {this.expectedRevision, this.leaseGeneration, this.editorId})
      : super._();
  @override
  KitchenSendInput rebuild(void Function(KitchenSendInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenSendInputBuilder toBuilder() =>
      KitchenSendInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenSendInput &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenSendInput')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId))
        .toString();
  }
}

class KitchenSendInputBuilder
    implements Builder<KitchenSendInput, KitchenSendInputBuilder> {
  _$KitchenSendInput? _$v;

  int? _expectedRevision;
  int? get expectedRevision => _$this._expectedRevision;
  set expectedRevision(int? expectedRevision) =>
      _$this._expectedRevision = expectedRevision;

  int? _leaseGeneration;
  int? get leaseGeneration => _$this._leaseGeneration;
  set leaseGeneration(int? leaseGeneration) =>
      _$this._leaseGeneration = leaseGeneration;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  KitchenSendInputBuilder() {
    KitchenSendInput._defaults(this);
  }

  KitchenSendInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenSendInput other) {
    _$v = other as _$KitchenSendInput;
  }

  @override
  void update(void Function(KitchenSendInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenSendInput build() => _build();

  _$KitchenSendInput _build() {
    final _$result = _$v ??
        _$KitchenSendInput._(
          expectedRevision: expectedRevision,
          leaseGeneration: leaseGeneration,
          editorId: editorId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
