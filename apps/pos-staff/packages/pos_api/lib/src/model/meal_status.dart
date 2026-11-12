//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/meal_sponsor_ref.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/meal_split_plan.dart';
import 'package:pos_api/src/model/meal_account.dart';
import 'package:pos_api/src/model/meal_window.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_status.g.dart';

/// MealStatus
///
/// Properties:
/// * [id]
/// * [employeeCode]
/// * [name]
/// * [phone]
/// * [customerId]
/// * [groupLabel]
/// * [sponsor]
/// * [payMode]
/// * [dailyMealLimit]
/// * [mealWindows]
/// * [lowBalanceThreshold]
/// * [balance]
/// * [currency]
/// * [status]
/// * [revision]
/// * [updatedAt]
/// * [mealsToday]
/// * [mealsLeft]
/// * [lowBalance]
/// * [walletCovers] - The wallet holds the eater's part of this order.
/// * [plan]
@BuiltValue()
abstract class MealStatus
    implements MealAccount, Built<MealStatus, MealStatusBuilder> {
  /// The wallet holds the eater's part of this order.
  @BuiltValueField(wireName: r'wallet_covers')
  bool get walletCovers;

  @BuiltValueField(wireName: r'meals_today')
  int get mealsToday;

  @BuiltValueField(wireName: r'low_balance')
  bool get lowBalance;

  @BuiltValueField(wireName: r'meals_left')
  int? get mealsLeft;

  @BuiltValueField(wireName: r'plan')
  MealSplitPlan get plan;

  MealStatus._();

  factory MealStatus([void updates(MealStatusBuilder b)]) = _$MealStatus;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealStatusBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealStatus> get serializer => _$MealStatusSerializer();
}

class _$MealStatusSerializer implements PrimitiveSerializer<MealStatus> {
  @override
  final Iterable<Type> types = const [MealStatus, _$MealStatus];

  @override
  final String wireName = r'MealStatus';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.sponsor != null) {
      yield r'sponsor';
      yield serializers.serialize(
        object.sponsor,
        specifiedType: const FullType.nullable(MealSponsorRef),
      );
    }
    if (object.lowBalanceThreshold != null) {
      yield r'low_balance_threshold';
      yield serializers.serialize(
        object.lowBalanceThreshold,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'pay_mode';
    yield serializers.serialize(
      object.payMode,
      specifiedType: const FullType(MealAccountPayModeEnum),
    );
    if (object.groupLabel != null) {
      yield r'group_label';
      yield serializers.serialize(
        object.groupLabel,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.mealsLeft != null) {
      yield r'meals_left';
      yield serializers.serialize(
        object.mealsLeft,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.mealWindows != null) {
      yield r'meal_windows';
      yield serializers.serialize(
        object.mealWindows,
        specifiedType: const FullType(BuiltList, [FullType(MealWindow)]),
      );
    }
    yield r'employee_code';
    yield serializers.serialize(
      object.employeeCode,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'wallet_covers';
    yield serializers.serialize(
      object.walletCovers,
      specifiedType: const FullType(bool),
    );
    if (object.dailyMealLimit != null) {
      yield r'daily_meal_limit';
      yield serializers.serialize(
        object.dailyMealLimit,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'name';
    yield object.name == null
        ? null
        : serializers.serialize(
            object.name,
            specifiedType: const FullType.nullable(String),
          );
    if (object.customerId != null) {
      yield r'customer_id';
      yield serializers.serialize(
        object.customerId,
        specifiedType: const FullType(String),
      );
    }
    yield r'meals_today';
    yield serializers.serialize(
      object.mealsToday,
      specifiedType: const FullType(int),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'low_balance';
    yield serializers.serialize(
      object.lowBalance,
      specifiedType: const FullType(bool),
    );
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(MealSplitPlan),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(MealAccountStatusEnum),
    );
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MealStatus object, {
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
    required MealStatusBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sponsor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MealSponsorRef),
          ) as MealSponsorRef?;
          if (valueDes == null) continue;
          result.sponsor.replace(valueDes);
          break;
        case r'low_balance_threshold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lowBalanceThreshold = valueDes;
          break;
        case r'pay_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealAccountPayModeEnum),
          ) as MealAccountPayModeEnum;
          result.payMode = valueDes;
          break;
        case r'group_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.groupLabel = valueDes;
          break;
        case r'meals_left':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.mealsLeft = valueDes;
          break;
        case r'meal_windows':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(MealWindow)]),
          ) as BuiltList<MealWindow>?;
          if (valueDes == null) continue;
          result.mealWindows.replace(valueDes);
          break;
        case r'employee_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.employeeCode = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'wallet_covers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.walletCovers = valueDes;
          break;
        case r'daily_meal_limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.dailyMealLimit = valueDes;
          break;
        case r'balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balance = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'customer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.customerId = valueDes;
          break;
        case r'meals_today':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.mealsToday = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'low_balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.lowBalance = valueDes;
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealSplitPlan),
          ) as MealSplitPlan;
          result.plan.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealAccountStatusEnum),
          ) as MealAccountStatusEnum;
          result.status = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MealStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealStatusBuilder();
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

class MealStatusPayModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'wallet')
  static const MealStatusPayModeEnum wallet = _$mealStatusPayModeEnum_wallet;
  @BuiltValueEnumConst(wireName: r'sponsor')
  static const MealStatusPayModeEnum sponsor = _$mealStatusPayModeEnum_sponsor;
  @BuiltValueEnumConst(wireName: r'sponsor_subsidy')
  static const MealStatusPayModeEnum sponsorSubsidy =
      _$mealStatusPayModeEnum_sponsorSubsidy;

  static Serializer<MealStatusPayModeEnum> get serializer =>
      _$mealStatusPayModeEnumSerializer;

  const MealStatusPayModeEnum._(String name) : super(name);

  static BuiltSet<MealStatusPayModeEnum> get values =>
      _$mealStatusPayModeEnumValues;
  static MealStatusPayModeEnum valueOf(String name) =>
      _$mealStatusPayModeEnumValueOf(name);
}

class MealStatusStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const MealStatusStatusEnum active = _$mealStatusStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'locked')
  static const MealStatusStatusEnum locked = _$mealStatusStatusEnum_locked;

  static Serializer<MealStatusStatusEnum> get serializer =>
      _$mealStatusStatusEnumSerializer;

  const MealStatusStatusEnum._(String name) : super(name);

  static BuiltSet<MealStatusStatusEnum> get values =>
      _$mealStatusStatusEnumValues;
  static MealStatusStatusEnum valueOf(String name) =>
      _$mealStatusStatusEnumValueOf(name);
}
