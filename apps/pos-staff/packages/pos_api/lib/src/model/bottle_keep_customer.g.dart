// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottle_keep_customer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BottleKeepCustomer extends BottleKeepCustomer {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? phone;

  factory _$BottleKeepCustomer(
          [void Function(BottleKeepCustomerBuilder)? updates]) =>
      (BottleKeepCustomerBuilder()..update(updates))._build();

  _$BottleKeepCustomer._({required this.id, required this.name, this.phone})
      : super._();
  @override
  BottleKeepCustomer rebuild(
          void Function(BottleKeepCustomerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BottleKeepCustomerBuilder toBuilder() =>
      BottleKeepCustomerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BottleKeepCustomer &&
        id == other.id &&
        name == other.name &&
        phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BottleKeepCustomer')
          ..add('id', id)
          ..add('name', name)
          ..add('phone', phone))
        .toString();
  }
}

class BottleKeepCustomerBuilder
    implements Builder<BottleKeepCustomer, BottleKeepCustomerBuilder> {
  _$BottleKeepCustomer? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  BottleKeepCustomerBuilder() {
    BottleKeepCustomer._defaults(this);
  }

  BottleKeepCustomerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BottleKeepCustomer other) {
    _$v = other as _$BottleKeepCustomer;
  }

  @override
  void update(void Function(BottleKeepCustomerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BottleKeepCustomer build() => _build();

  _$BottleKeepCustomer _build() {
    final _$result = _$v ??
        _$BottleKeepCustomer._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'BottleKeepCustomer', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'BottleKeepCustomer', 'name'),
          phone: phone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
