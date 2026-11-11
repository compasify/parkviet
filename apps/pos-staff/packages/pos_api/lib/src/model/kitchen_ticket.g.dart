// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KitchenTicketStationKindEnum _$kitchenTicketStationKindEnum_prep =
    const KitchenTicketStationKindEnum._('prep');
const KitchenTicketStationKindEnum _$kitchenTicketStationKindEnum_bar =
    const KitchenTicketStationKindEnum._('bar');
const KitchenTicketStationKindEnum _$kitchenTicketStationKindEnum_expo =
    const KitchenTicketStationKindEnum._('expo');

KitchenTicketStationKindEnum _$kitchenTicketStationKindEnumValueOf(
    String name) {
  switch (name) {
    case 'prep':
      return _$kitchenTicketStationKindEnum_prep;
    case 'bar':
      return _$kitchenTicketStationKindEnum_bar;
    case 'expo':
      return _$kitchenTicketStationKindEnum_expo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KitchenTicketStationKindEnum>
    _$kitchenTicketStationKindEnumValues =
    BuiltSet<KitchenTicketStationKindEnum>(const <KitchenTicketStationKindEnum>[
  _$kitchenTicketStationKindEnum_prep,
  _$kitchenTicketStationKindEnum_bar,
  _$kitchenTicketStationKindEnum_expo,
]);

const KitchenTicketKindEnum _$kitchenTicketKindEnum_fire =
    const KitchenTicketKindEnum._('fire');
const KitchenTicketKindEnum _$kitchenTicketKindEnum_void_ =
    const KitchenTicketKindEnum._('void_');

KitchenTicketKindEnum _$kitchenTicketKindEnumValueOf(String name) {
  switch (name) {
    case 'fire':
      return _$kitchenTicketKindEnum_fire;
    case 'void_':
      return _$kitchenTicketKindEnum_void_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KitchenTicketKindEnum> _$kitchenTicketKindEnumValues =
    BuiltSet<KitchenTicketKindEnum>(const <KitchenTicketKindEnum>[
  _$kitchenTicketKindEnum_fire,
  _$kitchenTicketKindEnum_void_,
]);

Serializer<KitchenTicketStationKindEnum>
    _$kitchenTicketStationKindEnumSerializer =
    _$KitchenTicketStationKindEnumSerializer();
Serializer<KitchenTicketKindEnum> _$kitchenTicketKindEnumSerializer =
    _$KitchenTicketKindEnumSerializer();

class _$KitchenTicketStationKindEnumSerializer
    implements PrimitiveSerializer<KitchenTicketStationKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'prep': 'prep',
    'bar': 'bar',
    'expo': 'expo',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'prep': 'prep',
    'bar': 'bar',
    'expo': 'expo',
  };

  @override
  final Iterable<Type> types = const <Type>[KitchenTicketStationKindEnum];
  @override
  final String wireName = 'KitchenTicketStationKindEnum';

  @override
  Object serialize(Serializers serializers, KitchenTicketStationKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KitchenTicketStationKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KitchenTicketStationKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KitchenTicketKindEnumSerializer
    implements PrimitiveSerializer<KitchenTicketKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fire': 'fire',
    'void_': 'void',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fire': 'fire',
    'void': 'void_',
  };

  @override
  final Iterable<Type> types = const <Type>[KitchenTicketKindEnum];
  @override
  final String wireName = 'KitchenTicketKindEnum';

  @override
  Object serialize(Serializers serializers, KitchenTicketKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KitchenTicketKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KitchenTicketKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KitchenTicket extends KitchenTicket {
  @override
  final String id;
  @override
  final String workspaceId;
  @override
  final String branchId;
  @override
  final String kitchenStationId;
  @override
  final String stationName;
  @override
  final KitchenTicketStationKindEnum stationKind;
  @override
  final int sequence;
  @override
  final KitchenTicketKindEnum kind;
  @override
  final String serviceMode;
  @override
  final Date businessDate;
  @override
  final BuiltMap<String, JsonObject?> header;
  @override
  final DateTime sentAt;
  @override
  final bool done;
  @override
  final DateTime? doneAt;
  @override
  final BuiltList<KitchenTicketItem> items;

  factory _$KitchenTicket([void Function(KitchenTicketBuilder)? updates]) =>
      (KitchenTicketBuilder()..update(updates))._build();

  _$KitchenTicket._(
      {required this.id,
      required this.workspaceId,
      required this.branchId,
      required this.kitchenStationId,
      required this.stationName,
      required this.stationKind,
      required this.sequence,
      required this.kind,
      required this.serviceMode,
      required this.businessDate,
      required this.header,
      required this.sentAt,
      required this.done,
      this.doneAt,
      required this.items})
      : super._();
  @override
  KitchenTicket rebuild(void Function(KitchenTicketBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenTicketBuilder toBuilder() => KitchenTicketBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenTicket &&
        id == other.id &&
        workspaceId == other.workspaceId &&
        branchId == other.branchId &&
        kitchenStationId == other.kitchenStationId &&
        stationName == other.stationName &&
        stationKind == other.stationKind &&
        sequence == other.sequence &&
        kind == other.kind &&
        serviceMode == other.serviceMode &&
        businessDate == other.businessDate &&
        header == other.header &&
        sentAt == other.sentAt &&
        done == other.done &&
        doneAt == other.doneAt &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, kitchenStationId.hashCode);
    _$hash = $jc(_$hash, stationName.hashCode);
    _$hash = $jc(_$hash, stationKind.hashCode);
    _$hash = $jc(_$hash, sequence.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jc(_$hash, businessDate.hashCode);
    _$hash = $jc(_$hash, header.hashCode);
    _$hash = $jc(_$hash, sentAt.hashCode);
    _$hash = $jc(_$hash, done.hashCode);
    _$hash = $jc(_$hash, doneAt.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenTicket')
          ..add('id', id)
          ..add('workspaceId', workspaceId)
          ..add('branchId', branchId)
          ..add('kitchenStationId', kitchenStationId)
          ..add('stationName', stationName)
          ..add('stationKind', stationKind)
          ..add('sequence', sequence)
          ..add('kind', kind)
          ..add('serviceMode', serviceMode)
          ..add('businessDate', businessDate)
          ..add('header', header)
          ..add('sentAt', sentAt)
          ..add('done', done)
          ..add('doneAt', doneAt)
          ..add('items', items))
        .toString();
  }
}

class KitchenTicketBuilder
    implements Builder<KitchenTicket, KitchenTicketBuilder> {
  _$KitchenTicket? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _kitchenStationId;
  String? get kitchenStationId => _$this._kitchenStationId;
  set kitchenStationId(String? kitchenStationId) =>
      _$this._kitchenStationId = kitchenStationId;

  String? _stationName;
  String? get stationName => _$this._stationName;
  set stationName(String? stationName) => _$this._stationName = stationName;

  KitchenTicketStationKindEnum? _stationKind;
  KitchenTicketStationKindEnum? get stationKind => _$this._stationKind;
  set stationKind(KitchenTicketStationKindEnum? stationKind) =>
      _$this._stationKind = stationKind;

  int? _sequence;
  int? get sequence => _$this._sequence;
  set sequence(int? sequence) => _$this._sequence = sequence;

  KitchenTicketKindEnum? _kind;
  KitchenTicketKindEnum? get kind => _$this._kind;
  set kind(KitchenTicketKindEnum? kind) => _$this._kind = kind;

  String? _serviceMode;
  String? get serviceMode => _$this._serviceMode;
  set serviceMode(String? serviceMode) => _$this._serviceMode = serviceMode;

  Date? _businessDate;
  Date? get businessDate => _$this._businessDate;
  set businessDate(Date? businessDate) => _$this._businessDate = businessDate;

  MapBuilder<String, JsonObject?>? _header;
  MapBuilder<String, JsonObject?> get header =>
      _$this._header ??= MapBuilder<String, JsonObject?>();
  set header(MapBuilder<String, JsonObject?>? header) =>
      _$this._header = header;

  DateTime? _sentAt;
  DateTime? get sentAt => _$this._sentAt;
  set sentAt(DateTime? sentAt) => _$this._sentAt = sentAt;

  bool? _done;
  bool? get done => _$this._done;
  set done(bool? done) => _$this._done = done;

  DateTime? _doneAt;
  DateTime? get doneAt => _$this._doneAt;
  set doneAt(DateTime? doneAt) => _$this._doneAt = doneAt;

  ListBuilder<KitchenTicketItem>? _items;
  ListBuilder<KitchenTicketItem> get items =>
      _$this._items ??= ListBuilder<KitchenTicketItem>();
  set items(ListBuilder<KitchenTicketItem>? items) => _$this._items = items;

  KitchenTicketBuilder() {
    KitchenTicket._defaults(this);
  }

  KitchenTicketBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _workspaceId = $v.workspaceId;
      _branchId = $v.branchId;
      _kitchenStationId = $v.kitchenStationId;
      _stationName = $v.stationName;
      _stationKind = $v.stationKind;
      _sequence = $v.sequence;
      _kind = $v.kind;
      _serviceMode = $v.serviceMode;
      _businessDate = $v.businessDate;
      _header = $v.header.toBuilder();
      _sentAt = $v.sentAt;
      _done = $v.done;
      _doneAt = $v.doneAt;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenTicket other) {
    _$v = other as _$KitchenTicket;
  }

  @override
  void update(void Function(KitchenTicketBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenTicket build() => _build();

  _$KitchenTicket _build() {
    _$KitchenTicket _$result;
    try {
      _$result = _$v ??
          _$KitchenTicket._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'KitchenTicket', 'id'),
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'KitchenTicket', 'workspaceId'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'KitchenTicket', 'branchId'),
            kitchenStationId: BuiltValueNullFieldError.checkNotNull(
                kitchenStationId, r'KitchenTicket', 'kitchenStationId'),
            stationName: BuiltValueNullFieldError.checkNotNull(
                stationName, r'KitchenTicket', 'stationName'),
            stationKind: BuiltValueNullFieldError.checkNotNull(
                stationKind, r'KitchenTicket', 'stationKind'),
            sequence: BuiltValueNullFieldError.checkNotNull(
                sequence, r'KitchenTicket', 'sequence'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'KitchenTicket', 'kind'),
            serviceMode: BuiltValueNullFieldError.checkNotNull(
                serviceMode, r'KitchenTicket', 'serviceMode'),
            businessDate: BuiltValueNullFieldError.checkNotNull(
                businessDate, r'KitchenTicket', 'businessDate'),
            header: header.build(),
            sentAt: BuiltValueNullFieldError.checkNotNull(
                sentAt, r'KitchenTicket', 'sentAt'),
            done: BuiltValueNullFieldError.checkNotNull(
                done, r'KitchenTicket', 'done'),
            doneAt: doneAt,
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'header';
        header.build();

        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenTicket', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
