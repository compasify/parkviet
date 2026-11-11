// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintRow extends PrintRow {
  @override
  final String label;
  @override
  final String value;
  @override
  final bool? strong;

  factory _$PrintRow([void Function(PrintRowBuilder)? updates]) =>
      (PrintRowBuilder()..update(updates))._build();

  _$PrintRow._({required this.label, required this.value, this.strong})
      : super._();
  @override
  PrintRow rebuild(void Function(PrintRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintRowBuilder toBuilder() => PrintRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintRow &&
        label == other.label &&
        value == other.value &&
        strong == other.strong;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, strong.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintRow')
          ..add('label', label)
          ..add('value', value)
          ..add('strong', strong))
        .toString();
  }
}

class PrintRowBuilder implements Builder<PrintRow, PrintRowBuilder> {
  _$PrintRow? _$v;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  bool? _strong;
  bool? get strong => _$this._strong;
  set strong(bool? strong) => _$this._strong = strong;

  PrintRowBuilder() {
    PrintRow._defaults(this);
  }

  PrintRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _label = $v.label;
      _value = $v.value;
      _strong = $v.strong;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintRow other) {
    _$v = other as _$PrintRow;
  }

  @override
  void update(void Function(PrintRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintRow build() => _build();

  _$PrintRow _build() {
    final _$result = _$v ??
        _$PrintRow._(
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'PrintRow', 'label'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'PrintRow', 'value'),
          strong: strong,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
