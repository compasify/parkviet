// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_snapshot.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSnapshot extends OfflineSnapshot {
  @override
  final OfflineSnapshotStore store;
  @override
  final OfflineSnapshotBranch branch;
  @override
  final OfflineSnapshotRegister register;
  @override
  final OfflineSnapshotStaff staff;
  @override
  final OfflineSnapshotShift? shift;
  @override
  final OfflineSnapshotOffline offline;
  @override
  final Menu? menu;
  @override
  final String etag;
  @override
  final DateTime generatedAt;
  @override
  final int maxAgeSeconds;

  factory _$OfflineSnapshot([void Function(OfflineSnapshotBuilder)? updates]) =>
      (OfflineSnapshotBuilder()..update(updates))._build();

  _$OfflineSnapshot._(
      {required this.store,
      required this.branch,
      required this.register,
      required this.staff,
      this.shift,
      required this.offline,
      this.menu,
      required this.etag,
      required this.generatedAt,
      required this.maxAgeSeconds})
      : super._();
  @override
  OfflineSnapshot rebuild(void Function(OfflineSnapshotBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSnapshotBuilder toBuilder() => OfflineSnapshotBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSnapshot &&
        store == other.store &&
        branch == other.branch &&
        register == other.register &&
        staff == other.staff &&
        shift == other.shift &&
        offline == other.offline &&
        menu == other.menu &&
        etag == other.etag &&
        generatedAt == other.generatedAt &&
        maxAgeSeconds == other.maxAgeSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, store.hashCode);
    _$hash = $jc(_$hash, branch.hashCode);
    _$hash = $jc(_$hash, register.hashCode);
    _$hash = $jc(_$hash, staff.hashCode);
    _$hash = $jc(_$hash, shift.hashCode);
    _$hash = $jc(_$hash, offline.hashCode);
    _$hash = $jc(_$hash, menu.hashCode);
    _$hash = $jc(_$hash, etag.hashCode);
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, maxAgeSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSnapshot')
          ..add('store', store)
          ..add('branch', branch)
          ..add('register', register)
          ..add('staff', staff)
          ..add('shift', shift)
          ..add('offline', offline)
          ..add('menu', menu)
          ..add('etag', etag)
          ..add('generatedAt', generatedAt)
          ..add('maxAgeSeconds', maxAgeSeconds))
        .toString();
  }
}

class OfflineSnapshotBuilder
    implements Builder<OfflineSnapshot, OfflineSnapshotBuilder> {
  _$OfflineSnapshot? _$v;

  OfflineSnapshotStoreBuilder? _store;
  OfflineSnapshotStoreBuilder get store =>
      _$this._store ??= OfflineSnapshotStoreBuilder();
  set store(OfflineSnapshotStoreBuilder? store) => _$this._store = store;

  OfflineSnapshotBranchBuilder? _branch;
  OfflineSnapshotBranchBuilder get branch =>
      _$this._branch ??= OfflineSnapshotBranchBuilder();
  set branch(OfflineSnapshotBranchBuilder? branch) => _$this._branch = branch;

  OfflineSnapshotRegisterBuilder? _register;
  OfflineSnapshotRegisterBuilder get register =>
      _$this._register ??= OfflineSnapshotRegisterBuilder();
  set register(OfflineSnapshotRegisterBuilder? register) =>
      _$this._register = register;

  OfflineSnapshotStaffBuilder? _staff;
  OfflineSnapshotStaffBuilder get staff =>
      _$this._staff ??= OfflineSnapshotStaffBuilder();
  set staff(OfflineSnapshotStaffBuilder? staff) => _$this._staff = staff;

  OfflineSnapshotShiftBuilder? _shift;
  OfflineSnapshotShiftBuilder get shift =>
      _$this._shift ??= OfflineSnapshotShiftBuilder();
  set shift(OfflineSnapshotShiftBuilder? shift) => _$this._shift = shift;

  OfflineSnapshotOfflineBuilder? _offline;
  OfflineSnapshotOfflineBuilder get offline =>
      _$this._offline ??= OfflineSnapshotOfflineBuilder();
  set offline(OfflineSnapshotOfflineBuilder? offline) =>
      _$this._offline = offline;

  MenuBuilder? _menu;
  MenuBuilder get menu => _$this._menu ??= MenuBuilder();
  set menu(MenuBuilder? menu) => _$this._menu = menu;

  String? _etag;
  String? get etag => _$this._etag;
  set etag(String? etag) => _$this._etag = etag;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  int? _maxAgeSeconds;
  int? get maxAgeSeconds => _$this._maxAgeSeconds;
  set maxAgeSeconds(int? maxAgeSeconds) =>
      _$this._maxAgeSeconds = maxAgeSeconds;

  OfflineSnapshotBuilder() {
    OfflineSnapshot._defaults(this);
  }

  OfflineSnapshotBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _store = $v.store.toBuilder();
      _branch = $v.branch.toBuilder();
      _register = $v.register.toBuilder();
      _staff = $v.staff.toBuilder();
      _shift = $v.shift?.toBuilder();
      _offline = $v.offline.toBuilder();
      _menu = $v.menu?.toBuilder();
      _etag = $v.etag;
      _generatedAt = $v.generatedAt;
      _maxAgeSeconds = $v.maxAgeSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSnapshot other) {
    _$v = other as _$OfflineSnapshot;
  }

  @override
  void update(void Function(OfflineSnapshotBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSnapshot build() => _build();

  _$OfflineSnapshot _build() {
    _$OfflineSnapshot _$result;
    try {
      _$result = _$v ??
          _$OfflineSnapshot._(
            store: store.build(),
            branch: branch.build(),
            register: register.build(),
            staff: staff.build(),
            shift: _shift?.build(),
            offline: offline.build(),
            menu: _menu?.build(),
            etag: BuiltValueNullFieldError.checkNotNull(
                etag, r'OfflineSnapshot', 'etag'),
            generatedAt: BuiltValueNullFieldError.checkNotNull(
                generatedAt, r'OfflineSnapshot', 'generatedAt'),
            maxAgeSeconds: BuiltValueNullFieldError.checkNotNull(
                maxAgeSeconds, r'OfflineSnapshot', 'maxAgeSeconds'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'store';
        store.build();
        _$failedField = 'branch';
        branch.build();
        _$failedField = 'register';
        register.build();
        _$failedField = 'staff';
        staff.build();
        _$failedField = 'shift';
        _shift?.build();
        _$failedField = 'offline';
        offline.build();
        _$failedField = 'menu';
        _menu?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OfflineSnapshot', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
