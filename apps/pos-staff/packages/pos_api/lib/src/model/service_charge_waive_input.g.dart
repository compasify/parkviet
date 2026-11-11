// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_charge_waive_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ServiceChargeWaiveInput extends ServiceChargeWaiveInput {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;
  @override
  final bool waived;

  factory _$ServiceChargeWaiveInput(
          [void Function(ServiceChargeWaiveInputBuilder)? updates]) =>
      (ServiceChargeWaiveInputBuilder()..update(updates))._build();

  _$ServiceChargeWaiveInput._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId,
      required this.waived})
      : super._();
  @override
  ServiceChargeWaiveInput rebuild(
          void Function(ServiceChargeWaiveInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ServiceChargeWaiveInputBuilder toBuilder() =>
      ServiceChargeWaiveInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ServiceChargeWaiveInput &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId &&
        waived == other.waived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, waived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ServiceChargeWaiveInput')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId)
          ..add('waived', waived))
        .toString();
  }
}

class ServiceChargeWaiveInputBuilder
    implements
        Builder<ServiceChargeWaiveInput, ServiceChargeWaiveInputBuilder> {
  _$ServiceChargeWaiveInput? _$v;

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

  bool? _waived;
  bool? get waived => _$this._waived;
  set waived(bool? waived) => _$this._waived = waived;

  ServiceChargeWaiveInputBuilder() {
    ServiceChargeWaiveInput._defaults(this);
  }

  ServiceChargeWaiveInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _waived = $v.waived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ServiceChargeWaiveInput other) {
    _$v = other as _$ServiceChargeWaiveInput;
  }

  @override
  void update(void Function(ServiceChargeWaiveInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ServiceChargeWaiveInput build() => _build();

  _$ServiceChargeWaiveInput _build() {
    final _$result = _$v ??
        _$ServiceChargeWaiveInput._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision, r'ServiceChargeWaiveInput', 'expectedRevision'),
          leaseGeneration: BuiltValueNullFieldError.checkNotNull(
              leaseGeneration, r'ServiceChargeWaiveInput', 'leaseGeneration'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'ServiceChargeWaiveInput', 'editorId'),
          waived: BuiltValueNullFieldError.checkNotNull(
              waived, r'ServiceChargeWaiveInput', 'waived'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
