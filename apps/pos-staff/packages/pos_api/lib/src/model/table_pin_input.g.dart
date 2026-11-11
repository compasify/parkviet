// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_pin_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TablePinInput extends TablePinInput {
  @override
  final String resourceId;

  factory _$TablePinInput([void Function(TablePinInputBuilder)? updates]) =>
      (TablePinInputBuilder()..update(updates))._build();

  _$TablePinInput._({required this.resourceId}) : super._();
  @override
  TablePinInput rebuild(void Function(TablePinInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TablePinInputBuilder toBuilder() => TablePinInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TablePinInput && resourceId == other.resourceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TablePinInput')
          ..add('resourceId', resourceId))
        .toString();
  }
}

class TablePinInputBuilder
    implements Builder<TablePinInput, TablePinInputBuilder> {
  _$TablePinInput? _$v;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  TablePinInputBuilder() {
    TablePinInput._defaults(this);
  }

  TablePinInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _resourceId = $v.resourceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TablePinInput other) {
    _$v = other as _$TablePinInput;
  }

  @override
  void update(void Function(TablePinInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TablePinInput build() => _build();

  _$TablePinInput _build() {
    final _$result = _$v ??
        _$TablePinInput._(
          resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId, r'TablePinInput', 'resourceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
