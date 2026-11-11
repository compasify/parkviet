// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_history_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KitchenHistoryEntryKindEnum _$kitchenHistoryEntryKindEnum_send =
    const KitchenHistoryEntryKindEnum._('send');
const KitchenHistoryEntryKindEnum _$kitchenHistoryEntryKindEnum_void_ =
    const KitchenHistoryEntryKindEnum._('void_');

KitchenHistoryEntryKindEnum _$kitchenHistoryEntryKindEnumValueOf(String name) {
  switch (name) {
    case 'send':
      return _$kitchenHistoryEntryKindEnum_send;
    case 'void_':
      return _$kitchenHistoryEntryKindEnum_void_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KitchenHistoryEntryKindEnum>
    _$kitchenHistoryEntryKindEnumValues =
    BuiltSet<KitchenHistoryEntryKindEnum>(const <KitchenHistoryEntryKindEnum>[
  _$kitchenHistoryEntryKindEnum_send,
  _$kitchenHistoryEntryKindEnum_void_,
]);

Serializer<KitchenHistoryEntryKindEnum>
    _$kitchenHistoryEntryKindEnumSerializer =
    _$KitchenHistoryEntryKindEnumSerializer();

class _$KitchenHistoryEntryKindEnumSerializer
    implements PrimitiveSerializer<KitchenHistoryEntryKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'send': 'send',
    'void_': 'void',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'send': 'send',
    'void': 'void_',
  };

  @override
  final Iterable<Type> types = const <Type>[KitchenHistoryEntryKindEnum];
  @override
  final String wireName = 'KitchenHistoryEntryKindEnum';

  @override
  Object serialize(Serializers serializers, KitchenHistoryEntryKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KitchenHistoryEntryKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KitchenHistoryEntryKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KitchenHistoryEntry extends KitchenHistoryEntry {
  @override
  final KitchenHistoryEntryKindEnum kind;
  @override
  final String? id;
  @override
  final int? sequence;
  @override
  final DateTime at;
  @override
  final String? staffName;
  @override
  final String? deviceId;
  @override
  final String? reasonCode;
  @override
  final String? note;
  @override
  final bool? wasted;
  @override
  final String? approverName;
  @override
  final BuiltList<KitchenHistoryItem> items;

  factory _$KitchenHistoryEntry(
          [void Function(KitchenHistoryEntryBuilder)? updates]) =>
      (KitchenHistoryEntryBuilder()..update(updates))._build();

  _$KitchenHistoryEntry._(
      {required this.kind,
      this.id,
      this.sequence,
      required this.at,
      this.staffName,
      this.deviceId,
      this.reasonCode,
      this.note,
      this.wasted,
      this.approverName,
      required this.items})
      : super._();
  @override
  KitchenHistoryEntry rebuild(
          void Function(KitchenHistoryEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenHistoryEntryBuilder toBuilder() =>
      KitchenHistoryEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenHistoryEntry &&
        kind == other.kind &&
        id == other.id &&
        sequence == other.sequence &&
        at == other.at &&
        staffName == other.staffName &&
        deviceId == other.deviceId &&
        reasonCode == other.reasonCode &&
        note == other.note &&
        wasted == other.wasted &&
        approverName == other.approverName &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, sequence.hashCode);
    _$hash = $jc(_$hash, at.hashCode);
    _$hash = $jc(_$hash, staffName.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, wasted.hashCode);
    _$hash = $jc(_$hash, approverName.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenHistoryEntry')
          ..add('kind', kind)
          ..add('id', id)
          ..add('sequence', sequence)
          ..add('at', at)
          ..add('staffName', staffName)
          ..add('deviceId', deviceId)
          ..add('reasonCode', reasonCode)
          ..add('note', note)
          ..add('wasted', wasted)
          ..add('approverName', approverName)
          ..add('items', items))
        .toString();
  }
}

class KitchenHistoryEntryBuilder
    implements Builder<KitchenHistoryEntry, KitchenHistoryEntryBuilder> {
  _$KitchenHistoryEntry? _$v;

  KitchenHistoryEntryKindEnum? _kind;
  KitchenHistoryEntryKindEnum? get kind => _$this._kind;
  set kind(KitchenHistoryEntryKindEnum? kind) => _$this._kind = kind;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _sequence;
  int? get sequence => _$this._sequence;
  set sequence(int? sequence) => _$this._sequence = sequence;

  DateTime? _at;
  DateTime? get at => _$this._at;
  set at(DateTime? at) => _$this._at = at;

  String? _staffName;
  String? get staffName => _$this._staffName;
  set staffName(String? staffName) => _$this._staffName = staffName;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  bool? _wasted;
  bool? get wasted => _$this._wasted;
  set wasted(bool? wasted) => _$this._wasted = wasted;

  String? _approverName;
  String? get approverName => _$this._approverName;
  set approverName(String? approverName) => _$this._approverName = approverName;

  ListBuilder<KitchenHistoryItem>? _items;
  ListBuilder<KitchenHistoryItem> get items =>
      _$this._items ??= ListBuilder<KitchenHistoryItem>();
  set items(ListBuilder<KitchenHistoryItem>? items) => _$this._items = items;

  KitchenHistoryEntryBuilder() {
    KitchenHistoryEntry._defaults(this);
  }

  KitchenHistoryEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _id = $v.id;
      _sequence = $v.sequence;
      _at = $v.at;
      _staffName = $v.staffName;
      _deviceId = $v.deviceId;
      _reasonCode = $v.reasonCode;
      _note = $v.note;
      _wasted = $v.wasted;
      _approverName = $v.approverName;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenHistoryEntry other) {
    _$v = other as _$KitchenHistoryEntry;
  }

  @override
  void update(void Function(KitchenHistoryEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenHistoryEntry build() => _build();

  _$KitchenHistoryEntry _build() {
    _$KitchenHistoryEntry _$result;
    try {
      _$result = _$v ??
          _$KitchenHistoryEntry._(
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'KitchenHistoryEntry', 'kind'),
            id: id,
            sequence: sequence,
            at: BuiltValueNullFieldError.checkNotNull(
                at, r'KitchenHistoryEntry', 'at'),
            staffName: staffName,
            deviceId: deviceId,
            reasonCode: reasonCode,
            note: note,
            wasted: wasted,
            approverName: approverName,
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenHistoryEntry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
