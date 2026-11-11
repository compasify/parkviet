//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/pos_recipe_save_request_ingredients_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_recipe_save_request.g.dart';

/// PosRecipeSaveRequest
///
/// Properties:
/// * [variantId]
/// * [modifierOptionId]
/// * [confirmStockWriteOff]
/// * [ingredients]
@BuiltValue()
abstract class PosRecipeSaveRequest
    implements Built<PosRecipeSaveRequest, PosRecipeSaveRequestBuilder> {
  @BuiltValueField(wireName: r'variant_id')
  String? get variantId;

  @BuiltValueField(wireName: r'modifier_option_id')
  String? get modifierOptionId;

  @BuiltValueField(wireName: r'confirm_stock_write_off')
  bool? get confirmStockWriteOff;

  @BuiltValueField(wireName: r'ingredients')
  BuiltList<PosRecipeSaveRequestIngredientsInner> get ingredients;

  PosRecipeSaveRequest._();

  factory PosRecipeSaveRequest([void updates(PosRecipeSaveRequestBuilder b)]) =
      _$PosRecipeSaveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosRecipeSaveRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosRecipeSaveRequest> get serializer =>
      _$PosRecipeSaveRequestSerializer();
}

class _$PosRecipeSaveRequestSerializer
    implements PrimitiveSerializer<PosRecipeSaveRequest> {
  @override
  final Iterable<Type> types = const [
    PosRecipeSaveRequest,
    _$PosRecipeSaveRequest
  ];

  @override
  final String wireName = r'PosRecipeSaveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosRecipeSaveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.variantId != null) {
      yield r'variant_id';
      yield serializers.serialize(
        object.variantId,
        specifiedType: const FullType(String),
      );
    }
    if (object.modifierOptionId != null) {
      yield r'modifier_option_id';
      yield serializers.serialize(
        object.modifierOptionId,
        specifiedType: const FullType(String),
      );
    }
    if (object.confirmStockWriteOff != null) {
      yield r'confirm_stock_write_off';
      yield serializers.serialize(
        object.confirmStockWriteOff,
        specifiedType: const FullType(bool),
      );
    }
    yield r'ingredients';
    yield serializers.serialize(
      object.ingredients,
      specifiedType: const FullType(
          BuiltList, [FullType(PosRecipeSaveRequestIngredientsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosRecipeSaveRequest object, {
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
    required PosRecipeSaveRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.variantId = valueDes;
          break;
        case r'modifier_option_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.modifierOptionId = valueDes;
          break;
        case r'confirm_stock_write_off':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.confirmStockWriteOff = valueDes;
          break;
        case r'ingredients':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(PosRecipeSaveRequestIngredientsInner)]),
          ) as BuiltList<PosRecipeSaveRequestIngredientsInner>;
          result.ingredients.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosRecipeSaveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosRecipeSaveRequestBuilder();
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
