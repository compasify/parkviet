//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_split_plan.g.dart';

/// MealSplitPlan
///
/// Properties:
/// * [mealAccountId]
/// * [payMode]
/// * [total]
/// * [sponsorId]
/// * [sponsorName]
/// * [sponsorAmount]
/// * [employeeAmount]
/// * [sponsorUnavailable]
@BuiltValue()
abstract class MealSplitPlan
    implements Built<MealSplitPlan, MealSplitPlanBuilder> {
  @BuiltValueField(wireName: r'meal_account_id')
  String? get mealAccountId;

  @BuiltValueField(wireName: r'pay_mode')
  String? get payMode;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'sponsor_id')
  String? get sponsorId;

  @BuiltValueField(wireName: r'sponsor_name')
  String? get sponsorName;

  @BuiltValueField(wireName: r'sponsor_amount')
  String get sponsorAmount;

  @BuiltValueField(wireName: r'employee_amount')
  String get employeeAmount;

  @BuiltValueField(wireName: r'sponsor_unavailable')
  bool get sponsorUnavailable;

  MealSplitPlan._();

  factory MealSplitPlan([void updates(MealSplitPlanBuilder b)]) =
      _$MealSplitPlan;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealSplitPlanBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealSplitPlan> get serializer =>
      _$MealSplitPlanSerializer();
}

class _$MealSplitPlanSerializer implements PrimitiveSerializer<MealSplitPlan> {
  @override
  final Iterable<Type> types = const [MealSplitPlan, _$MealSplitPlan];

  @override
  final String wireName = r'MealSplitPlan';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealSplitPlan object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.mealAccountId != null) {
      yield r'meal_account_id';
      yield serializers.serialize(
        object.mealAccountId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.payMode != null) {
      yield r'pay_mode';
      yield serializers.serialize(
        object.payMode,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    if (object.sponsorId != null) {
      yield r'sponsor_id';
      yield serializers.serialize(
        object.sponsorId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sponsorName != null) {
      yield r'sponsor_name';
      yield serializers.serialize(
        object.sponsorName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'sponsor_amount';
    yield serializers.serialize(
      object.sponsorAmount,
      specifiedType: const FullType(String),
    );
    yield r'employee_amount';
    yield serializers.serialize(
      object.employeeAmount,
      specifiedType: const FullType(String),
    );
    yield r'sponsor_unavailable';
    yield serializers.serialize(
      object.sponsorUnavailable,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MealSplitPlan object, {
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
    required MealSplitPlanBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'meal_account_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mealAccountId = valueDes;
          break;
        case r'pay_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.payMode = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        case r'sponsor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sponsorId = valueDes;
          break;
        case r'sponsor_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sponsorName = valueDes;
          break;
        case r'sponsor_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sponsorAmount = valueDes;
          break;
        case r'employee_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.employeeAmount = valueDes;
          break;
        case r'sponsor_unavailable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.sponsorUnavailable = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MealSplitPlan deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealSplitPlanBuilder();
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
