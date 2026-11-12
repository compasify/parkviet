// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sale_staff.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSaleStaff extends OfflineSaleStaff {
  @override
  final String id;
  @override
  final String? name;

  factory _$OfflineSaleStaff(
          [void Function(OfflineSaleStaffBuilder)? updates]) =>
      (OfflineSaleStaffBuilder()..update(updates))._build();

  _$OfflineSaleStaff._({required this.id, this.name}) : super._();
  @override
  OfflineSaleStaff rebuild(void Function(OfflineSaleStaffBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSaleStaffBuilder toBuilder() =>
      OfflineSaleStaffBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSaleStaff && id == other.id && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSaleStaff')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class OfflineSaleStaffBuilder
    implements Builder<OfflineSaleStaff, OfflineSaleStaffBuilder> {
  _$OfflineSaleStaff? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  OfflineSaleStaffBuilder() {
    OfflineSaleStaff._defaults(this);
  }

  OfflineSaleStaffBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSaleStaff other) {
    _$v = other as _$OfflineSaleStaff;
  }

  @override
  void update(void Function(OfflineSaleStaffBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSaleStaff build() => _build();

  _$OfflineSaleStaff _build() {
    final _$result = _$v ??
        _$OfflineSaleStaff._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OfflineSaleStaff', 'id'),
          name: name,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
