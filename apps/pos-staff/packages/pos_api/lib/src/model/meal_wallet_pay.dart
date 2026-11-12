//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace.dart';
import 'package:pos_api/src/model/meal_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_wallet_pay.g.dart';

/// MealWalletPay
///
/// Properties:
/// * [workspace]
/// * [meal]
@BuiltValue()
abstract class MealWalletPay
    implements Built<MealWalletPay, MealWalletPayBuilder> {
  @BuiltValueField(wireName: r'workspace')
  Workspace get workspace;

  @BuiltValueField(wireName: r'meal')
  MealStatus get meal;

  MealWalletPay._();

  factory MealWalletPay([void updates(MealWalletPayBuilder b)]) =
      _$MealWalletPay;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealWalletPayBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealWalletPay> get serializer =>
      _$MealWalletPaySerializer();
}

class _$MealWalletPaySerializer implements PrimitiveSerializer<MealWalletPay> {
  @override
  final Iterable<Type> types = const [MealWalletPay, _$MealWalletPay];

  @override
  final String wireName = r'MealWalletPay';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealWalletPay object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace';
    yield serializers.serialize(
      object.workspace,
      specifiedType: const FullType(Workspace),
    );
    yield r'meal';
    yield serializers.serialize(
      object.meal,
      specifiedType: const FullType(MealStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MealWalletPay object, {
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
    required MealWalletPayBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Workspace),
          ) as Workspace;
          result.workspace.replace(valueDes);
          break;
        case r'meal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealStatus),
          ) as MealStatus;
          result.meal.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MealWalletPay deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealWalletPayBuilder();
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
