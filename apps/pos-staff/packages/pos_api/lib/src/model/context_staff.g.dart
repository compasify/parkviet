// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_staff.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContextStaff extends ContextStaff {
  @override
  final String id;
  @override
  final String email;

  factory _$ContextStaff([void Function(ContextStaffBuilder)? updates]) =>
      (ContextStaffBuilder()..update(updates))._build();

  _$ContextStaff._({required this.id, required this.email}) : super._();
  @override
  ContextStaff rebuild(void Function(ContextStaffBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContextStaffBuilder toBuilder() => ContextStaffBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContextStaff && id == other.id && email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContextStaff')
          ..add('id', id)
          ..add('email', email))
        .toString();
  }
}

class ContextStaffBuilder
    implements Builder<ContextStaff, ContextStaffBuilder> {
  _$ContextStaff? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  ContextStaffBuilder() {
    ContextStaff._defaults(this);
  }

  ContextStaffBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContextStaff other) {
    _$v = other as _$ContextStaff;
  }

  @override
  void update(void Function(ContextStaffBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContextStaff build() => _build();

  _$ContextStaff _build() {
    final _$result = _$v ??
        _$ContextStaff._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'ContextStaff', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ContextStaff', 'email'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
