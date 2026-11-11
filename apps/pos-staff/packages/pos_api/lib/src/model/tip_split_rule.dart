//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tip_split_rule.g.dart';

/// TipSplitRule
///
/// Properties:
/// * [mode]
/// * [roleCodes] - Staff roles that share tips; every role when empty.
@BuiltValue()
abstract class TipSplitRule
    implements Built<TipSplitRule, TipSplitRuleBuilder> {
  @BuiltValueField(wireName: r'mode')
  TipSplitRuleModeEnum get mode;
  // enum modeEnum {  equal,  by_hours,  manual,  };

  /// Staff roles that share tips; every role when empty.
  @BuiltValueField(wireName: r'role_codes')
  BuiltList<String> get roleCodes;

  TipSplitRule._();

  factory TipSplitRule([void updates(TipSplitRuleBuilder b)]) = _$TipSplitRule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TipSplitRuleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TipSplitRule> get serializer => _$TipSplitRuleSerializer();
}

class _$TipSplitRuleSerializer implements PrimitiveSerializer<TipSplitRule> {
  @override
  final Iterable<Type> types = const [TipSplitRule, _$TipSplitRule];

  @override
  final String wireName = r'TipSplitRule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TipSplitRule object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(TipSplitRuleModeEnum),
    );
    yield r'role_codes';
    yield serializers.serialize(
      object.roleCodes,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TipSplitRule object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TipSplitRuleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TipSplitRuleModeEnum),
          ) as TipSplitRuleModeEnum;
          result.mode = valueDes;
          break;
        case r'role_codes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.roleCodes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TipSplitRule deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TipSplitRuleBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class TipSplitRuleModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'equal')
  static const TipSplitRuleModeEnum equal = _$tipSplitRuleModeEnum_equal;
  @BuiltValueEnumConst(wireName: r'by_hours')
  static const TipSplitRuleModeEnum byHours = _$tipSplitRuleModeEnum_byHours;
  @BuiltValueEnumConst(wireName: r'manual')
  static const TipSplitRuleModeEnum manual = _$tipSplitRuleModeEnum_manual;

  static Serializer<TipSplitRuleModeEnum> get serializer =>
      _$tipSplitRuleModeEnumSerializer;

  const TipSplitRuleModeEnum._(String name) : super(name);

  static BuiltSet<TipSplitRuleModeEnum> get values =>
      _$tipSplitRuleModeEnumValues;
  static TipSplitRuleModeEnum valueOf(String name) =>
      _$tipSplitRuleModeEnumValueOf(name);
}
