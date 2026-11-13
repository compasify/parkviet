// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_line.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkspaceLineKindEnum _$workspaceLineKindEnum_ordinary =
    const WorkspaceLineKindEnum._('ordinary');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_measured =
    const WorkspaceLineKindEnum._('measured');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_tracked =
    const WorkspaceLineKindEnum._('tracked');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_menu =
    const WorkspaceLineKindEnum._('menu');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_timed =
    const WorkspaceLineKindEnum._('timed');
const WorkspaceLineKindEnum _$workspaceLineKindEnum_cover =
    const WorkspaceLineKindEnum._('cover');

WorkspaceLineKindEnum _$workspaceLineKindEnumValueOf(String name) {
  switch (name) {
    case 'ordinary':
      return _$workspaceLineKindEnum_ordinary;
    case 'measured':
      return _$workspaceLineKindEnum_measured;
    case 'tracked':
      return _$workspaceLineKindEnum_tracked;
    case 'menu':
      return _$workspaceLineKindEnum_menu;
    case 'timed':
      return _$workspaceLineKindEnum_timed;
    case 'cover':
      return _$workspaceLineKindEnum_cover;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkspaceLineKindEnum> _$workspaceLineKindEnumValues =
    BuiltSet<WorkspaceLineKindEnum>(const <WorkspaceLineKindEnum>[
  _$workspaceLineKindEnum_ordinary,
  _$workspaceLineKindEnum_measured,
  _$workspaceLineKindEnum_tracked,
  _$workspaceLineKindEnum_menu,
  _$workspaceLineKindEnum_timed,
  _$workspaceLineKindEnum_cover,
]);

const WorkspaceLineCourseStatusEnum _$workspaceLineCourseStatusEnum_none =
    const WorkspaceLineCourseStatusEnum._('none');
const WorkspaceLineCourseStatusEnum _$workspaceLineCourseStatusEnum_held =
    const WorkspaceLineCourseStatusEnum._('held');
const WorkspaceLineCourseStatusEnum _$workspaceLineCourseStatusEnum_fired =
    const WorkspaceLineCourseStatusEnum._('fired');

WorkspaceLineCourseStatusEnum _$workspaceLineCourseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'none':
      return _$workspaceLineCourseStatusEnum_none;
    case 'held':
      return _$workspaceLineCourseStatusEnum_held;
    case 'fired':
      return _$workspaceLineCourseStatusEnum_fired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkspaceLineCourseStatusEnum>
    _$workspaceLineCourseStatusEnumValues = BuiltSet<
        WorkspaceLineCourseStatusEnum>(const <WorkspaceLineCourseStatusEnum>[
  _$workspaceLineCourseStatusEnum_none,
  _$workspaceLineCourseStatusEnum_held,
  _$workspaceLineCourseStatusEnum_fired,
]);

Serializer<WorkspaceLineKindEnum> _$workspaceLineKindEnumSerializer =
    _$WorkspaceLineKindEnumSerializer();
Serializer<WorkspaceLineCourseStatusEnum>
    _$workspaceLineCourseStatusEnumSerializer =
    _$WorkspaceLineCourseStatusEnumSerializer();

class _$WorkspaceLineKindEnumSerializer
    implements PrimitiveSerializer<WorkspaceLineKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ordinary': 'ordinary',
    'measured': 'measured',
    'tracked': 'tracked',
    'menu': 'menu',
    'timed': 'timed',
    'cover': 'cover',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ordinary': 'ordinary',
    'measured': 'measured',
    'tracked': 'tracked',
    'menu': 'menu',
    'timed': 'timed',
    'cover': 'cover',
  };

  @override
  final Iterable<Type> types = const <Type>[WorkspaceLineKindEnum];
  @override
  final String wireName = 'WorkspaceLineKindEnum';

  @override
  Object serialize(Serializers serializers, WorkspaceLineKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkspaceLineKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkspaceLineKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkspaceLineCourseStatusEnumSerializer
    implements PrimitiveSerializer<WorkspaceLineCourseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'none': 'none',
    'held': 'held',
    'fired': 'fired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'none': 'none',
    'held': 'held',
    'fired': 'fired',
  };

  @override
  final Iterable<Type> types = const <Type>[WorkspaceLineCourseStatusEnum];
  @override
  final String wireName = 'WorkspaceLineCourseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, WorkspaceLineCourseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkspaceLineCourseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkspaceLineCourseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkspaceLine extends WorkspaceLine {
  @override
  final String id;
  @override
  final String variantId;
  @override
  final String name;
  @override
  final int quantity;
  @override
  final String price;
  @override
  final String amount;
  @override
  final String? saleLineId;
  @override
  final WorkspaceLineKindEnum? kind;
  @override
  final String? unitPrice;
  @override
  final String? priceLabel;
  @override
  final String? note;
  @override
  final BuiltList<LineModifier>? modifiers;
  @override
  final BuiltList<LineComponent>? components;
  @override
  final String? kitchenSentQuantity;
  @override
  final String? pendingKitchenQuantity;
  @override
  final int? rowVersion;
  @override
  final StaffRef? addedBy;
  @override
  final LineKitchenStatus? kitchenStatus;
  @override
  final int? kitchenSendSequence;
  @override
  final int? course;
  @override
  final WorkspaceLineCourseStatusEnum? courseStatus;
  @override
  final int? seat;
  @override
  final String? buffetTierId;
  @override
  final String? buffetCoverLineId;

  factory _$WorkspaceLine([void Function(WorkspaceLineBuilder)? updates]) =>
      (WorkspaceLineBuilder()..update(updates))._build();

  _$WorkspaceLine._(
      {required this.id,
      required this.variantId,
      required this.name,
      required this.quantity,
      required this.price,
      required this.amount,
      this.saleLineId,
      this.kind,
      this.unitPrice,
      this.priceLabel,
      this.note,
      this.modifiers,
      this.components,
      this.kitchenSentQuantity,
      this.pendingKitchenQuantity,
      this.rowVersion,
      this.addedBy,
      this.kitchenStatus,
      this.kitchenSendSequence,
      this.course,
      this.courseStatus,
      this.seat,
      this.buffetTierId,
      this.buffetCoverLineId})
      : super._();
  @override
  WorkspaceLine rebuild(void Function(WorkspaceLineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceLineBuilder toBuilder() => WorkspaceLineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceLine &&
        id == other.id &&
        variantId == other.variantId &&
        name == other.name &&
        quantity == other.quantity &&
        price == other.price &&
        amount == other.amount &&
        saleLineId == other.saleLineId &&
        kind == other.kind &&
        unitPrice == other.unitPrice &&
        priceLabel == other.priceLabel &&
        note == other.note &&
        modifiers == other.modifiers &&
        components == other.components &&
        kitchenSentQuantity == other.kitchenSentQuantity &&
        pendingKitchenQuantity == other.pendingKitchenQuantity &&
        rowVersion == other.rowVersion &&
        addedBy == other.addedBy &&
        kitchenStatus == other.kitchenStatus &&
        kitchenSendSequence == other.kitchenSendSequence &&
        course == other.course &&
        courseStatus == other.courseStatus &&
        seat == other.seat &&
        buffetTierId == other.buffetTierId &&
        buffetCoverLineId == other.buffetCoverLineId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, saleLineId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, unitPrice.hashCode);
    _$hash = $jc(_$hash, priceLabel.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, modifiers.hashCode);
    _$hash = $jc(_$hash, components.hashCode);
    _$hash = $jc(_$hash, kitchenSentQuantity.hashCode);
    _$hash = $jc(_$hash, pendingKitchenQuantity.hashCode);
    _$hash = $jc(_$hash, rowVersion.hashCode);
    _$hash = $jc(_$hash, addedBy.hashCode);
    _$hash = $jc(_$hash, kitchenStatus.hashCode);
    _$hash = $jc(_$hash, kitchenSendSequence.hashCode);
    _$hash = $jc(_$hash, course.hashCode);
    _$hash = $jc(_$hash, courseStatus.hashCode);
    _$hash = $jc(_$hash, seat.hashCode);
    _$hash = $jc(_$hash, buffetTierId.hashCode);
    _$hash = $jc(_$hash, buffetCoverLineId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceLine')
          ..add('id', id)
          ..add('variantId', variantId)
          ..add('name', name)
          ..add('quantity', quantity)
          ..add('price', price)
          ..add('amount', amount)
          ..add('saleLineId', saleLineId)
          ..add('kind', kind)
          ..add('unitPrice', unitPrice)
          ..add('priceLabel', priceLabel)
          ..add('note', note)
          ..add('modifiers', modifiers)
          ..add('components', components)
          ..add('kitchenSentQuantity', kitchenSentQuantity)
          ..add('pendingKitchenQuantity', pendingKitchenQuantity)
          ..add('rowVersion', rowVersion)
          ..add('addedBy', addedBy)
          ..add('kitchenStatus', kitchenStatus)
          ..add('kitchenSendSequence', kitchenSendSequence)
          ..add('course', course)
          ..add('courseStatus', courseStatus)
          ..add('seat', seat)
          ..add('buffetTierId', buffetTierId)
          ..add('buffetCoverLineId', buffetCoverLineId))
        .toString();
  }
}

