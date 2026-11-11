// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KitchenTicketItemStatusEnum _$kitchenTicketItemStatusEnum_new_ =
    const KitchenTicketItemStatusEnum._('new_');
const KitchenTicketItemStatusEnum _$kitchenTicketItemStatusEnum_preparing =
    const KitchenTicketItemStatusEnum._('preparing');
const KitchenTicketItemStatusEnum _$kitchenTicketItemStatusEnum_ready =
    const KitchenTicketItemStatusEnum._('ready');
const KitchenTicketItemStatusEnum _$kitchenTicketItemStatusEnum_served =
    const KitchenTicketItemStatusEnum._('served');
const KitchenTicketItemStatusEnum _$kitchenTicketItemStatusEnum_voided =
    const KitchenTicketItemStatusEnum._('voided');

KitchenTicketItemStatusEnum _$kitchenTicketItemStatusEnumValueOf(String name) {
  switch (name) {
    case 'new_':
      return _$kitchenTicketItemStatusEnum_new_;
    case 'preparing':
      return _$kitchenTicketItemStatusEnum_preparing;
    case 'ready':
      return _$kitchenTicketItemStatusEnum_ready;
    case 'served':
      return _$kitchenTicketItemStatusEnum_served;
    case 'voided':
      return _$kitchenTicketItemStatusEnum_voided;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KitchenTicketItemStatusEnum>
    _$kitchenTicketItemStatusEnumValues =
    BuiltSet<KitchenTicketItemStatusEnum>(const <KitchenTicketItemStatusEnum>[
  _$kitchenTicketItemStatusEnum_new_,
  _$kitchenTicketItemStatusEnum_preparing,
  _$kitchenTicketItemStatusEnum_ready,
  _$kitchenTicketItemStatusEnum_served,
  _$kitchenTicketItemStatusEnum_voided,
]);

Serializer<KitchenTicketItemStatusEnum>
    _$kitchenTicketItemStatusEnumSerializer =
    _$KitchenTicketItemStatusEnumSerializer();

class _$KitchenTicketItemStatusEnumSerializer
    implements PrimitiveSerializer<KitchenTicketItemStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'new_': 'new',
    'preparing': 'preparing',
    'ready': 'ready',
    'served': 'served',
    'voided': 'voided',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'new': 'new_',
    'preparing': 'preparing',
    'ready': 'ready',
    'served': 'served',
    'voided': 'voided',
  };

  @override
  final Iterable<Type> types = const <Type>[KitchenTicketItemStatusEnum];
  @override
  final String wireName = 'KitchenTicketItemStatusEnum';

  @override
  Object serialize(Serializers serializers, KitchenTicketItemStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KitchenTicketItemStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KitchenTicketItemStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KitchenTicketItem extends KitchenTicketItem {
  @override
  final int? seat;
  @override
  final int? course;
  @override
  final DateTime? recalledAt;
  @override
  final int recallCount;
  @override
  final int? prepSeconds;
  @override
  final bool late_;
  @override
  final String id;
  @override
  final String? saleLineId;
  @override
  final String name;
  @override
  final BuiltList<KitchenTicketItemModifiersInner> modifiers;
  @override
  final BuiltList<KitchenTicketItemComponentsInner> components;
  @override
  final String? note;
  @override
  final String quantity;
  @override
  final KitchenTicketItemStatusEnum status;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? readyAt;
  @override
  final DateTime? servedAt;
  @override
  final DateTime? voidedAt;

  factory _$KitchenTicketItem(
          [void Function(KitchenTicketItemBuilder)? updates]) =>
      (KitchenTicketItemBuilder()..update(updates))._build();

  _$KitchenTicketItem._(
      {this.seat,
      this.course,
      this.recalledAt,
      required this.recallCount,
      this.prepSeconds,
      required this.late_,
      required this.id,
      this.saleLineId,
      required this.name,
      required this.modifiers,
      required this.components,
      this.note,
      required this.quantity,
      required this.status,
      this.startedAt,
      this.readyAt,
      this.servedAt,
      this.voidedAt})
      : super._();
  @override
  KitchenTicketItem rebuild(void Function(KitchenTicketItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenTicketItemBuilder toBuilder() =>
      KitchenTicketItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenTicketItem &&
        seat == other.seat &&
        course == other.course &&
        recalledAt == other.recalledAt &&
        recallCount == other.recallCount &&
        prepSeconds == other.prepSeconds &&
        late_ == other.late_ &&
        id == other.id &&
        saleLineId == other.saleLineId &&
        name == other.name &&
        modifiers == other.modifiers &&
        components == other.components &&
        note == other.note &&
        quantity == other.quantity &&
        status == other.status &&
        startedAt == other.startedAt &&
        readyAt == other.readyAt &&
        servedAt == other.servedAt &&
        voidedAt == other.voidedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, seat.hashCode);
    _$hash = $jc(_$hash, course.hashCode);
    _$hash = $jc(_$hash, recalledAt.hashCode);
    _$hash = $jc(_$hash, recallCount.hashCode);
    _$hash = $jc(_$hash, prepSeconds.hashCode);
    _$hash = $jc(_$hash, late_.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, saleLineId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jc(_$hash, components.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, readyAt.hashCode);
    _$hash = $jc(_$hash, servedAt.hashCode);
    _$hash = $jc(_$hash, voidedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenTicketItem')
          ..add('seat', seat)
          ..add('course', course)
          ..add('recalledAt', recalledAt)
          ..add('recallCount', recallCount)
          ..add('prepSeconds', prepSeconds)
          ..add('late_', late_)
          ..add('id', id)
          ..add('saleLineId', saleLineId)
          ..add('name', name)
          ..add('modifiers', modifiers)
          ..add('components', components)
          ..add('note', note)
          ..add('quantity', quantity)
          ..add('status', status)
          ..add('startedAt', startedAt)
          ..add('readyAt', readyAt)
          ..add('servedAt', servedAt)
          ..add('voidedAt', voidedAt))
        .toString();
  }
}

class KitchenTicketItemBuilder
    implements Builder<KitchenTicketItem, KitchenTicketItemBuilder> {
  _$KitchenTicketItem? _$v;

  int? _seat;
  int? get seat => _$this._seat;
  set seat(int? seat) => _$this._seat = seat;

  int? _course;
  int? get course => _$this._course;
  set course(int? course) => _$this._course = course;

  DateTime? _recalledAt;
  DateTime? get recalledAt => _$this._recalledAt;
  set recalledAt(DateTime? recalledAt) => _$this._recalledAt = recalledAt;

  int? _recallCount;
  int? get recallCount => _$this._recallCount;
  set recallCount(int? recallCount) => _$this._recallCount = recallCount;

  int? _prepSeconds;
  int? get prepSeconds => _$this._prepSeconds;
  set prepSeconds(int? prepSeconds) => _$this._prepSeconds = prepSeconds;

  bool? _late_;
  bool? get late_ => _$this._late_;
  set late_(bool? late_) => _$this._late_ = late_;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _saleLineId;
  String? get saleLineId => _$this._saleLineId;
  set saleLineId(String? saleLineId) => _$this._saleLineId = saleLineId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<KitchenTicketItemModifiersInner>? _modifiers;
  ListBuilder<KitchenTicketItemModifiersInner> get modifiers =>
      _$this._modifiers ??= ListBuilder<KitchenTicketItemModifiersInner>();
  set modifiers(ListBuilder<KitchenTicketItemModifiersInner>? modifiers) =>
      _$this._modifiers = modifiers;

  ListBuilder<KitchenTicketItemComponentsInner>? _components;
  ListBuilder<KitchenTicketItemComponentsInner> get components =>
      _$this._components ??= ListBuilder<KitchenTicketItemComponentsInner>();
  set components(ListBuilder<KitchenTicketItemComponentsInner>? components) =>
      _$this._components = components;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  KitchenTicketItemStatusEnum? _status;
  KitchenTicketItemStatusEnum? get status => _$this._status;
  set status(KitchenTicketItemStatusEnum? status) => _$this._status = status;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _readyAt;
  DateTime? get readyAt => _$this._readyAt;
  set readyAt(DateTime? readyAt) => _$this._readyAt = readyAt;

  DateTime? _servedAt;
  DateTime? get servedAt => _$this._servedAt;
  set servedAt(DateTime? servedAt) => _$this._servedAt = servedAt;

  DateTime? _voidedAt;
  DateTime? get voidedAt => _$this._voidedAt;
  set voidedAt(DateTime? voidedAt) => _$this._voidedAt = voidedAt;

  KitchenTicketItemBuilder() {
    KitchenTicketItem._defaults(this);
  }

  KitchenTicketItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _seat = $v.seat;
      _course = $v.course;
      _recalledAt = $v.recalledAt;
      _recallCount = $v.recallCount;
      _prepSeconds = $v.prepSeconds;
      _late_ = $v.late_;
      _id = $v.id;
      _saleLineId = $v.saleLineId;
      _name = $v.name;
      _modifiers = $v.modifiers.toBuilder();
      _components = $v.components.toBuilder();
      _note = $v.note;
      _quantity = $v.quantity;
      _status = $v.status;
      _startedAt = $v.startedAt;
      _readyAt = $v.readyAt;
      _servedAt = $v.servedAt;
      _voidedAt = $v.voidedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenTicketItem other) {
    _$v = other as _$KitchenTicketItem;
  }

  @override
  void update(void Function(KitchenTicketItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenTicketItem build() => _build();

  _$KitchenTicketItem _build() {
    _$KitchenTicketItem _$result;
    try {
      _$result = _$v ??
          _$KitchenTicketItem._(
            seat: seat,
            course: course,
            recalledAt: recalledAt,
            recallCount: BuiltValueNullFieldError.checkNotNull(
                recallCount, r'KitchenTicketItem', 'recallCount'),
            prepSeconds: prepSeconds,
            late_: BuiltValueNullFieldError.checkNotNull(
                late_, r'KitchenTicketItem', 'late_'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'KitchenTicketItem', 'id'),
            saleLineId: saleLineId,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'KitchenTicketItem', 'name'),
            modifiers: modifiers.build(),
            components: components.build(),
            note: note,
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'KitchenTicketItem', 'quantity'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'KitchenTicketItem', 'status'),
            startedAt: startedAt,
            readyAt: readyAt,
            servedAt: servedAt,
            voidedAt: voidedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        modifiers.build();
        _$failedField = 'components';
        components.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenTicketItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
