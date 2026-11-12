// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_package.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TimedPackage extends TimedPackage {
  @override
  final String name;
  @override
  final int minutes;
  @override
  final String price;

  factory _$TimedPackage([void Function(TimedPackageBuilder)? updates]) =>
      (TimedPackageBuilder()..update(updates))._build();

  _$TimedPackage._(
      {required this.name, required this.minutes, required this.price})
      : super._();
  @override
  TimedPackage rebuild(void Function(TimedPackageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedPackageBuilder toBuilder() => TimedPackageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedPackage &&
        name == other.name &&
        minutes == other.minutes &&
        price == other.price;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, minutes.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedPackage')
          ..add('name', name)
          ..add('minutes', minutes)
          ..add('price', price))
        .toString();
  }
}

class TimedPackageBuilder
    implements Builder<TimedPackage, TimedPackageBuilder> {
  _$TimedPackage? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _minutes;
  int? get minutes => _$this._minutes;
  set minutes(int? minutes) => _$this._minutes = minutes;

  String? _price;
  String? get price => _$this._price;
  set price(String? price) => _$this._price = price;

  TimedPackageBuilder() {
    TimedPackage._defaults(this);
  }

  TimedPackageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _minutes = $v.minutes;
      _price = $v.price;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedPackage other) {
    _$v = other as _$TimedPackage;
  }

  @override
  void update(void Function(TimedPackageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedPackage build() => _build();

  _$TimedPackage _build() {
    final _$result = _$v ??
        _$TimedPackage._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TimedPackage', 'name'),
          minutes: BuiltValueNullFieldError.checkNotNull(
              minutes, r'TimedPackage', 'minutes'),
          price: BuiltValueNullFieldError.checkNotNull(
              price, r'TimedPackage', 'price'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
