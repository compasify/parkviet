//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/modifier_pick.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'append_item.g.dart';

/// AppendItem
///
/// Properties:
/// * [variantId]
/// * [quantity]
/// * [modifiers]
/// * [note]
/// * [course] - The course of a table dish.
/// * [seat]
/// * [hold] - Keep the dish off the kitchen until its course is fired; needs `course`.
/// * [buffetTierId] - Adds the tier's ticket, `quantity` guests, as a `cover` line; `variant_id` is then ignored and may be empty.
/// * [buffetCoverLineId] - A free dish of that cover's buffet tier; refused (`buffet_item_not_in_tier`) for any other dish.
@BuiltValue()
abstract class AppendItem implements Built<AppendItem, AppendItemBuilder> {
  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<ModifierPick>? get modifiers;

  @BuiltValueField(wireName: r'note')
  String? get note;

  /// The course of a table dish.
  @BuiltValueField(wireName: r'course')
  int? get course;

  @BuiltValueField(wireName: r'seat')
  int? get seat;

  /// Keep the dish off the kitchen until its course is fired; needs `course`.
  @BuiltValueField(wireName: r'hold')
  bool? get hold;

  /// Adds the tier's ticket, `quantity` guests, as a `cover` line; `variant_id` is then ignored and may be empty.
  @BuiltValueField(wireName: r'buffet_tier_id')
  String? get buffetTierId;

  /// A free dish of that cover's buffet tier; refused (`buffet_item_not_in_tier`) for any other dish.
  @BuiltValueField(wireName: r'buffet_cover_line_id')
  String? get buffetCoverLineId;

  AppendItem._();

  factory AppendItem([void updates(AppendItemBuilder b)]) = _$AppendItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppendItemBuilder b) => b..quantity = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppendItem> get serializer => _$AppendItemSerializer();
}

class _$AppendItemSerializer implements PrimitiveSerializer<AppendItem> {
  @override
  final Iterable<Type> types = const [AppendItem, _$AppendItem];

  @override
  final String wireName = r'AppendItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppendItem object, {
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
    if (object.modifiers != null) {
      yield r'modifiers';
      yield serializers.serialize(
        object.modifiers,
        specifiedType: const FullType(BuiltList, [FullType(ModifierPick)]),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.course != null) {
      yield r'course';
      yield serializers.serialize(
        object.course,
        specifiedType: const FullType(int),
      );
    }
    if (object.seat != null) {
      yield r'seat';
      yield serializers.serialize(
        object.seat,
        specifiedType: const FullType(int),
      );
    }
    if (object.hold != null) {
      yield r'hold';
      yield serializers.serialize(
        object.hold,
        specifiedType: const FullType(bool),
      );
    }
    if (object.buffetTierId != null) {
      yield r'buffet_tier_id';
      yield serializers.serialize(
        object.buffetTierId,
        specifiedType: const FullType(String),
      );
    }
    if (object.buffetCoverLineId != null) {
      yield r'buffet_cover_line_id';
      yield serializers.serialize(
        object.buffetCoverLineId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AppendItem object, {
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
    required AppendItemBuilder result,
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
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(ModifierPick)]),
          ) as BuiltList<ModifierPick>?;
          if (valueDes == null) continue;
          result.modifiers.replace(valueDes);
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'course':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.course = valueDes;
          break;
        case r'seat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.seat = valueDes;
          break;
        case r'hold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.hold = valueDes;
          break;
        case r'buffet_tier_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.buffetTierId = valueDes;
          break;
        case r'buffet_cover_line_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.buffetCoverLineId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppendItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppendItemBuilder();
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
