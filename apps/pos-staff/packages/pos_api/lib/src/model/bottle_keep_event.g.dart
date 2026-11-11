// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottle_keep_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BottleKeepEventKindEnum _$bottleKeepEventKindEnum_open =
    const BottleKeepEventKindEnum._('open');
const BottleKeepEventKindEnum _$bottleKeepEventKindEnum_pour =
    const BottleKeepEventKindEnum._('pour');
const BottleKeepEventKindEnum _$bottleKeepEventKindEnum_adjust =
    const BottleKeepEventKindEnum._('adjust');
const BottleKeepEventKindEnum _$bottleKeepEventKindEnum_expire =
    const BottleKeepEventKindEnum._('expire');
const BottleKeepEventKindEnum _$bottleKeepEventKindEnum_return_ =
    const BottleKeepEventKindEnum._('return_');

BottleKeepEventKindEnum _$bottleKeepEventKindEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$bottleKeepEventKindEnum_open;
    case 'pour':
      return _$bottleKeepEventKindEnum_pour;
    case 'adjust':
      return _$bottleKeepEventKindEnum_adjust;
    case 'expire':
      return _$bottleKeepEventKindEnum_expire;
    case 'return_':
      return _$bottleKeepEventKindEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BottleKeepEventKindEnum> _$bottleKeepEventKindEnumValues =
    BuiltSet<BottleKeepEventKindEnum>(const <BottleKeepEventKindEnum>[
  _$bottleKeepEventKindEnum_open,
  _$bottleKeepEventKindEnum_pour,
  _$bottleKeepEventKindEnum_adjust,
  _$bottleKeepEventKindEnum_expire,
  _$bottleKeepEventKindEnum_return_,
]);

Serializer<BottleKeepEventKindEnum> _$bottleKeepEventKindEnumSerializer =
    _$BottleKeepEventKindEnumSerializer();

class _$BottleKeepEventKindEnumSerializer
    implements PrimitiveSerializer<BottleKeepEventKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'pour': 'pour',
    'adjust': 'adjust',
    'expire': 'expire',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'pour': 'pour',
    'adjust': 'adjust',
    'expire': 'expire',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[BottleKeepEventKindEnum];
  @override
  final String wireName = 'BottleKeepEventKindEnum';

  @override
  Object serialize(Serializers serializers, BottleKeepEventKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BottleKeepEventKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BottleKeepEventKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BottleKeepEvent extends BottleKeepEvent {
  @override
  final String id;
  @override
  final BottleKeepEventKindEnum kind;
  @override
  final int? levelBefore;
  @override
  final int levelAfter;
  @override
  final int? ml;
  @override
  final String? workspaceId;
  @override
  final String? approvalId;
  @override
  final BottleKeepActor actor;
  @override
  final String? note;
  @override
  final DateTime createdAt;

  factory _$BottleKeepEvent([void Function(BottleKeepEventBuilder)? updates]) =>
      (BottleKeepEventBuilder()..update(updates))._build();

  _$BottleKeepEvent._(
      {required this.id,
      required this.kind,
      this.levelBefore,
      required this.levelAfter,
      this.ml,
      this.workspaceId,
      this.approvalId,
      required this.actor,
      this.note,
      required this.createdAt})
      : super._();
  @override
  BottleKeepEvent rebuild(void Function(BottleKeepEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BottleKeepEventBuilder toBuilder() => BottleKeepEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BottleKeepEvent &&
        id == other.id &&
        kind == other.kind &&
        levelBefore == other.levelBefore &&
        levelAfter == other.levelAfter &&
        ml == other.ml &&
        workspaceId == other.workspaceId &&
        approvalId == other.approvalId &&
        actor == other.actor &&
        note == other.note &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, levelBefore.hashCode);
    _$hash = $jc(_$hash, levelAfter.hashCode);
    _$hash = $jc(_$hash, ml.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, actor.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BottleKeepEvent')
          ..add('id', id)
          ..add('kind', kind)
          ..add('levelBefore', levelBefore)
          ..add('levelAfter', levelAfter)
          ..add('ml', ml)
          ..add('workspaceId', workspaceId)
          ..add('approvalId', approvalId)
          ..add('actor', actor)
          ..add('note', note)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class BottleKeepEventBuilder
    implements Builder<BottleKeepEvent, BottleKeepEventBuilder> {
  _$BottleKeepEvent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  BottleKeepEventKindEnum? _kind;
  BottleKeepEventKindEnum? get kind => _$this._kind;
  set kind(BottleKeepEventKindEnum? kind) => _$this._kind = kind;

  int? _levelBefore;
  int? get levelBefore => _$this._levelBefore;
  set levelBefore(int? levelBefore) => _$this._levelBefore = levelBefore;

  int? _levelAfter;
  int? get levelAfter => _$this._levelAfter;
  set levelAfter(int? levelAfter) => _$this._levelAfter = levelAfter;

  int? _ml;
  int? get ml => _$this._ml;
  set ml(int? ml) => _$this._ml = ml;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  BottleKeepActorBuilder? _actor;
  BottleKeepActorBuilder get actor =>
      _$this._actor ??= BottleKeepActorBuilder();
  set actor(BottleKeepActorBuilder? actor) => _$this._actor = actor;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  BottleKeepEventBuilder() {
    BottleKeepEvent._defaults(this);
  }

  BottleKeepEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _levelBefore = $v.levelBefore;
      _levelAfter = $v.levelAfter;
      _ml = $v.ml;
      _workspaceId = $v.workspaceId;
      _approvalId = $v.approvalId;
      _actor = $v.actor.toBuilder();
      _note = $v.note;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BottleKeepEvent other) {
    _$v = other as _$BottleKeepEvent;
  }

  @override
  void update(void Function(BottleKeepEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BottleKeepEvent build() => _build();

  _$BottleKeepEvent _build() {
    _$BottleKeepEvent _$result;
    try {
      _$result = _$v ??
          _$BottleKeepEvent._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'BottleKeepEvent', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'BottleKeepEvent', 'kind'),
            levelBefore: levelBefore,
            levelAfter: BuiltValueNullFieldError.checkNotNull(
                levelAfter, r'BottleKeepEvent', 'levelAfter'),
            ml: ml,
            workspaceId: workspaceId,
            approvalId: approvalId,
            actor: actor.build(),
            note: note,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'BottleKeepEvent', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'actor';
        actor.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BottleKeepEvent', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
