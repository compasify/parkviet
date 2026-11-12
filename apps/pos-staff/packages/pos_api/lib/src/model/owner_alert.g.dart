// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_alert.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OwnerAlertKindEnum _$ownerAlertKindEnum_kitchenLate =
    const OwnerAlertKindEnum._('kitchenLate');
const OwnerAlertKindEnum _$ownerAlertKindEnum_shiftVariance =
    const OwnerAlertKindEnum._('shiftVariance');
const OwnerAlertKindEnum _$ownerAlertKindEnum_voidBurst =
    const OwnerAlertKindEnum._('voidBurst');
const OwnerAlertKindEnum _$ownerAlertKindEnum_revenueMilestone =
    const OwnerAlertKindEnum._('revenueMilestone');
const OwnerAlertKindEnum _$ownerAlertKindEnum_printFailed =
    const OwnerAlertKindEnum._('printFailed');
const OwnerAlertKindEnum _$ownerAlertKindEnum_einvoiceFailed =
    const OwnerAlertKindEnum._('einvoiceFailed');

OwnerAlertKindEnum _$ownerAlertKindEnumValueOf(String name) {
  switch (name) {
    case 'kitchenLate':
      return _$ownerAlertKindEnum_kitchenLate;
    case 'shiftVariance':
      return _$ownerAlertKindEnum_shiftVariance;
    case 'voidBurst':
      return _$ownerAlertKindEnum_voidBurst;
    case 'revenueMilestone':
      return _$ownerAlertKindEnum_revenueMilestone;
    case 'printFailed':
      return _$ownerAlertKindEnum_printFailed;
    case 'einvoiceFailed':
      return _$ownerAlertKindEnum_einvoiceFailed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OwnerAlertKindEnum> _$ownerAlertKindEnumValues =
    BuiltSet<OwnerAlertKindEnum>(const <OwnerAlertKindEnum>[
  _$ownerAlertKindEnum_kitchenLate,
  _$ownerAlertKindEnum_shiftVariance,
  _$ownerAlertKindEnum_voidBurst,
  _$ownerAlertKindEnum_revenueMilestone,
  _$ownerAlertKindEnum_printFailed,
  _$ownerAlertKindEnum_einvoiceFailed,
]);

Serializer<OwnerAlertKindEnum> _$ownerAlertKindEnumSerializer =
    _$OwnerAlertKindEnumSerializer();

class _$OwnerAlertKindEnumSerializer
    implements PrimitiveSerializer<OwnerAlertKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'kitchenLate': 'kitchen_late',
    'shiftVariance': 'shift_variance',
    'voidBurst': 'void_burst',
    'revenueMilestone': 'revenue_milestone',
    'printFailed': 'print_failed',
    'einvoiceFailed': 'einvoice_failed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'kitchen_late': 'kitchenLate',
    'shift_variance': 'shiftVariance',
    'void_burst': 'voidBurst',
    'revenue_milestone': 'revenueMilestone',
    'print_failed': 'printFailed',
    'einvoice_failed': 'einvoiceFailed',
  };

  @override
  final Iterable<Type> types = const <Type>[OwnerAlertKindEnum];
  @override
  final String wireName = 'OwnerAlertKindEnum';

  @override
  Object serialize(Serializers serializers, OwnerAlertKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OwnerAlertKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OwnerAlertKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OwnerAlert extends OwnerAlert {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final OwnerAlertKindEnum kind;
  @override
  final String? subjectId;
  @override
  final BuiltMap<String, JsonObject?> details;
  @override
  final DateTime occurredAt;

  factory _$OwnerAlert([void Function(OwnerAlertBuilder)? updates]) =>
      (OwnerAlertBuilder()..update(updates))._build();

  _$OwnerAlert._(
      {required this.id,
      required this.branchId,
      required this.kind,
      this.subjectId,
      required this.details,
      required this.occurredAt})
      : super._();
  @override
  OwnerAlert rebuild(void Function(OwnerAlertBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerAlertBuilder toBuilder() => OwnerAlertBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerAlert &&
        id == other.id &&
        branchId == other.branchId &&
        kind == other.kind &&
        subjectId == other.subjectId &&
        details == other.details &&
        occurredAt == other.occurredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, subjectId.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jc(_$hash, occurredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OwnerAlert')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('kind', kind)
          ..add('subjectId', subjectId)
          ..add('details', details)
          ..add('occurredAt', occurredAt))
        .toString();
  }
}

class OwnerAlertBuilder implements Builder<OwnerAlert, OwnerAlertBuilder> {
  _$OwnerAlert? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  OwnerAlertKindEnum? _kind;
  OwnerAlertKindEnum? get kind => _$this._kind;
  set kind(OwnerAlertKindEnum? kind) => _$this._kind = kind;

  String? _subjectId;
  String? get subjectId => _$this._subjectId;
  set subjectId(String? subjectId) => _$this._subjectId = subjectId;

  MapBuilder<String, JsonObject?>? _details;
  MapBuilder<String, JsonObject?> get details =>
      _$this._details ??= MapBuilder<String, JsonObject?>();
  set details(MapBuilder<String, JsonObject?>? details) =>
      _$this._details = details;

  DateTime? _occurredAt;
  DateTime? get occurredAt => _$this._occurredAt;
  set occurredAt(DateTime? occurredAt) => _$this._occurredAt = occurredAt;

  OwnerAlertBuilder() {
    OwnerAlert._defaults(this);
  }

  OwnerAlertBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _kind = $v.kind;
      _subjectId = $v.subjectId;
      _details = $v.details.toBuilder();
      _occurredAt = $v.occurredAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerAlert other) {
    _$v = other as _$OwnerAlert;
  }

  @override
  void update(void Function(OwnerAlertBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerAlert build() => _build();

  _$OwnerAlert _build() {
    _$OwnerAlert _$result;
    try {
      _$result = _$v ??
          _$OwnerAlert._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'OwnerAlert', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'OwnerAlert', 'branchId'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'OwnerAlert', 'kind'),
            subjectId: subjectId,
            details: details.build(),
            occurredAt: BuiltValueNullFieldError.checkNotNull(
                occurredAt, r'OwnerAlert', 'occurredAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'details';
        details.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OwnerAlert', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
