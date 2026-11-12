// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KioskRef extends KioskRef {
  @override
  final String id;
  @override
  final String name;

  factory _$KioskRef([void Function(KioskRefBuilder)? updates]) =>
      (KioskRefBuilder()..update(updates))._build();

  _$KioskRef._({required this.id, required this.name}) : super._();
  @override
  KioskRef rebuild(void Function(KioskRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskRefBuilder toBuilder() => KioskRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskRef && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'KioskRef')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class KioskRefBuilder implements Builder<KioskRef, KioskRefBuilder> {
  _$KioskRef? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  KioskRefBuilder() {
    KioskRef._defaults(this);
  }

  KioskRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskRef other) {
    _$v = other as _$KioskRef;
  }

  @override
  void update(void Function(KioskRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskRef build() => _build();

  _$KioskRef _build() {
    final _$result = _$v ??
        _$KioskRef._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'KioskRef', 'id'),
          name:
              BuiltValueNullFieldError.checkNotNull(name, r'KioskRef', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
