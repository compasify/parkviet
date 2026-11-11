// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottle_keep.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BottleKeepStatusEnum _$bottleKeepStatusEnum_kept =
    const BottleKeepStatusEnum._('kept');
const BottleKeepStatusEnum _$bottleKeepStatusEnum_finished =
    const BottleKeepStatusEnum._('finished');
const BottleKeepStatusEnum _$bottleKeepStatusEnum_expired =
    const BottleKeepStatusEnum._('expired');
const BottleKeepStatusEnum _$bottleKeepStatusEnum_returned =
    const BottleKeepStatusEnum._('returned');

BottleKeepStatusEnum _$bottleKeepStatusEnumValueOf(String name) {
  switch (name) {
    case 'kept':
      return _$bottleKeepStatusEnum_kept;
    case 'finished':
      return _$bottleKeepStatusEnum_finished;
    case 'expired':
      return _$bottleKeepStatusEnum_expired;
    case 'returned':
      return _$bottleKeepStatusEnum_returned;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BottleKeepStatusEnum> _$bottleKeepStatusEnumValues =
    BuiltSet<BottleKeepStatusEnum>(const <BottleKeepStatusEnum>[
  _$bottleKeepStatusEnum_kept,
  _$bottleKeepStatusEnum_finished,
  _$bottleKeepStatusEnum_expired,
  _$bottleKeepStatusEnum_returned,
]);

Serializer<BottleKeepStatusEnum> _$bottleKeepStatusEnumSerializer =
    _$BottleKeepStatusEnumSerializer();

class _$BottleKeepStatusEnumSerializer
    implements PrimitiveSerializer<BottleKeepStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'kept': 'kept',
    'finished': 'finished',
    'expired': 'expired',
    'returned': 'returned',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'kept': 'kept',
    'finished': 'finished',
    'expired': 'expired',
    'returned': 'returned',
  };

  @override
  final Iterable<Type> types = const <Type>[BottleKeepStatusEnum];
  @override
  final String wireName = 'BottleKeepStatusEnum';

  @override
  Object serialize(Serializers serializers, BottleKeepStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BottleKeepStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BottleKeepStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BottleKeep extends BottleKeep {
  @override
  final String id;
  @override
  final String branchId;
  @override
  final String code;
  @override
  final BottleKeepStatusEnum status;
  @override
  final int levelPercent;
  @override
  final String variantId;
  @override
  final String? productName;
  @override
  final String? optionsText;
  @override
  final BottleKeepCustomer? customer;
  @override
  final String? guestName;
  @override
  final String? phone;
  @override
  final Date keptOn;
  @override
  final Date expiresOn;
  @override
  final String? sourceOrderId;
  @override
  final String? note;
  @override
  final int revision;
  @override
  final String? photoUrl;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? closedAt;
  @override
  final BuiltList<BottleKeepEvent>? events;

  factory _$BottleKeep([void Function(BottleKeepBuilder)? updates]) =>
      (BottleKeepBuilder()..update(updates))._build();

  _$BottleKeep._(
      {required this.id,
      required this.branchId,
      required this.code,
      required this.status,
      required this.levelPercent,
      required this.variantId,
      this.productName,
      this.optionsText,
      this.customer,
      this.guestName,
      this.phone,
      required this.keptOn,
      required this.expiresOn,
      this.sourceOrderId,
      this.note,
      required this.revision,
      this.photoUrl,
      this.createdAt,
      this.closedAt,
      this.events})
      : super._();
  @override
  BottleKeep rebuild(void Function(BottleKeepBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BottleKeepBuilder toBuilder() => BottleKeepBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BottleKeep &&
        id == other.id &&
        branchId == other.branchId &&
        code == other.code &&
        status == other.status &&
        levelPercent == other.levelPercent &&
        variantId == other.variantId &&
        productName == other.productName &&
        optionsText == other.optionsText &&
        customer == other.customer &&
        guestName == other.guestName &&
        phone == other.phone &&
        keptOn == other.keptOn &&
        expiresOn == other.expiresOn &&
        sourceOrderId == other.sourceOrderId &&
        note == other.note &&
        revision == other.revision &&
        photoUrl == other.photoUrl &&
        createdAt == other.createdAt &&
        closedAt == other.closedAt &&
        events == other.events;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, levelPercent.hashCode);
    _$hash = $jc(_$hash, variantId.hashCode);
    _$hash = $jc(_$hash, productName.hashCode);
    _$hash = $jc(_$hash, optionsText.hashCode);
    _$hash = $jc(_$hash, customer.hashCode);
    _$hash = $jc(_$hash, guestName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, keptOn.hashCode);
    _$hash = $jc(_$hash, expiresOn.hashCode);
    _$hash = $jc(_$hash, sourceOrderId.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, photoUrl.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, closedAt.hashCode);
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BottleKeep')
          ..add('id', id)
          ..add('branchId', branchId)
          ..add('code', code)
          ..add('status', status)
          ..add('levelPercent', levelPercent)
          ..add('variantId', variantId)
          ..add('productName', productName)
          ..add('optionsText', optionsText)
          ..add('customer', customer)
          ..add('guestName', guestName)
          ..add('phone', phone)
          ..add('keptOn', keptOn)
          ..add('expiresOn', expiresOn)
          ..add('sourceOrderId', sourceOrderId)
          ..add('note', note)
          ..add('revision', revision)
          ..add('photoUrl', photoUrl)
          ..add('createdAt', createdAt)
          ..add('closedAt', closedAt)
          ..add('events', events))
        .toString();
  }
}

class BottleKeepBuilder implements Builder<BottleKeep, BottleKeepBuilder> {
  _$BottleKeep? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  BottleKeepStatusEnum? _status;
  BottleKeepStatusEnum? get status => _$this._status;
  set status(BottleKeepStatusEnum? status) => _$this._status = status;

  int? _levelPercent;
  int? get levelPercent => _$this._levelPercent;
  set levelPercent(int? levelPercent) => _$this._levelPercent = levelPercent;

  String? _variantId;
  String? get variantId => _$this._variantId;
  set variantId(String? variantId) => _$this._variantId = variantId;

  String? _productName;
  String? get productName => _$this._productName;
  set productName(String? productName) => _$this._productName = productName;

  String? _optionsText;
  String? get optionsText => _$this._optionsText;
  set optionsText(String? optionsText) => _$this._optionsText = optionsText;

  BottleKeepCustomerBuilder? _customer;
  BottleKeepCustomerBuilder get customer =>
      _$this._customer ??= BottleKeepCustomerBuilder();
  set customer(BottleKeepCustomerBuilder? customer) =>
      _$this._customer = customer;

  String? _guestName;
  String? get guestName => _$this._guestName;
  set guestName(String? guestName) => _$this._guestName = guestName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  Date? _keptOn;
  Date? get keptOn => _$this._keptOn;
  set keptOn(Date? keptOn) => _$this._keptOn = keptOn;

  Date? _expiresOn;
  Date? get expiresOn => _$this._expiresOn;
  set expiresOn(Date? expiresOn) => _$this._expiresOn = expiresOn;

  String? _sourceOrderId;
  String? get sourceOrderId => _$this._sourceOrderId;
  set sourceOrderId(String? sourceOrderId) =>
      _$this._sourceOrderId = sourceOrderId;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  String? _photoUrl;
  String? get photoUrl => _$this._photoUrl;
  set photoUrl(String? photoUrl) => _$this._photoUrl = photoUrl;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _closedAt;
  DateTime? get closedAt => _$this._closedAt;
  set closedAt(DateTime? closedAt) => _$this._closedAt = closedAt;

  ListBuilder<BottleKeepEvent>? _events;
  ListBuilder<BottleKeepEvent> get events =>
      _$this._events ??= ListBuilder<BottleKeepEvent>();
  set events(ListBuilder<BottleKeepEvent>? events) => _$this._events = events;

  BottleKeepBuilder() {
    BottleKeep._defaults(this);
  }

  BottleKeepBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _branchId = $v.branchId;
      _code = $v.code;
      _status = $v.status;
      _levelPercent = $v.levelPercent;
      _variantId = $v.variantId;
      _productName = $v.productName;
      _optionsText = $v.optionsText;
      _customer = $v.customer?.toBuilder();
      _guestName = $v.guestName;
      _phone = $v.phone;
      _keptOn = $v.keptOn;
      _expiresOn = $v.expiresOn;
      _sourceOrderId = $v.sourceOrderId;
      _note = $v.note;
      _revision = $v.revision;
      _photoUrl = $v.photoUrl;
      _createdAt = $v.createdAt;
      _closedAt = $v.closedAt;
      _events = $v.events?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BottleKeep other) {
    _$v = other as _$BottleKeep;
  }

  @override
  void update(void Function(BottleKeepBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BottleKeep build() => _build();

  _$BottleKeep _build() {
    _$BottleKeep _$result;
    try {
      _$result = _$v ??
          _$BottleKeep._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'BottleKeep', 'id'),
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'BottleKeep', 'branchId'),
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'BottleKeep', 'code'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'BottleKeep', 'status'),
            levelPercent: BuiltValueNullFieldError.checkNotNull(
                levelPercent, r'BottleKeep', 'levelPercent'),
            variantId: BuiltValueNullFieldError.checkNotNull(
                variantId, r'BottleKeep', 'variantId'),
            productName: productName,
            optionsText: optionsText,
            customer: _customer?.build(),
            guestName: guestName,
            phone: phone,
            keptOn: BuiltValueNullFieldError.checkNotNull(
                keptOn, r'BottleKeep', 'keptOn'),
            expiresOn: BuiltValueNullFieldError.checkNotNull(
                expiresOn, r'BottleKeep', 'expiresOn'),
            sourceOrderId: sourceOrderId,
            note: note,
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'BottleKeep', 'revision'),
            photoUrl: photoUrl,
            createdAt: createdAt,
            closedAt: closedAt,
            events: _events?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'customer';
        _customer?.build();

        _$failedField = 'events';
        _events?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BottleKeep', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
