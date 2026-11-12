// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_shift_closure.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskShiftClosure extends KioskShiftClosure {
  @override
  final String id;

  factory _$KioskShiftClosure(
          [void Function(KioskShiftClosureBuilder)? updates]) =>
      (KioskShiftClosureBuilder()..update(updates))._build();

  _$KioskShiftClosure._({required this.id}) : super._();
  @override
  KioskShiftClosure rebuild(void Function(KioskShiftClosureBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskShiftClosureBuilder toBuilder() =>
      KioskShiftClosureBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskShiftClosure && id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskShiftClosure')..add('id', id))
        .toString();
  }
}

class KioskShiftClosureBuilder
    implements Builder<KioskShiftClosure, KioskShiftClosureBuilder> {
  _$KioskShiftClosure? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  KioskShiftClosureBuilder() {
    KioskShiftClosure._defaults(this);
  }

  KioskShiftClosureBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskShiftClosure other) {
    _$v = other as _$KioskShiftClosure;
  }

  @override
  void update(void Function(KioskShiftClosureBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskShiftClosure build() => _build();

  _$KioskShiftClosure _build() {
    final _$result = _$v ??
        _$KioskShiftClosure._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'KioskShiftClosure', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
