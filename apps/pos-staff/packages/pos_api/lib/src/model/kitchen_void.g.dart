// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_void.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenVoid extends KitchenVoid {
  @override
  final String id;
  @override
  final String? saleLineId;
  @override
  final String name;
  @override
  final String quantity;
  @override
  final String reasonCode;
  @override
  final String? note;
  @override
  final bool wasted;
  @override
  final String staffId;
  @override
  final String? staffName;
  @override
  final String? approvalId;
  @override
  final String? approverId;
  @override
  final String? kitchenTicketId;
  @override
  final DateTime voidedAt;

  factory _$KitchenVoid([void Function(KitchenVoidBuilder)? updates]) =>
      (KitchenVoidBuilder()..update(updates))._build();

  _$KitchenVoid._(
      {required this.id,
      this.saleLineId,
      required this.name,
      required this.quantity,
      required this.reasonCode,
      this.note,
      required this.wasted,
      required this.staffId,
      this.staffName,
      this.approvalId,
      this.approverId,
      this.kitchenTicketId,
      required this.voidedAt})
      : super._();
  @override
  KitchenVoid rebuild(void Function(KitchenVoidBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenVoidBuilder toBuilder() => KitchenVoidBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenVoid &&
        id == other.id &&
        saleLineId == other.saleLineId &&
        name == other.name &&
        quantity == other.quantity &&
        reasonCode == other.reasonCode &&
        note == other.note &&
        wasted == other.wasted &&
        staffId == other.staffId &&
        staffName == other.staffName &&
        approvalId == other.approvalId &&
        approverId == other.approverId &&
        kitchenTicketId == other.kitchenTicketId &&
        voidedAt == other.voidedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, saleLineId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, wasted.hashCode);
    _$hash = $jc(_$hash, staffId.hashCode);
    _$hash = $jc(_$hash, staffName.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, approverId.hashCode);
    _$hash = $jc(_$hash, kitchenTicketId.hashCode);
    _$hash = $jc(_$hash, voidedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenVoid')
          ..add('id', id)
          ..add('saleLineId', saleLineId)
          ..add('name', name)
          ..add('quantity', quantity)
          ..add('reasonCode', reasonCode)
          ..add('note', note)
          ..add('wasted', wasted)
          ..add('staffId', staffId)
          ..add('staffName', staffName)
          ..add('approvalId', approvalId)
          ..add('approverId', approverId)
          ..add('kitchenTicketId', kitchenTicketId)
          ..add('voidedAt', voidedAt))
        .toString();
  }
}

class KitchenVoidBuilder implements Builder<KitchenVoid, KitchenVoidBuilder> {
  _$KitchenVoid? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _saleLineId;
  String? get saleLineId => _$this._saleLineId;
  set saleLineId(String? saleLineId) => _$this._saleLineId = saleLineId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _quantity;
  String? get quantity => _$this._quantity;
  set quantity(String? quantity) => _$this._quantity = quantity;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  bool? _wasted;
  bool? get wasted => _$this._wasted;
  set wasted(bool? wasted) => _$this._wasted = wasted;

  String? _staffId;
  String? get staffId => _$this._staffId;
  set staffId(String? staffId) => _$this._staffId = staffId;

  String? _staffName;
  String? get staffName => _$this._staffName;
  set staffName(String? staffName) => _$this._staffName = staffName;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  String? _approverId;
  String? get approverId => _$this._approverId;
  set approverId(String? approverId) => _$this._approverId = approverId;

  String? _kitchenTicketId;
  String? get kitchenTicketId => _$this._kitchenTicketId;
  set kitchenTicketId(String? kitchenTicketId) =>
      _$this._kitchenTicketId = kitchenTicketId;

  DateTime? _voidedAt;
  DateTime? get voidedAt => _$this._voidedAt;
  set voidedAt(DateTime? voidedAt) => _$this._voidedAt = voidedAt;

  KitchenVoidBuilder() {
    KitchenVoid._defaults(this);
  }

  KitchenVoidBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _saleLineId = $v.saleLineId;
      _name = $v.name;
      _quantity = $v.quantity;
      _reasonCode = $v.reasonCode;
      _note = $v.note;
      _wasted = $v.wasted;
      _staffId = $v.staffId;
      _staffName = $v.staffName;
      _approvalId = $v.approvalId;
      _approverId = $v.approverId;
      _kitchenTicketId = $v.kitchenTicketId;
      _voidedAt = $v.voidedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenVoid other) {
    _$v = other as _$KitchenVoid;
  }

  @override
  void update(void Function(KitchenVoidBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenVoid build() => _build();

  _$KitchenVoid _build() {
    final _$result = _$v ??
        _$KitchenVoid._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'KitchenVoid', 'id'),
          saleLineId: saleLineId,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'KitchenVoid', 'name'),
          quantity: BuiltValueNullFieldError.checkNotNull(
              quantity, r'KitchenVoid', 'quantity'),
          reasonCode: BuiltValueNullFieldError.checkNotNull(
              reasonCode, r'KitchenVoid', 'reasonCode'),
          note: note,
          wasted: BuiltValueNullFieldError.checkNotNull(
              wasted, r'KitchenVoid', 'wasted'),
          staffId: BuiltValueNullFieldError.checkNotNull(
              staffId, r'KitchenVoid', 'staffId'),
          staffName: staffName,
          approvalId: approvalId,
          approverId: approverId,
          kitchenTicketId: kitchenTicketId,
          voidedAt: BuiltValueNullFieldError.checkNotNull(
              voidedAt, r'KitchenVoid', 'voidedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
