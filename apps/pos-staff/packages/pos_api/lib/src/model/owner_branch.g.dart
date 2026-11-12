// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_branch.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnerBranch extends OwnerBranch {
  @override
  final String id;
  @override
  final String name;
  @override
  final String code;
  @override
  final String timezone;
  @override
  final bool canReadReports;
  @override
  final bool canApprove;
  @override
  final bool canManageReservations;

  factory _$OwnerBranch([void Function(OwnerBranchBuilder)? updates]) =>
      (OwnerBranchBuilder()..update(updates))._build();

  _$OwnerBranch._(
      {required this.id,
      required this.name,
      required this.code,
      required this.timezone,
      required this.canReadReports,
      required this.canApprove,
      required this.canManageReservations})
      : super._();
  @override
  OwnerBranch rebuild(void Function(OwnerBranchBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerBranchBuilder toBuilder() => OwnerBranchBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerBranch &&
        id == other.id &&
        name == other.name &&
        code == other.code &&
        timezone == other.timezone &&
        canReadReports == other.canReadReports &&
        canApprove == other.canApprove &&
        canManageReservations == other.canManageReservations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, canReadReports.hashCode);
    _$hash = $jc(_$hash, canApprove.hashCode);
    _$hash = $jc(_$hash, canManageReservations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnerBranch')
          ..add('id', id)
          ..add('name', name)
          ..add('code', code)
          ..add('timezone', timezone)
          ..add('canReadReports', canReadReports)
          ..add('canApprove', canApprove)
          ..add('canManageReservations', canManageReservations))
        .toString();
  }
}

class OwnerBranchBuilder implements Builder<OwnerBranch, OwnerBranchBuilder> {
  _$OwnerBranch? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  bool? _canReadReports;
  bool? get canReadReports => _$this._canReadReports;
  set canReadReports(bool? canReadReports) =>
      _$this._canReadReports = canReadReports;

  bool? _canApprove;
  bool? get canApprove => _$this._canApprove;
  set canApprove(bool? canApprove) => _$this._canApprove = canApprove;

  bool? _canManageReservations;
  bool? get canManageReservations => _$this._canManageReservations;
  set canManageReservations(bool? canManageReservations) =>
      _$this._canManageReservations = canManageReservations;

  OwnerBranchBuilder() {
    OwnerBranch._defaults(this);
  }

  OwnerBranchBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _code = $v.code;
      _timezone = $v.timezone;
      _canReadReports = $v.canReadReports;
      _canApprove = $v.canApprove;
      _canManageReservations = $v.canManageReservations;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerBranch other) {
    _$v = other as _$OwnerBranch;
  }

  @override
  void update(void Function(OwnerBranchBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerBranch build() => _build();

  _$OwnerBranch _build() {
    final _$result = _$v ??
        _$OwnerBranch._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'OwnerBranch', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'OwnerBranch', 'name'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'OwnerBranch', 'code'),
          timezone: BuiltValueNullFieldError.checkNotNull(
              timezone, r'OwnerBranch', 'timezone'),
          canReadReports: BuiltValueNullFieldError.checkNotNull(
              canReadReports, r'OwnerBranch', 'canReadReports'),
          canApprove: BuiltValueNullFieldError.checkNotNull(
              canApprove, r'OwnerBranch', 'canApprove'),
          canManageReservations: BuiltValueNullFieldError.checkNotNull(
              canManageReservations, r'OwnerBranch', 'canManageReservations'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
