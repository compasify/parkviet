// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Context extends Context {
  @override
  final BuiltList<String> capabilities;
  @override
  final ContextStaff staff;
  @override
  final ContextStore store;
  @override
  final ContextAdministration administration;

  factory _$Context([void Function(ContextBuilder)? updates]) =>
      (ContextBuilder()..update(updates))._build();

  _$Context._(
      {required this.capabilities,
      required this.staff,
      required this.store,
      required this.administration})
      : super._();
  @override
  Context rebuild(void Function(ContextBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContextBuilder toBuilder() => ContextBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Context &&
        capabilities == other.capabilities &&
        staff == other.staff &&
        store == other.store &&
        administration == other.administration;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, capabilities.hashCode);
    _$hash = $jc(_$hash, staff.hashCode);
    _$hash = $jc(_$hash, store.hashCode);
    _$hash = $jc(_$hash, administration.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Context')
          ..add('capabilities', capabilities)
          ..add('staff', staff)
          ..add('store', store)
          ..add('administration', administration))
        .toString();
  }
}

class ContextBuilder implements Builder<Context, ContextBuilder> {
  _$Context? _$v;

  ListBuilder<String>? _capabilities;
  ListBuilder<String> get capabilities =>
      _$this._capabilities ??= ListBuilder<String>();
  set capabilities(ListBuilder<String>? capabilities) =>
      _$this._capabilities = capabilities;

  ContextStaffBuilder? _staff;
  ContextStaffBuilder get staff => _$this._staff ??= ContextStaffBuilder();
  set staff(ContextStaffBuilder? staff) => _$this._staff = staff;

  ContextStoreBuilder? _store;
  ContextStoreBuilder get store => _$this._store ??= ContextStoreBuilder();
  set store(ContextStoreBuilder? store) => _$this._store = store;

  ContextAdministrationBuilder? _administration;
  ContextAdministrationBuilder get administration =>
      _$this._administration ??= ContextAdministrationBuilder();
  set administration(ContextAdministrationBuilder? administration) =>
      _$this._administration = administration;

  ContextBuilder() {
    Context._defaults(this);
  }

  ContextBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _capabilities = $v.capabilities.toBuilder();
      _staff = $v.staff.toBuilder();
      _store = $v.store.toBuilder();
      _administration = $v.administration.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Context other) {
    _$v = other as _$Context;
  }

  @override
  void update(void Function(ContextBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Context build() => _build();

  _$Context _build() {
    _$Context _$result;
    try {
      _$result = _$v ??
          _$Context._(
            capabilities: capabilities.build(),
            staff: staff.build(),
            store: store.build(),
            administration: administration.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'capabilities';
        capabilities.build();
        _$failedField = 'staff';
        staff.build();
        _$failedField = 'store';
        store.build();
        _$failedField = 'administration';
        administration.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Context', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
