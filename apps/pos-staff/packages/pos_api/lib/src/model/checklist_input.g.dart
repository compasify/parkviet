// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChecklistInput extends ChecklistInput {
  @override
  final String? printerId;

  factory _$ChecklistInput([void Function(ChecklistInputBuilder)? updates]) =>
      (ChecklistInputBuilder()..update(updates))._build();

  _$ChecklistInput._({this.printerId}) : super._();
  @override
  ChecklistInput rebuild(void Function(ChecklistInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChecklistInputBuilder toBuilder() => ChecklistInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChecklistInput && printerId == other.printerId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, printerId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChecklistInput')
          ..add('printerId', printerId))
        .toString();
  }
}

class ChecklistInputBuilder
    implements Builder<ChecklistInput, ChecklistInputBuilder> {
  _$ChecklistInput? _$v;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(String? printerId) => _$this._printerId = printerId;

  ChecklistInputBuilder() {
    ChecklistInput._defaults(this);
  }

  ChecklistInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _printerId = $v.printerId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChecklistInput other) {
    _$v = other as _$ChecklistInput;
  }

  @override
  void update(void Function(ChecklistInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChecklistInput build() => _build();

  _$ChecklistInput _build() {
    final _$result = _$v ??
        _$ChecklistInput._(
          printerId: printerId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
