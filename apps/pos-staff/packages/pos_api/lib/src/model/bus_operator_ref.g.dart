// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_operator_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusOperatorRef extends BusOperatorRef {
  @override
  final String id;
  @override
  final String name;

  factory _$BusOperatorRef([void Function(BusOperatorRefBuilder)? updates]) =>
      (BusOperatorRefBuilder()..update(updates))._build();

  _$BusOperatorRef._({required this.id, required this.name}) : super._();
  @override
  BusOperatorRef rebuild(void Function(BusOperatorRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusOperatorRefBuilder toBuilder() => BusOperatorRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusOperatorRef && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'BusOperatorRef')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class BusOperatorRefBuilder
    implements Builder<BusOperatorRef, BusOperatorRefBuilder> {
  _$BusOperatorRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  BusOperatorRefBuilder() {
    BusOperatorRef._defaults(this);
  }

  BusOperatorRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusOperatorRef other) {
    _$v = other as _$BusOperatorRef;
  }

  @override
  void update(void Function(BusOperatorRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusOperatorRef build() => _build();

  _$BusOperatorRef _build() {
    final _$result = _$v ??
        _$BusOperatorRef._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'BusOperatorRef', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'BusOperatorRef', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
