// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_job.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintJobKindEnum _$printJobKindEnum_receipt =
    const PrintJobKindEnum._('receipt');
const PrintJobKindEnum _$printJobKindEnum_prebill =
    const PrintJobKindEnum._('prebill');
const PrintJobKindEnum _$printJobKindEnum_kitchenTicket =
    const PrintJobKindEnum._('kitchenTicket');
const PrintJobKindEnum _$printJobKindEnum_voidTicket =
    const PrintJobKindEnum._('voidTicket');
const PrintJobKindEnum _$printJobKindEnum_cupLabel =
    const PrintJobKindEnum._('cupLabel');
const PrintJobKindEnum _$printJobKindEnum_checklist =
    const PrintJobKindEnum._('checklist');
const PrintJobKindEnum _$printJobKindEnum_tableQr =
    const PrintJobKindEnum._('tableQr');
const PrintJobKindEnum _$printJobKindEnum_test =
    const PrintJobKindEnum._('test');

PrintJobKindEnum _$printJobKindEnumValueOf(String name) {
  switch (name) {
    case 'receipt':
      return _$printJobKindEnum_receipt;
    case 'prebill':
      return _$printJobKindEnum_prebill;
    case 'kitchenTicket':
      return _$printJobKindEnum_kitchenTicket;
    case 'voidTicket':
      return _$printJobKindEnum_voidTicket;
    case 'cupLabel':
      return _$printJobKindEnum_cupLabel;
    case 'checklist':
      return _$printJobKindEnum_checklist;
    case 'tableQr':
      return _$printJobKindEnum_tableQr;
    case 'test':
      return _$printJobKindEnum_test;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintJobKindEnum> _$printJobKindEnumValues =
    BuiltSet<PrintJobKindEnum>(const <PrintJobKindEnum>[
  _$printJobKindEnum_receipt,
  _$printJobKindEnum_prebill,
  _$printJobKindEnum_kitchenTicket,
  _$printJobKindEnum_voidTicket,
  _$printJobKindEnum_cupLabel,
  _$printJobKindEnum_checklist,
  _$printJobKindEnum_tableQr,
  _$printJobKindEnum_test,
]);

const PrintJobStatusEnum _$printJobStatusEnum_queued =
    const PrintJobStatusEnum._('queued');
const PrintJobStatusEnum _$printJobStatusEnum_claimed =
    const PrintJobStatusEnum._('claimed');
const PrintJobStatusEnum _$printJobStatusEnum_printed =
    const PrintJobStatusEnum._('printed');
const PrintJobStatusEnum _$printJobStatusEnum_failed =
    const PrintJobStatusEnum._('failed');
const PrintJobStatusEnum _$printJobStatusEnum_canceled =
    const PrintJobStatusEnum._('canceled');

PrintJobStatusEnum _$printJobStatusEnumValueOf(String name) {
  switch (name) {
    case 'queued':
      return _$printJobStatusEnum_queued;
    case 'claimed':
      return _$printJobStatusEnum_claimed;
    case 'printed':
      return _$printJobStatusEnum_printed;
    case 'failed':
      return _$printJobStatusEnum_failed;
    case 'canceled':
      return _$printJobStatusEnum_canceled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintJobStatusEnum> _$printJobStatusEnumValues =
    BuiltSet<PrintJobStatusEnum>(const <PrintJobStatusEnum>[
  _$printJobStatusEnum_queued,
  _$printJobStatusEnum_claimed,
  _$printJobStatusEnum_printed,
  _$printJobStatusEnum_failed,
  _$printJobStatusEnum_canceled,
]);

Serializer<PrintJobKindEnum> _$printJobKindEnumSerializer =
    _$PrintJobKindEnumSerializer();
Serializer<PrintJobStatusEnum> _$printJobStatusEnumSerializer =
    _$PrintJobStatusEnumSerializer();

class _$PrintJobKindEnumSerializer
    implements PrimitiveSerializer<PrintJobKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'receipt': 'receipt',
    'prebill': 'prebill',
    'kitchenTicket': 'kitchen_ticket',
    'voidTicket': 'void_ticket',
    'cupLabel': 'cup_label',
    'checklist': 'checklist',
    'tableQr': 'table_qr',
    'test': 'test',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'receipt': 'receipt',
    'prebill': 'prebill',
    'kitchen_ticket': 'kitchenTicket',
    'void_ticket': 'voidTicket',
    'cup_label': 'cupLabel',
    'checklist': 'checklist',
    'table_qr': 'tableQr',
    'test': 'test',
  };

  @override
  final Iterable<Type> types = const <Type>[PrintJobKindEnum];
  @override
  final String wireName = 'PrintJobKindEnum';

  @override
  Object serialize(Serializers serializers, PrintJobKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintJobKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintJobKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintJobStatusEnumSerializer
    implements PrimitiveSerializer<PrintJobStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
    'claimed': 'claimed',
    'printed': 'printed',
    'failed': 'failed',
    'canceled': 'canceled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
    'claimed': 'claimed',
    'printed': 'printed',
    'failed': 'failed',
    'canceled': 'canceled',
  };

  @override
  final Iterable<Type> types = const <Type>[PrintJobStatusEnum];
  @override
  final String wireName = 'PrintJobStatusEnum';

  @override
  Object serialize(Serializers serializers, PrintJobStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintJobStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintJobStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintJob extends PrintJob {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String printerId;
  @override
  final String printerName;
  @override
  final PrintJobKindEnum kind;
  @override
  final PrintJobStatusEnum status;
  @override
  final int attempts;
  @override
  final String? label;
  @override
  final String? lastError;
  @override
  final String? copyOfId;
  @override
  final String createdAt;
  @override
  final String? printedAt;
  @override
  final String? workspaceId;
  @override
  final int? sourceRevision;
  @override
  final bool printerAvailable;
  @override
  final bool reprinted;
  @override
  final PrintJobReprint? reprint;

  factory _$PrintJob([void Function(PrintJobBuilder)? updates]) =>
      (PrintJobBuilder()..update(updates))._build();

  _$PrintJob._(
      {required this.id,
      required this.branchId,
      required this.printerId,
      required this.printerName,
      required this.kind,
      required this.status,
      required this.attempts,
      this.label,
      this.lastError,
      this.copyOfId,
      required this.createdAt,
      this.printedAt,
      this.workspaceId,
      this.sourceRevision,
      required this.printerAvailable,
      required this.reprinted,
      this.reprint})
      : super._();
  @override
  PrintJob rebuild(void Function(PrintJobBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintJobBuilder toBuilder() => PrintJobBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintJob &&
        id == other.id &&
        branchId == other.branchId &&
        printerId == other.printerId &&
        printerName == other.printerName &&
        kind == other.kind &&
        status == other.status &&
        attempts == other.attempts &&
        label == other.label &&
        lastError == other.lastError &&
        copyOfId == other.copyOfId &&
        createdAt == other.createdAt &&
        printedAt == other.printedAt &&
        workspaceId == other.workspaceId &&
        sourceRevision == other.sourceRevision &&
        printerAvailable == other.printerAvailable &&
        reprinted == other.reprinted &&
        reprint == other.reprint;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, printerId.hashCode);
    _$hash = $jc(_$hash, printerName.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, lastError.hashCode);
    _$hash = $jc(_$hash, copyOfId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, printedAt.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, sourceRevision.hashCode);
    _$hash = $jc(_$hash, printerAvailable.hashCode);
    _$hash = $jc(_$hash, reprinted.hashCode);
    _$hash = $jc(_$hash, reprint.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintJob')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('printerId', printerId)
          ..add('printerName', printerName)
          ..add('kind', kind)
          ..add('status', status)
          ..add('attempts', attempts)
          ..add('label', label)
          ..add('lastError', lastError)
          ..add('copyOfId', copyOfId)
          ..add('createdAt', createdAt)
          ..add('printedAt', printedAt)
          ..add('workspaceId', workspaceId)
          ..add('sourceRevision', sourceRevision)
          ..add('printerAvailable', printerAvailable)
          ..add('reprinted', reprinted)
          ..add('reprint', reprint))
        .toString();
  }
}

class PrintJobBuilder implements Builder<PrintJob, PrintJobBuilder> {
  _$PrintJob? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(String? printerId) => _$this._printerId = printerId;

  String? _printerName;
  String? get printerName => _$this._printerName;
  set printerName(String? printerName) => _$this._printerName = printerName;

  PrintJobKindEnum? _kind;
  PrintJobKindEnum? get kind => _$this._kind;
  set kind(PrintJobKindEnum? kind) => _$this._kind = kind;

  PrintJobStatusEnum? _status;
  PrintJobStatusEnum? get status => _$this._status;
  set status(PrintJobStatusEnum? status) => _$this._status = status;

  int? _attempts;
  int? get attempts => _$this._attempts;
  set attempts(int? attempts) => _$this._attempts = attempts;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _lastError;
  String? get lastError => _$this._lastError;
  set lastError(String? lastError) => _$this._lastError = lastError;

  String? _copyOfId;
  String? get copyOfId => _$this._copyOfId;
  set copyOfId(String? copyOfId) => _$this._copyOfId = copyOfId;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  String? _printedAt;
  String? get printedAt => _$this._printedAt;
  set printedAt(String? printedAt) => _$this._printedAt = printedAt;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  int? _sourceRevision;
  int? get sourceRevision => _$this._sourceRevision;
  set sourceRevision(int? sourceRevision) =>
      _$this._sourceRevision = sourceRevision;

  bool? _printerAvailable;
  bool? get printerAvailable => _$this._printerAvailable;
  set printerAvailable(bool? printerAvailable) =>
      _$this._printerAvailable = printerAvailable;

  bool? _reprinted;
  bool? get reprinted => _$this._reprinted;
  set reprinted(bool? reprinted) => _$this._reprinted = reprinted;

  PrintJobReprintBuilder? _reprint;
  PrintJobReprintBuilder get reprint =>
      _$this._reprint ??= PrintJobReprintBuilder();
  set reprint(PrintJobReprintBuilder? reprint) => _$this._reprint = reprint;

  PrintJobBuilder() {
    PrintJob._defaults(this);
  }

  PrintJobBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _printerId = $v.printerId;
      _printerName = $v.printerName;
      _kind = $v.kind;
      _status = $v.status;
      _attempts = $v.attempts;
      _label = $v.label;
      _lastError = $v.lastError;
      _copyOfId = $v.copyOfId;
      _createdAt = $v.createdAt;
      _printedAt = $v.printedAt;
      _workspaceId = $v.workspaceId;
      _sourceRevision = $v.sourceRevision;
      _printerAvailable = $v.printerAvailable;
      _reprinted = $v.reprinted;
      _reprint = $v.reprint?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintJob other) {
    _$v = other as _$PrintJob;
  }

  @override
  void update(void Function(PrintJobBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintJob build() => _build();

  _$PrintJob _build() {
    _$PrintJob _$result;
    try {
      _$result = _$v ??
          _$PrintJob._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'PrintJob', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'PrintJob', 'branchId'),
            printerId: BuiltValueNullFieldError.checkNotNull(
                printerId, r'PrintJob', 'printerId'),
            printerName: BuiltValueNullFieldError.checkNotNull(
                printerName, r'PrintJob', 'printerName'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'PrintJob', 'kind'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'PrintJob', 'status'),
            attempts: BuiltValueNullFieldError.checkNotNull(
                attempts, r'PrintJob', 'attempts'),
            label: label,
            lastError: lastError,
            copyOfId: copyOfId,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'PrintJob', 'createdAt'),
            printedAt: printedAt,
            workspaceId: workspaceId,
            sourceRevision: sourceRevision,
            printerAvailable: BuiltValueNullFieldError.checkNotNull(
                printerAvailable, r'PrintJob', 'printerAvailable'),
            reprinted: BuiltValueNullFieldError.checkNotNull(
                reprinted, r'PrintJob', 'reprinted'),
            reprint: _reprint?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'reprint';
        _reprint?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintJob', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
