// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_totals.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceTotals extends WorkspaceTotals {
  @override
  final BuiltList<WorkspaceTotalsTaxesInner> taxes;

  factory _$WorkspaceTotals([void Function(WorkspaceTotalsBuilder)? updates]) =>
      (WorkspaceTotalsBuilder()..update(updates))._build();

  _$WorkspaceTotals._({required this.taxes}) : super._();
  @override
  WorkspaceTotals rebuild(void Function(WorkspaceTotalsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceTotalsBuilder toBuilder() => WorkspaceTotalsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceTotals && taxes == other.taxes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taxes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceTotals')
          ..add('taxes', taxes))
        .toString();
  }
}

class WorkspaceTotalsBuilder
    implements Builder<WorkspaceTotals, WorkspaceTotalsBuilder> {
  _$WorkspaceTotals? _$v;

  ListBuilder<WorkspaceTotalsTaxesInner>? _taxes;
  ListBuilder<WorkspaceTotalsTaxesInner> get taxes =>
      _$this._taxes ??= ListBuilder<WorkspaceTotalsTaxesInner>();
  set taxes(ListBuilder<WorkspaceTotalsTaxesInner>? taxes) =>
      _$this._taxes = taxes;

  WorkspaceTotalsBuilder() {
    WorkspaceTotals._defaults(this);
  }

  WorkspaceTotalsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taxes = $v.taxes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceTotals other) {
    _$v = other as _$WorkspaceTotals;
  }

  @override
  void update(void Function(WorkspaceTotalsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceTotals build() => _build();

  _$WorkspaceTotals _build() {
    _$WorkspaceTotals _$result;
    try {
      _$result = _$v ??
          _$WorkspaceTotals._(
            taxes: taxes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taxes';
        taxes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkspaceTotals', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
