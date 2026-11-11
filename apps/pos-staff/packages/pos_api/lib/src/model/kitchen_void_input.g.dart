// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_void_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenVoidInput extends KitchenVoidInput {
  @override
  final int quantity;
  @override
  final String reasonCode;
  @override
  final String? note;
  @override
  final String? approvalId;
  @override
  final int? expectedRevision;
  @override
  final int? leaseGeneration;
  @override
  final String? editorId;

  factory _$KitchenVoidInput(
          [void Function(KitchenVoidInputBuilder)? updates]) =>
      (KitchenVoidInputBuilder()..update(updates))._build();

  _$KitchenVoidInput._(
      {required this.quantity,
      required this.reasonCode,
      this.note,
      this.approvalId,
      this.expectedRevision,
      this.leaseGeneration,
      this.editorId})
      : super._();
  @override
  KitchenVoidInput rebuild(void Function(KitchenVoidInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenVoidInputBuilder toBuilder() =>
      KitchenVoidInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenVoidInput &&
        quantity == other.quantity &&
        reasonCode == other.reasonCode &&
        note == other.note &&
        approvalId == other.approvalId &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenVoidInput')
          ..add('quantity', quantity)
          ..add('reasonCode', reasonCode)
          ..add('note', note)
          ..add('approvalId', approvalId)
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId))
        .toString();
  }
}

class KitchenVoidInputBuilder
    implements Builder<KitchenVoidInput, KitchenVoidInputBuilder> {
  _$KitchenVoidInput? _$v;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

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

  KitchenVoidInputBuilder() {
    KitchenVoidInput._defaults(this);
  }

  KitchenVoidInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _quantity = $v.quantity;
      _reasonCode = $v.reasonCode;
      _note = $v.note;
      _approvalId = $v.approvalId;
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenVoidInput other) {
    _$v = other as _$KitchenVoidInput;
  }

  @override
  void update(void Function(KitchenVoidInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenVoidInput build() => _build();

  _$KitchenVoidInput _build() {
    final _$result = _$v ??
        _$KitchenVoidInput._(
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'KitchenVoidInput', 'quantity'),
          reasonCode: BuiltValueNullFieldError.checkNotNull(
              reasonCode, r'KitchenVoidInput', 'reasonCode'),
          note: note,
          approvalId: approvalId,
          expectedRevision: expectedRevision,
          leaseGeneration: leaseGeneration,
          editorId: editorId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
