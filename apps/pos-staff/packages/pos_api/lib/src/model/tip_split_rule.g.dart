// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_split_rule.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TipSplitRuleModeEnum _$tipSplitRuleModeEnum_equal =
    const TipSplitRuleModeEnum._('equal');
const TipSplitRuleModeEnum _$tipSplitRuleModeEnum_byHours =
    const TipSplitRuleModeEnum._('byHours');
const TipSplitRuleModeEnum _$tipSplitRuleModeEnum_manual =
    const TipSplitRuleModeEnum._('manual');

TipSplitRuleModeEnum _$tipSplitRuleModeEnumValueOf(String name) {
  switch (name) {
    case 'equal':
      return _$tipSplitRuleModeEnum_equal;
    case 'byHours':
      return _$tipSplitRuleModeEnum_byHours;
    case 'manual':
      return _$tipSplitRuleModeEnum_manual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TipSplitRuleModeEnum> _$tipSplitRuleModeEnumValues =
    BuiltSet<TipSplitRuleModeEnum>(const <TipSplitRuleModeEnum>[
  _$tipSplitRuleModeEnum_equal,
  _$tipSplitRuleModeEnum_byHours,
  _$tipSplitRuleModeEnum_manual,
]);

Serializer<TipSplitRuleModeEnum> _$tipSplitRuleModeEnumSerializer =
    _$TipSplitRuleModeEnumSerializer();

class _$TipSplitRuleModeEnumSerializer
    implements PrimitiveSerializer<TipSplitRuleModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'equal': 'equal',
    'byHours': 'by_hours',
    'manual': 'manual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'equal': 'equal',
    'by_hours': 'byHours',
    'manual': 'manual',
  };

  @override
  final Iterable<Type> types = const <Type>[TipSplitRuleModeEnum];
  @override
  final String wireName = 'TipSplitRuleModeEnum';

  @override
  Object serialize(Serializers serializers, TipSplitRuleModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TipSplitRuleModeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TipSplitRuleModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TipSplitRule extends TipSplitRule {
  @override
  final TipSplitRuleModeEnum mode;
  @override
  final BuiltList<String> roleCodes;

  factory _$TipSplitRule([void Function(TipSplitRuleBuilder)? updates]) =>
      (TipSplitRuleBuilder()..update(updates))._build();

  _$TipSplitRule._({required this.mode, required this.roleCodes}) : super._();
  @override
  TipSplitRule rebuild(void Function(TipSplitRuleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TipSplitRuleBuilder toBuilder() => TipSplitRuleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TipSplitRule &&
        mode == other.mode &&
        roleCodes == other.roleCodes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, roleCodes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TipSplitRule')
          ..add('mode', mode)
          ..add('roleCodes', roleCodes))
        .toString();
  }
}

class TipSplitRuleBuilder
    implements Builder<TipSplitRule, TipSplitRuleBuilder> {
  _$TipSplitRule? _$v;

  TipSplitRuleModeEnum? _mode;
  TipSplitRuleModeEnum? get mode => _$this._mode;
  set mode(TipSplitRuleModeEnum? mode) => _$this._mode = mode;

  ListBuilder<String>? _roleCodes;
  ListBuilder<String> get roleCodes =>
      _$this._roleCodes ??= ListBuilder<String>();
  set roleCodes(ListBuilder<String>? roleCodes) =>
      _$this._roleCodes = roleCodes;

  TipSplitRuleBuilder() {
    TipSplitRule._defaults(this);
  }

  TipSplitRuleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mode = $v.mode;
      _roleCodes = $v.roleCodes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TipSplitRule other) {
    _$v = other as _$TipSplitRule;
  }

  @override
  void update(void Function(TipSplitRuleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TipSplitRule build() => _build();

  _$TipSplitRule _build() {
    _$TipSplitRule _$result;
    try {
      _$result = _$v ??
          _$TipSplitRule._(
            mode: BuiltValueNullFieldError.checkNotNull(
                mode, r'TipSplitRule', 'mode'),
            roleCodes: roleCodes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roleCodes';
        roleCodes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TipSplitRule', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
