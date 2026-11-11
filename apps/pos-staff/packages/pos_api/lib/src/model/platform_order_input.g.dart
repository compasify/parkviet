// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_order_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlatformOrderInputPlatformEnum _$platformOrderInputPlatformEnum_grabfood =
    const PlatformOrderInputPlatformEnum._('grabfood');
const PlatformOrderInputPlatformEnum
    _$platformOrderInputPlatformEnum_shopeefood =
    const PlatformOrderInputPlatformEnum._('shopeefood');

PlatformOrderInputPlatformEnum _$platformOrderInputPlatformEnumValueOf(
    String name) {
  switch (name) {
    case 'grabfood':
      return _$platformOrderInputPlatformEnum_grabfood;
    case 'shopeefood':
      return _$platformOrderInputPlatformEnum_shopeefood;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlatformOrderInputPlatformEnum>
    _$platformOrderInputPlatformEnumValues = BuiltSet<
        PlatformOrderInputPlatformEnum>(const <PlatformOrderInputPlatformEnum>[
  _$platformOrderInputPlatformEnum_grabfood,
  _$platformOrderInputPlatformEnum_shopeefood,
]);

Serializer<PlatformOrderInputPlatformEnum>
    _$platformOrderInputPlatformEnumSerializer =
    _$PlatformOrderInputPlatformEnumSerializer();

class _$PlatformOrderInputPlatformEnumSerializer
    implements PrimitiveSerializer<PlatformOrderInputPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'grabfood': 'grabfood',
    'shopeefood': 'shopeefood',
  };

  @override
  final Iterable<Type> types = const <Type>[PlatformOrderInputPlatformEnum];
  @override
  final String wireName = 'PlatformOrderInputPlatformEnum';

  @override
  Object serialize(
          Serializers serializers, PlatformOrderInputPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlatformOrderInputPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlatformOrderInputPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlatformOrderInput extends PlatformOrderInput {
  @override
  final String editorId;
  @override
  final String? registerId;
  @override
  final String? branchId;
  @override
  final PlatformOrderInputPlatformEnum platform;
  @override
  final String platformOrderRef;
  @override
  final String? pickupCode;
  @override
  final String? note;
  @override
  final BuiltList<PlatformOrderLineInput> lines;

  factory _$PlatformOrderInput(
          [void Function(PlatformOrderInputBuilder)? updates]) =>
      (PlatformOrderInputBuilder()..update(updates))._build();

  _$PlatformOrderInput._(
      {required this.editorId,
      this.registerId,
      this.branchId,
      required this.platform,
      required this.platformOrderRef,
      this.pickupCode,
      this.note,
      required this.lines})
      : super._();
  @override
  PlatformOrderInput rebuild(
          void Function(PlatformOrderInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformOrderInputBuilder toBuilder() =>
      PlatformOrderInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformOrderInput &&
        editorId == other.editorId &&
        registerId == other.registerId &&
        branchId == other.branchId &&
        platform == other.platform &&
        platformOrderRef == other.platformOrderRef &&
        pickupCode == other.pickupCode &&
        note == other.note &&
        lines == other.lines;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, registerId.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, platformOrderRef.hashCode);
    _$hash = $jc(_$hash, pickupCode.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformOrderInput')
          ..add('editorId', editorId)
          ..add('registerId', registerId)
          ..add('branchId', branchId)
          ..add('platform', platform)
          ..add('platformOrderRef', platformOrderRef)
          ..add('pickupCode', pickupCode)
          ..add('note', note)
          ..add('lines', lines))
        .toString();
  }
}

class PlatformOrderInputBuilder
    implements Builder<PlatformOrderInput, PlatformOrderInputBuilder> {
  _$PlatformOrderInput? _$v;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  String? _registerId;
  String? get registerId => _$this._registerId;
  set registerId(String? registerId) => _$this._registerId = registerId;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  PlatformOrderInputPlatformEnum? _platform;
  PlatformOrderInputPlatformEnum? get platform => _$this._platform;
  set platform(PlatformOrderInputPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _platformOrderRef;
  String? get platformOrderRef => _$this._platformOrderRef;
  set platformOrderRef(String? platformOrderRef) =>
      _$this._platformOrderRef = platformOrderRef;

  String? _pickupCode;
  String? get pickupCode => _$this._pickupCode;
  set pickupCode(String? pickupCode) => _$this._pickupCode = pickupCode;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<PlatformOrderLineInput>? _lines;
  ListBuilder<PlatformOrderLineInput> get lines =>
      _$this._lines ??= ListBuilder<PlatformOrderLineInput>();
  set lines(ListBuilder<PlatformOrderLineInput>? lines) =>
      _$this._lines = lines;

  PlatformOrderInputBuilder() {
    PlatformOrderInput._defaults(this);
  }

  PlatformOrderInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _editorId = $v.editorId;
      _registerId = $v.registerId;
      _branchId = $v.branchId;
      _platform = $v.platform;
      _platformOrderRef = $v.platformOrderRef;
      _pickupCode = $v.pickupCode;
      _note = $v.note;
      _lines = $v.lines.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformOrderInput other) {
    _$v = other as _$PlatformOrderInput;
  }

  @override
  void update(void Function(PlatformOrderInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformOrderInput build() => _build();

  _$PlatformOrderInput _build() {
    _$PlatformOrderInput _$result;
    try {
      _$result = _$v ??
          _$PlatformOrderInput._(
            editorId: BuiltValueNullFieldError.checkNotNull(
                editorId, r'PlatformOrderInput', 'editorId'),
            registerId: registerId,
            branchId: branchId,
            platform: BuiltValueNullFieldError.checkNotNull(
                platform, r'PlatformOrderInput', 'platform'),
            platformOrderRef: BuiltValueNullFieldError.checkNotNull(
                platformOrderRef, r'PlatformOrderInput', 'platformOrderRef'),
            pickupCode: pickupCode,
            note: note,
            lines: lines.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lines';
        lines.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlatformOrderInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
