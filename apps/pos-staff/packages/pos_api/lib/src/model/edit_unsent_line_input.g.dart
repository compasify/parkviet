// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_unsent_line_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EditUnsentLineInput extends EditUnsentLineInput {
  @override
  final int rowVersion;
  @override
  final int quantity;

  factory _$EditUnsentLineInput(
          [void Function(EditUnsentLineInputBuilder)? updates]) =>
      (EditUnsentLineInputBuilder()..update(updates))._build();

  _$EditUnsentLineInput._({required this.rowVersion, required this.quantity})
      : super._();
  @override
  EditUnsentLineInput rebuild(
          void Function(EditUnsentLineInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EditUnsentLineInputBuilder toBuilder() =>
      EditUnsentLineInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EditUnsentLineInput &&
        rowVersion == other.rowVersion &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rowVersion.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditUnsentLineInput')
          ..add('rowVersion', rowVersion)
          ..add('quantity', quantity))
        .toString();
  }
}

class EditUnsentLineInputBuilder
    implements Builder<EditUnsentLineInput, EditUnsentLineInputBuilder> {
  _$EditUnsentLineInput? _$v;

  int? _rowVersion;
  int? get rowVersion => _$this._rowVersion;
  set rowVersion(int? rowVersion) => _$this._rowVersion = rowVersion;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  EditUnsentLineInputBuilder() {
    EditUnsentLineInput._defaults(this);
  }

  EditUnsentLineInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rowVersion = $v.rowVersion;
      _quantity = $v.quantity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EditUnsentLineInput other) {
    _$v = other as _$EditUnsentLineInput;
  }

  @override
  void update(void Function(EditUnsentLineInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EditUnsentLineInput build() => _build();

  _$EditUnsentLineInput _build() {
    final _$result = _$v ??
        _$EditUnsentLineInput._(
          rowVersion: BuiltValueNullFieldError.checkNotNull(
              rowVersion, r'EditUnsentLineInput', 'rowVersion'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'EditUnsentLineInput', 'quantity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
