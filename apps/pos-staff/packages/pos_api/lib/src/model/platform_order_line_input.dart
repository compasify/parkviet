//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/modifier_selection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_order_line_input.g.dart';

/// PlatformOrderLineInput
///
/// Properties:
/// * [variantId]
/// * [quantity]
/// * [platformPrice] - The platform's price for one unit, options included. Absent keeps the menu price.
/// * [note]
/// * [modifiers]
@BuiltValue()
abstract class PlatformOrderLineInput
    implements Built<PlatformOrderLineInput, PlatformOrderLineInputBuilder> {
  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  /// The platform's price for one unit, options included. Absent keeps the menu price.
  @BuiltValueField(wireName: r'platform_price')
  String? get platformPrice;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<ModifierSelection>? get modifiers;

  PlatformOrderLineInput._();

  factory PlatformOrderLineInput(
          [void updates(PlatformOrderLineInputBuilder b)]) =
      _$PlatformOrderLineInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformOrderLineInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformOrderLineInput> get serializer =>
      _$PlatformOrderLineInputSerializer();
}

class _$PlatformOrderLineInputSerializer
    implements PrimitiveSerializer<PlatformOrderLineInput> {
  @override
  final Iterable<Type> types = const [
    PlatformOrderLineInput,
    _$PlatformOrderLineInput
  ];

  @override
  final String wireName = r'PlatformOrderLineInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformOrderLineInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    if (object.platformPrice != null) {
      yield r'platform_price';
      yield serializers.serialize(
        object.platformPrice,
        specifiedType: const FullType.nullable(String),
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
    PlatformOrderLineInput object, {
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
    required PlatformOrderLineInputBuilder result,
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
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'platform_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.platformPrice = valueDes;
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
  PlatformOrderLineInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformOrderLineInputBuilder();
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
