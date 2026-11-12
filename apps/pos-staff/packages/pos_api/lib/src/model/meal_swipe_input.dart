//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_swipe_input.g.dart';

/// MealSwipeInput
///
/// Properties:
/// * [expectedRevision]
/// * [leaseGeneration]
/// * [editorId]
/// * [code]
/// * [mealAccountId]
/// * [inputMethod]
/// * [approvalId]
/// * [overrideLimit] - Let a meal-time or limit refusal through on an approval.
@BuiltValue()
abstract class MealSwipeInput
    implements Built<MealSwipeInput, MealSwipeInputBuilder> {
  @BuiltValueField(wireName: r'expected_revision')
  int get expectedRevision;

  @BuiltValueField(wireName: r'lease_generation')
  int get leaseGeneration;

  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  @BuiltValueField(wireName: r'code')
  String? get code;

  @BuiltValueField(wireName: r'meal_account_id')
  String? get mealAccountId;

  @BuiltValueField(wireName: r'input_method')
  MealSwipeInputInputMethodEnum? get inputMethod;
  // enum inputMethodEnum {  code,  search,  };

  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  /// Let a meal-time or limit refusal through on an approval.
  @BuiltValueField(wireName: r'override_limit')
  bool? get overrideLimit;

  MealSwipeInput._();

  factory MealSwipeInput([void updates(MealSwipeInputBuilder b)]) =
      _$MealSwipeInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealSwipeInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealSwipeInput> get serializer =>
      _$MealSwipeInputSerializer();
}

class _$MealSwipeInputSerializer
    implements PrimitiveSerializer<MealSwipeInput> {
  @override
  final Iterable<Type> types = const [MealSwipeInput, _$MealSwipeInput];

  @override
  final String wireName = r'MealSwipeInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealSwipeInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expected_revision';
    yield serializers.serialize(
      object.expectedRevision,
      specifiedType: const FullType(int),
    );
    yield r'lease_generation';
    yield serializers.serialize(
      object.leaseGeneration,
      specifiedType: const FullType(int),
    );
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(String),
      );
    }
    if (object.mealAccountId != null) {
      yield r'meal_account_id';
      yield serializers.serialize(
        object.mealAccountId,
        specifiedType: const FullType(String),
      );
    }
    if (object.inputMethod != null) {
      yield r'input_method';
      yield serializers.serialize(
        object.inputMethod,
        specifiedType: const FullType(MealSwipeInputInputMethodEnum),
      );
    }
    if (object.approvalId != null) {
      yield r'approval_id';
      yield serializers.serialize(
        object.approvalId,
        specifiedType: const FullType(String),
      );
    }
    if (object.overrideLimit != null) {
      yield r'override_limit';
      yield serializers.serialize(
        object.overrideLimit,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MealSwipeInput object, {
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
    required MealSwipeInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expected_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedRevision = valueDes;
          break;
        case r'lease_generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.leaseGeneration = valueDes;
          break;
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorId = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        case r'meal_account_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mealAccountId = valueDes;
          break;
        case r'input_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(MealSwipeInputInputMethodEnum),
          ) as MealSwipeInputInputMethodEnum?;
          if (valueDes == null) continue;
          result.inputMethod = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        case r'override_limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.overrideLimit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MealSwipeInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealSwipeInputBuilder();
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

class MealSwipeInputInputMethodEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'code')
  static const MealSwipeInputInputMethodEnum code =
      _$mealSwipeInputInputMethodEnum_code;
  @BuiltValueEnumConst(wireName: r'search')
  static const MealSwipeInputInputMethodEnum search =
      _$mealSwipeInputInputMethodEnum_search;

  static Serializer<MealSwipeInputInputMethodEnum> get serializer =>
      _$mealSwipeInputInputMethodEnumSerializer;

  const MealSwipeInputInputMethodEnum._(String name) : super(name);

  static BuiltSet<MealSwipeInputInputMethodEnum> get values =>
      _$mealSwipeInputInputMethodEnumValues;
  static MealSwipeInputInputMethodEnum valueOf(String name) =>
      _$mealSwipeInputInputMethodEnumValueOf(name);
}
