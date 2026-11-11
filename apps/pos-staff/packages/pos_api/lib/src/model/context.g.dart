// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ContextEinvoiceTypeEnum _$contextEinvoiceTypeEnum_none =
    const ContextEinvoiceTypeEnum._('none');
const ContextEinvoiceTypeEnum _$contextEinvoiceTypeEnum_cashRegister =
    const ContextEinvoiceTypeEnum._('cashRegister');
const ContextEinvoiceTypeEnum _$contextEinvoiceTypeEnum_coded =
    const ContextEinvoiceTypeEnum._('coded');

ContextEinvoiceTypeEnum _$contextEinvoiceTypeEnumValueOf(String name) {
  switch (name) {
    case 'none':
      return _$contextEinvoiceTypeEnum_none;
    case 'cashRegister':
      return _$contextEinvoiceTypeEnum_cashRegister;
    case 'coded':
      return _$contextEinvoiceTypeEnum_coded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ContextEinvoiceTypeEnum> _$contextEinvoiceTypeEnumValues =
    BuiltSet<ContextEinvoiceTypeEnum>(const <ContextEinvoiceTypeEnum>[
  _$contextEinvoiceTypeEnum_none,
  _$contextEinvoiceTypeEnum_cashRegister,
  _$contextEinvoiceTypeEnum_coded,
]);

Serializer<ContextEinvoiceTypeEnum> _$contextEinvoiceTypeEnumSerializer =
    _$ContextEinvoiceTypeEnumSerializer();

class _$ContextEinvoiceTypeEnumSerializer
    implements PrimitiveSerializer<ContextEinvoiceTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'none': 'none',
    'cashRegister': 'cash_register',
    'coded': 'coded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'none': 'none',
    'cash_register': 'cashRegister',
    'coded': 'coded',
  };

  @override
  final Iterable<Type> types = const <Type>[ContextEinvoiceTypeEnum];
  @override
  final String wireName = 'ContextEinvoiceTypeEnum';

  @override
  Object serialize(Serializers serializers, ContextEinvoiceTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ContextEinvoiceTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ContextEinvoiceTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Context extends Context {
  @override
  final BuiltList<String> capabilities;
  @override
  final ContextStaff staff;
  @override
  final ContextStore store;
  @override
  final ContextAdministration administration;
  @override
  final ContextEinvoiceTypeEnum? einvoiceType;
  @override
  final BuiltMap<String, bool>? modules;
  @override
  final BuiltList<ContextBranch>? branches;

  factory _$Context([void Function(ContextBuilder)? updates]) =>
      (ContextBuilder()..update(updates))._build();

  _$Context._(
      {required this.capabilities,
      required this.staff,
      required this.store,
      required this.administration,
      this.einvoiceType,
      this.modules,
      this.branches})
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
        administration == other.administration &&
        einvoiceType == other.einvoiceType &&
        modules == other.modules &&
        branches == other.branches;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, capabilities.hashCode);
    _$hash = $jc(_$hash, staff.hashCode);
    _$hash = $jc(_$hash, store.hashCode);
    _$hash = $jc(_$hash, administration.hashCode);
    _$hash = $jc(_$hash, einvoiceType.hashCode);
    _$hash = $jc(_$hash, modules.hashCode);
    _$hash = $jc(_$hash, branches.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Context')
          ..add('capabilities', capabilities)
          ..add('staff', staff)
          ..add('store', store)
          ..add('administration', administration)
          ..add('einvoiceType', einvoiceType)
          ..add('modules', modules)
          ..add('branches', branches))
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

  ContextEinvoiceTypeEnum? _einvoiceType;
  ContextEinvoiceTypeEnum? get einvoiceType => _$this._einvoiceType;
  set einvoiceType(ContextEinvoiceTypeEnum? einvoiceType) =>
      _$this._einvoiceType = einvoiceType;

  MapBuilder<String, bool>? _modules;
  MapBuilder<String, bool> get modules =>
      _$this._modules ??= MapBuilder<String, bool>();
  set modules(MapBuilder<String, bool>? modules) => _$this._modules = modules;

  ListBuilder<ContextBranch>? _branches;
  ListBuilder<ContextBranch> get branches =>
      _$this._branches ??= ListBuilder<ContextBranch>();
  set branches(ListBuilder<ContextBranch>? branches) =>
      _$this._branches = branches;

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
      _einvoiceType = $v.einvoiceType;
      _modules = $v.modules?.toBuilder();
      _branches = $v.branches?.toBuilder();
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
            einvoiceType: einvoiceType,
            modules: _modules?.build(),
            branches: _branches?.build(),
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

        _$failedField = 'modules';
        _modules?.build();
        _$failedField = 'branches';
        _branches?.build();
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
