//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/modifier_selection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_order_item_input.g.dart';

/// KioskOrderItemInput
///
/// Properties:
/// * [variantId]
/// * [quantity]
/// * [note]
/// * [modifiers]
@BuiltValue()
abstract class KioskOrderItemInput
    implements Built<KioskOrderItemInput, KioskOrderItemInputBuilder> {
  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<ModifierSelection>? get modifiers;

  KioskOrderItemInput._();

  factory KioskOrderItemInput([void updates(KioskOrderItemInputBuilder b)]) =
      _$KioskOrderItemInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskOrderItemInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskOrderItemInput> get serializer =>
      _$KioskOrderItemInputSerializer();
}

class _$KioskOrderItemInputSerializer
    implements PrimitiveSerializer<KioskOrderItemInput> {
  @override
  final Iterable<Type> types = const [
    KioskOrderItemInput,
    _$KioskOrderItemInput
  ];

  @override
  final String wireName = r'KioskOrderItemInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskOrderItemInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType(int),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.modifiers != null) {
      yield r'modifiers';
      yield serializers.serialize(
        object.modifiers,
        specifiedType: const FullType(BuiltList, [FullType(ModifierSelection)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskOrderItemInput object, {
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
    required KioskOrderItemInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variantId = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.quantity = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltList, [FullType(ModifierSelection)]),
          ) as BuiltList<ModifierSelection>?;
          if (valueDes == null) continue;
          result.modifiers.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskOrderItemInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskOrderItemInputBuilder();
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