class WorkspaceLineBuilder
    implements Builder<WorkspaceLine, WorkspaceLineBuilder> {
  _$WorkspaceLine? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _quantity;
  int? get quantity => _$this._quantity;
  set quantity(int? quantity) => _$this._quantity = quantity;

  String? _price;
  String? get price => _$this._price;
  set price(String? price) => _$this._price = price;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _saleLineId;
  String? get saleLineId => _$this._saleLineId;
  set saleLineId(String? saleLineId) => _$this._saleLineId = saleLineId;

  WorkspaceLineKindEnum? _kind;
  WorkspaceLineKindEnum? get kind => _$this._kind;
  set kind(WorkspaceLineKindEnum? kind) => _$this._kind = kind;

  String? _unitPrice;
  String? get unitPrice => _$this._unitPrice;
  set unitPrice(String? unitPrice) => _$this._unitPrice = unitPrice;

  String? _priceLabel;
  String? get priceLabel => _$this._priceLabel;
  set priceLabel(String? priceLabel) => _$this._priceLabel = priceLabel;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<LineModifier>? _modifiers;
  ListBuilder<LineModifier> get modifiers =>
      _$this._modifiers ??= ListBuilder<LineModifier>();
  set modifiers(ListBuilder<LineModifier>? modifiers) =>
      _$this._modifiers = modifiers;

  ListBuilder<LineComponent>? _components;
  ListBuilder<LineComponent> get components =>
      _$this._components ??= ListBuilder<LineComponent>();
  set components(ListBuilder<LineComponent>? components) =>
      _$this._components = components;

  String? _kitchenSentQuantity;
  String? get kitchenSentQuantity => _$this._kitchenSentQuantity;
  set kitchenSentQuantity(String? kitchenSentQuantity) =>
      _$this._kitchenSentQuantity = kitchenSentQuantity;

  String? _pendingKitchenQuantity;
  String? get pendingKitchenQuantity => _$this._pendingKitchenQuantity;
  set pendingKitchenQuantity(String? pendingKitchenQuantity) =>
      _$this._pendingKitchenQuantity = pendingKitchenQuantity;

  int? _rowVersion;
  int? get rowVersion => _$this._rowVersion;
  set rowVersion(int? rowVersion) => _$this._rowVersion = rowVersion;

  StaffRefBuilder? _addedBy;
  StaffRefBuilder get addedBy => _$this._addedBy ??= StaffRefBuilder();
  set addedBy(StaffRefBuilder? addedBy) => _$this._addedBy = addedBy;

  LineKitchenStatusBuilder? _kitchenStatus;
  LineKitchenStatusBuilder get kitchenStatus =>
      _$this._kitchenStatus ??= LineKitchenStatusBuilder();
  set kitchenStatus(LineKitchenStatusBuilder? kitchenStatus) =>
      _$this._kitchenStatus = kitchenStatus;

  int? _kitchenSendSequence;
  int? get kitchenSendSequence => _$this._kitchenSendSequence;
  set kitchenSendSequence(int? kitchenSendSequence) =>
      _$this._kitchenSendSequence = kitchenSendSequence;

  int? _course;
  int? get course => _$this._course;
  set course(int? course) => _$this._course = course;

  WorkspaceLineCourseStatusEnum? _courseStatus;
  WorkspaceLineCourseStatusEnum? get courseStatus => _$this._courseStatus;
  set courseStatus(WorkspaceLineCourseStatusEnum? courseStatus) =>
      _$this._courseStatus = courseStatus;

  int? _seat;
  int? get seat => _$this._seat;
  set seat(int? seat) => _$this._seat = seat;

  String? _buffetTierId;
  String? get buffetTierId => _$this._buffetTierId;
  set buffetTierId(String? buffetTierId) => _$this._buffetTierId = buffetTierId;

  String? _buffetCoverLineId;
  String? get buffetCoverLineId => _$this._buffetCoverLineId;
  set buffetCoverLineId(String? buffetCoverLineId) =>
      _$this._buffetCoverLineId = buffetCoverLineId;

  WorkspaceLineBuilder() {
    WorkspaceLine._defaults(this);
  }

  WorkspaceLineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _variantId = $v.variantId;
      _name = $v.name;
      _quantity = $v.quantity;
      _price = $v.price;
      _amount = $v.amount;
      _saleLineId = $v.saleLineId;
      _kind = $v.kind;
      _unitPrice = $v.unitPrice;
      _priceLabel = $v.priceLabel;
      _note = $v.note;
      _modifiers = $v.modifiers?.toBuilder();
      _components = $v.components?.toBuilder();
      _kitchenSentQuantity = $v.kitchenSentQuantity;
      _pendingKitchenQuantity = $v.pendingKitchenQuantity;
      _rowVersion = $v.rowVersion;
      _addedBy = $v.addedBy?.toBuilder();
      _kitchenStatus = $v.kitchenStatus?.toBuilder();
      _kitchenSendSequence = $v.kitchenSendSequence;
      _course = $v.course;
      _courseStatus = $v.courseStatus;
      _seat = $v.seat;
      _buffetTierId = $v.buffetTierId;
      _buffetCoverLineId = $v.buffetCoverLineId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceLine other) {
    _$v = other as _$WorkspaceLine;
  }

  @override
  void update(void Function(WorkspaceLineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceLine build() => _build();

  _$WorkspaceLine _build() {
    _$WorkspaceLine _$result;
    try {
      _$result = _$v ??
          _$WorkspaceLine._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'WorkspaceLine', 'id'),
            variantId: BuiltValueNullFieldError.checkNotNull(
                variantId, r'WorkspaceLine', 'variantId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'WorkspaceLine', 'name'),
            quantity: BuiltValueNullFieldError.checkNotNull(
                quantity, r'WorkspaceLine', 'quantity'),
            price: BuiltValueNullFieldError.checkNotNull(
                price, r'WorkspaceLine', 'price'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'WorkspaceLine', 'amount'),
            saleLineId: saleLineId,
            kind: kind,
            unitPrice: unitPrice,
            priceLabel: priceLabel,
            note: note,
            modifiers: _modifiers?.build(),
            components: _components?.build(),
            kitchenSentQuantity: kitchenSentQuantity,
            pendingKitchenQuantity: pendingKitchenQuantity,
            rowVersion: rowVersion,
            addedBy: _addedBy?.build(),
            kitchenStatus: _kitchenStatus?.build(),
            kitchenSendSequence: kitchenSendSequence,
            course: course,
            courseStatus: courseStatus,
            seat: seat,
            buffetTierId: buffetTierId,
            buffetCoverLineId: buffetCoverLineId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'modifiers';
        _modifiers?.build();
        _$failedField = 'components';
        _components?.build();

        _$failedField = 'addedBy';
        _addedBy?.build();
        _$failedField = 'kitchenStatus';
        _kitchenStatus?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkspaceLine', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
