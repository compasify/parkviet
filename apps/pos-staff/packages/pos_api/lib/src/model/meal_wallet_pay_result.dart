//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/meal_wallet_pay.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_wallet_pay_result.g.dart';

/// MealWalletPayResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class MealWalletPayResult
    implements Built<MealWalletPayResult, MealWalletPayResultBuilder> {
  @BuiltValueField(wireName: r'data')
  MealWalletPay get data;

  MealWalletPayResult._();

  factory MealWalletPayResult([void updates(MealWalletPayResultBuilder b)]) =
      _$MealWalletPayResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealWalletPayResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealWalletPayResult> get serializer =>
      _$MealWalletPayResultSerializer();
}

class _$MealWalletPayResultSerializer
    implements PrimitiveSerializer<MealWalletPayResult> {
  @override
  final Iterable<Type> types = const [
    MealWalletPayResult,
    _$MealWalletPayResult
  ];

  @override
  final String wireName = r'MealWalletPayResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealWalletPayResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MealWalletPay),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MealWalletPayResult object, {
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
    required MealWalletPayResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MealWalletPay),
          ) as MealWalletPay;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MealWalletPayResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealWalletPayResultBuilder();
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
