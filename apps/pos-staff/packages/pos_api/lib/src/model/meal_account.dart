//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/meal_sponsor_ref.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/meal_window.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_account.g.dart';

/// MealAccount
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
@BuiltValue(instantiable: false)
abstract class MealAccount {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'employee_code')
  String get employeeCode;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'customer_id')
  String? get customerId;

  @BuiltValueField(wireName: r'group_label')
  String? get groupLabel;

  @BuiltValueField(wireName: r'sponsor')
  MealSponsorRef? get sponsor;

  @BuiltValueField(wireName: r'pay_mode')
  MealAccountPayModeEnum get payMode;
  // enum payModeEnum {  wallet,  sponsor,  sponsor_subsidy,  };

  @BuiltValueField(wireName: r'daily_meal_limit')
  int? get dailyMealLimit;

  @BuiltValueField(wireName: r'meal_windows')
  BuiltList<MealWindow>? get mealWindows;

  @BuiltValueField(wireName: r'low_balance_threshold')
  String? get lowBalanceThreshold;

  @BuiltValueField(wireName: r'balance')
  String get balance;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'status')
  MealAccountStatusEnum get status;
  // enum statusEnum {  active,  locked,  };

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealAccount> get serializer => _$MealAccountSerializer();
}

class _$MealAccountSerializer implements PrimitiveSerializer<MealAccount> {
  @override
  final Iterable<Type> types = const [MealAccount];

  @override
  final String wireName = r'MealAccount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealAccount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'employee_code';
    yield serializers.serialize(
      object.employeeCode,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null
        ? null
        : serializers.serialize(
            object.name,
            specifiedType: const FullType.nullable(String),
          );
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.customerId != null) {
      yield r'customer_id';
      yield serializers.serialize(
        object.customerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.groupLabel != null) {
      yield r'group_label';
      yield serializers.serialize(
        object.groupLabel,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sponsor != null) {
      yield r'sponsor';
      yield serializers.serialize(
        object.sponsor,
        specifiedType: const FullType.nullable(MealSponsorRef),
      );
    }
    yield r'pay_mode';
    yield serializers.serialize(
      object.payMode,
      specifiedType: const FullType(MealAccountPayModeEnum),
    );
    if (object.dailyMealLimit != null) {
      yield r'daily_meal_limit';
      yield serializers.serialize(
        object.dailyMealLimit,
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
    if (object.lowBalanceThreshold != null) {
      yield r'low_balance_threshold';
      yield serializers.serialize(
        object.lowBalanceThreshold,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(MealAccountStatusEnum),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
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
    MealAccount object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  @override
  MealAccount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized,
        specifiedType: FullType($MealAccount)) as $MealAccount;
  }
}

/// a concrete implementation of [MealAccount], since [MealAccount] is not instantiable
@BuiltValue(instantiable: true)
abstract class $MealAccount
    implements MealAccount, Built<$MealAccount, $MealAccountBuilder> {
  $MealAccount._();

  factory $MealAccount([void Function($MealAccountBuilder)? updates]) =
      _$$MealAccount;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($MealAccountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$MealAccount> get serializer => _$$MealAccountSerializer();
}

class _$$MealAccountSerializer implements PrimitiveSerializer<$MealAccount> {
  @override
  final Iterable<Type> types = const [$MealAccount, _$$MealAccount];

  @override
  final String wireName = r'$MealAccount';

  @override
  Object serialize(
    Serializers serializers,
    $MealAccount object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(MealAccount))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MealAccountBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'employee_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.employeeCode = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'customer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.customerId = valueDes;
          break;
        case r'group_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.groupLabel = valueDes;
          break;
        case r'sponsor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MealSponsorRef),
          ) as MealSponsorRef?;
          if (valueDes == null) continue;
          result.sponsor.replace(valueDes);
          break;
        case r'pay_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealAccountPayModeEnum),
          ) as MealAccountPayModeEnum;
          result.payMode = valueDes;
          break;
        case r'daily_meal_limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.dailyMealLimit = valueDes;
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
        case r'low_balance_threshold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lowBalanceThreshold = valueDes;
          break;
        case r'balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balance = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealAccountStatusEnum),
          ) as MealAccountStatusEnum;
          result.status = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
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
  $MealAccount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $MealAccountBuilder();
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

class MealAccountPayModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'wallet')
  static const MealAccountPayModeEnum wallet = _$mealAccountPayModeEnum_wallet;
  @BuiltValueEnumConst(wireName: r'sponsor')
  static const MealAccountPayModeEnum sponsor =
      _$mealAccountPayModeEnum_sponsor;
  @BuiltValueEnumConst(wireName: r'sponsor_subsidy')
  static const MealAccountPayModeEnum sponsorSubsidy =
      _$mealAccountPayModeEnum_sponsorSubsidy;

  static Serializer<MealAccountPayModeEnum> get serializer =>
      _$mealAccountPayModeEnumSerializer;

  const MealAccountPayModeEnum._(String name) : super(name);

  static BuiltSet<MealAccountPayModeEnum> get values =>
      _$mealAccountPayModeEnumValues;
  static MealAccountPayModeEnum valueOf(String name) =>
      _$mealAccountPayModeEnumValueOf(name);
}

class MealAccountStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const MealAccountStatusEnum active = _$mealAccountStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'locked')
  static const MealAccountStatusEnum locked = _$mealAccountStatusEnum_locked;

  static Serializer<MealAccountStatusEnum> get serializer =>
      _$mealAccountStatusEnumSerializer;

  const MealAccountStatusEnum._(String name) : super(name);

  static BuiltSet<MealAccountStatusEnum> get values =>
      _$mealAccountStatusEnumValues;
  static MealAccountStatusEnum valueOf(String name) =>
      _$mealAccountStatusEnumValueOf(name);
}
