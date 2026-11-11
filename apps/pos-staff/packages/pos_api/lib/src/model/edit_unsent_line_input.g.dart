// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_unsent_line_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EditUnsentLineInput extends EditUnsentLineInput {
  @override
  final int rowVersion;
  @override
  final int? quantity;
  @override
  final int? course;
  @override
  final int? seat;
  @override
  final bool? hold;

  factory _$EditUnsentLineInput(
          [void Function(EditUnsentLineInputBuilder)? updates]) =>
      (EditUnsentLineInputBuilder()..update(updates))._build();

  _$EditUnsentLineInput._(
      {required this.rowVersion,
      this.quantity,
      this.course,
      this.seat,
      this.hold})
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
        quantity == other.quantity &&
        course == other.course &&
        seat == other.seat &&
        hold == other.hold;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rowVersion.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, course.hashCode);
    _$hash = $jc(_$hash, seat.hashCode);
    _$hash = $jc(_$hash, hold.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EditUnsentLineInput')
          ..add('rowVersion', rowVersion)
          ..add('quantity', quantity)
          ..add('course', course)
          ..add('seat', seat)
          ..add('hold', hold))
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

  int? _course;
  int? get course => _$this._course;
  set course(int? course) => _$this._course = course;

  int? _seat;
  int? get seat => _$this._seat;
  set seat(int? seat) => _$this._seat = seat;

  bool? _hold;
  bool? get hold => _$this._hold;
  set hold(bool? hold) => _$this._hold = hold;

  EditUnsentLineInputBuilder() {
    EditUnsentLineInput._defaults(this);
  }

  EditUnsentLineInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rowVersion = $v.rowVersion;
      _quantity = $v.quantity;
      _course = $v.course;
      _seat = $v.seat;
      _hold = $v.hold;
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
          quantity: quantity,
          course: course,
          seat: seat,
          hold: hold,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
