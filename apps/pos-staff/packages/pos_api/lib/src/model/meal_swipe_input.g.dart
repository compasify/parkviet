// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_swipe_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MealSwipeInputInputMethodEnum _$mealSwipeInputInputMethodEnum_code =
    const MealSwipeInputInputMethodEnum._('code');
const MealSwipeInputInputMethodEnum _$mealSwipeInputInputMethodEnum_search =
    const MealSwipeInputInputMethodEnum._('search');

MealSwipeInputInputMethodEnum _$mealSwipeInputInputMethodEnumValueOf(
    String name) {
  switch (name) {
    case 'code':
      return _$mealSwipeInputInputMethodEnum_code;
    case 'search':
      return _$mealSwipeInputInputMethodEnum_search;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MealSwipeInputInputMethodEnum>
    _$mealSwipeInputInputMethodEnumValues = BuiltSet<
        MealSwipeInputInputMethodEnum>(const <MealSwipeInputInputMethodEnum>[
  _$mealSwipeInputInputMethodEnum_code,
  _$mealSwipeInputInputMethodEnum_search,
]);

Serializer<MealSwipeInputInputMethodEnum>
    _$mealSwipeInputInputMethodEnumSerializer =
    _$MealSwipeInputInputMethodEnumSerializer();

class _$MealSwipeInputInputMethodEnumSerializer
    implements PrimitiveSerializer<MealSwipeInputInputMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'code': 'code',
    'search': 'search',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'code': 'code',
    'search': 'search',
  };

  @override
  final Iterable<Type> types = const <Type>[MealSwipeInputInputMethodEnum];
  @override
  final String wireName = 'MealSwipeInputInputMethodEnum';

  @override
  Object serialize(
          Serializers serializers, MealSwipeInputInputMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MealSwipeInputInputMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MealSwipeInputInputMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MealSwipeInput extends MealSwipeInput {
  @override
  final int expectedRevision;
  @override
  final int leaseGeneration;
  @override
  final String editorId;
  @override
  final String? code;
  @override
  final String? mealAccountId;
  @override
  final MealSwipeInputInputMethodEnum? inputMethod;
  @override
  final String? approvalId;
  @override
  final bool? overrideLimit;

  factory _$MealSwipeInput([void Function(MealSwipeInputBuilder)? updates]) =>
      (MealSwipeInputBuilder()..update(updates))._build();

  _$MealSwipeInput._(
      {required this.expectedRevision,
      required this.leaseGeneration,
      required this.editorId,
      this.code,
      this.mealAccountId,
      this.inputMethod,
      this.approvalId,
      this.overrideLimit})
      : super._();
  @override
  MealSwipeInput rebuild(void Function(MealSwipeInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealSwipeInputBuilder toBuilder() => MealSwipeInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealSwipeInput &&
        expectedRevision == other.expectedRevision &&
        leaseGeneration == other.leaseGeneration &&
        editorId == other.editorId &&
        code == other.code &&
        mealAccountId == other.mealAccountId &&
        inputMethod == other.inputMethod &&
        approvalId == other.approvalId &&
        overrideLimit == other.overrideLimit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedRevision.hashCode);
    _$hash = $jc(_$hash, leaseGeneration.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, mealAccountId.hashCode);
    _$hash = $jc(_$hash, inputMethod.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, overrideLimit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MealSwipeInput')
          ..add('expectedRevision', expectedRevision)
          ..add('leaseGeneration', leaseGeneration)
          ..add('editorId', editorId)
          ..add('code', code)
          ..add('mealAccountId', mealAccountId)
          ..add('inputMethod', inputMethod)
          ..add('approvalId', approvalId)
          ..add('overrideLimit', overrideLimit))
        .toString();
  }
}

class MealSwipeInputBuilder
    implements Builder<MealSwipeInput, MealSwipeInputBuilder> {
  _$MealSwipeInput? _$v;

  int? _expectedRevision;
  int? get expectedRevision => _$this._expectedRevision;
  set expectedRevision(int? expectedRevision) =>
      _$this._expectedRevision = expectedRevision;

  int? _leaseGeneration;
  int? get leaseGeneration => _$this._leaseGeneration;
  set leaseGeneration(int? leaseGeneration) =>
      _$this._leaseGeneration = leaseGeneration;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _mealAccountId;
  String? get mealAccountId => _$this._mealAccountId;
  set mealAccountId(String? mealAccountId) =>
      _$this._mealAccountId = mealAccountId;

  MealSwipeInputInputMethodEnum? _inputMethod;
  MealSwipeInputInputMethodEnum? get inputMethod => _$this._inputMethod;
  set inputMethod(MealSwipeInputInputMethodEnum? inputMethod) =>
      _$this._inputMethod = inputMethod;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  bool? _overrideLimit;
  bool? get overrideLimit => _$this._overrideLimit;
  set overrideLimit(bool? overrideLimit) =>
      _$this._overrideLimit = overrideLimit;

  MealSwipeInputBuilder() {
    MealSwipeInput._defaults(this);
  }

  MealSwipeInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedRevision = $v.expectedRevision;
      _leaseGeneration = $v.leaseGeneration;
      _editorId = $v.editorId;
      _code = $v.code;
      _mealAccountId = $v.mealAccountId;
      _inputMethod = $v.inputMethod;
      _approvalId = $v.approvalId;
      _overrideLimit = $v.overrideLimit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MealSwipeInput other) {
    _$v = other as _$MealSwipeInput;
  }

  @override
  void update(void Function(MealSwipeInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealSwipeInput build() => _build();

  _$MealSwipeInput _build() {
    final _$result = _$v ??
        _$MealSwipeInput._(
          expectedRevision: BuiltValueNullFieldError.checkNotNull(
              expectedRevision, r'MealSwipeInput', 'expectedRevision'),
          leaseGeneration: BuiltValueNullFieldError.checkNotNull(
              leaseGeneration, r'MealSwipeInput', 'leaseGeneration'),
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'MealSwipeInput', 'editorId'),
          code: code,
          mealAccountId: mealAccountId,
          inputMethod: inputMethod,
          approvalId: approvalId,
          overrideLimit: overrideLimit,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
