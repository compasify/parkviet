// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_prebill.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkspacePrebillStatusEnum _$workspacePrebillStatusEnum_current =
    const WorkspacePrebillStatusEnum._('current');
const WorkspacePrebillStatusEnum _$workspacePrebillStatusEnum_superseded =
    const WorkspacePrebillStatusEnum._('superseded');
const WorkspacePrebillStatusEnum _$workspacePrebillStatusEnum_canceled =
    const WorkspacePrebillStatusEnum._('canceled');

WorkspacePrebillStatusEnum _$workspacePrebillStatusEnumValueOf(String name) {
  switch (name) {
    case 'current':
      return _$workspacePrebillStatusEnum_current;
    case 'superseded':
      return _$workspacePrebillStatusEnum_superseded;
    case 'canceled':
      return _$workspacePrebillStatusEnum_canceled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkspacePrebillStatusEnum> _$workspacePrebillStatusEnumValues =
    BuiltSet<WorkspacePrebillStatusEnum>(const <WorkspacePrebillStatusEnum>[
  _$workspacePrebillStatusEnum_current,
  _$workspacePrebillStatusEnum_superseded,
  _$workspacePrebillStatusEnum_canceled,
]);

Serializer<WorkspacePrebillStatusEnum> _$workspacePrebillStatusEnumSerializer =
    _$WorkspacePrebillStatusEnumSerializer();

class _$WorkspacePrebillStatusEnumSerializer
    implements PrimitiveSerializer<WorkspacePrebillStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'current': 'current',
    'superseded': 'superseded',
    'canceled': 'canceled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'current': 'current',
    'superseded': 'superseded',
    'canceled': 'canceled',
  };

  @override
  final Iterable<Type> types = const <Type>[WorkspacePrebillStatusEnum];
  @override
  final String wireName = 'WorkspacePrebillStatusEnum';

  @override
  Object serialize(Serializers serializers, WorkspacePrebillStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkspacePrebillStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkspacePrebillStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkspacePrebill extends WorkspacePrebill {
  @override
  final String id;
  @override
  final int sequence;
  @override
  final int revision;
  @override
  final WorkspacePrebillStatusEnum status;
  @override
  final String total;
  @override
  final String currency;
  @override
  final String staffId;
  @override
  final String? approvalId;
  @override
  final DateTime printedAt;
  @override
  final bool? stale;

  factory _$WorkspacePrebill(
          [void Function(WorkspacePrebillBuilder)? updates]) =>
      (WorkspacePrebillBuilder()..update(updates))._build();

  _$WorkspacePrebill._(
      {required this.id,
      required this.sequence,
      required this.revision,
      required this.status,
      required this.total,
      required this.currency,
      required this.staffId,
      this.approvalId,
      required this.printedAt,
      this.stale})
      : super._();
  @override
  WorkspacePrebill rebuild(void Function(WorkspacePrebillBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspacePrebillBuilder toBuilder() =>
      WorkspacePrebillBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspacePrebill &&
        id == other.id &&
        sequence == other.sequence &&
        revision == other.revision &&
        status == other.status &&
        total == other.total &&
        currency == other.currency &&
        staffId == other.staffId &&
        approvalId == other.approvalId &&
        printedAt == other.printedAt &&
        stale == other.stale;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, sequence.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, staffId.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, printedAt.hashCode);
    _$hash = $jc(_$hash, stale.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspacePrebill')
          ..add('id', id)
          ..add('sequence', sequence)
          ..add('revision', revision)
          ..add('status', status)
          ..add('total', total)
          ..add('currency', currency)
          ..add('staffId', staffId)
          ..add('approvalId', approvalId)
          ..add('printedAt', printedAt)
          ..add('stale', stale))
        .toString();
  }
}

class WorkspacePrebillBuilder
    implements Builder<WorkspacePrebill, WorkspacePrebillBuilder> {
  _$WorkspacePrebill? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _sequence;
  int? get sequence => _$this._sequence;
  set sequence(int? sequence) => _$this._sequence = sequence;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  WorkspacePrebillStatusEnum? _status;
  WorkspacePrebillStatusEnum? get status => _$this._status;
  set status(WorkspacePrebillStatusEnum? status) => _$this._status = status;

  String? _total;
  String? get total => _$this._total;
  set total(String? total) => _$this._total = total;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  String? _staffId;
  String? get staffId => _$this._staffId;
  set staffId(String? staffId) => _$this._staffId = staffId;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  DateTime? _printedAt;
  DateTime? get printedAt => _$this._printedAt;
  set printedAt(DateTime? printedAt) => _$this._printedAt = printedAt;

  bool? _stale;
  bool? get stale => _$this._stale;
  set stale(bool? stale) => _$this._stale = stale;

  WorkspacePrebillBuilder() {
    WorkspacePrebill._defaults(this);
  }

  WorkspacePrebillBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _sequence = $v.sequence;
      _revision = $v.revision;
      _status = $v.status;
      _total = $v.total;
      _currency = $v.currency;
      _staffId = $v.staffId;
      _approvalId = $v.approvalId;
      _printedAt = $v.printedAt;
      _stale = $v.stale;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspacePrebill other) {
    _$v = other as _$WorkspacePrebill;
  }

  @override
  void update(void Function(WorkspacePrebillBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspacePrebill build() => _build();

  _$WorkspacePrebill _build() {
    final _$result = _$v ??
        _$WorkspacePrebill._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'WorkspacePrebill', 'id'),
          sequence: BuiltValueNullFieldError.checkNotNull(
              sequence, r'WorkspacePrebill', 'sequence'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'WorkspacePrebill', 'revision'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'WorkspacePrebill', 'status'),
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'WorkspacePrebill', 'total'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'WorkspacePrebill', 'currency'),
          staffId: BuiltValueNullFieldError.checkNotNull(
              staffId, r'WorkspacePrebill', 'staffId'),
          approvalId: approvalId,
          printedAt: BuiltValueNullFieldError.checkNotNull(
              printedAt, r'WorkspacePrebill', 'printedAt'),
          stale: stale,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
