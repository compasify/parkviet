//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_history_item.g.dart';

/// KitchenHistoryItem
///
/// Properties:
/// * [name]
/// * [quantity] - Positive for a send, negative for a void.
/// * [stationName]
/// * [status]
/// * [modifiers]
/// * [note]
@BuiltValue()
abstract class KitchenHistoryItem
    implements Built<KitchenHistoryItem, KitchenHistoryItemBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Positive for a send, negative for a void.
  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'station_name')
  String? get stationName;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<BuiltMap<String, JsonObject?>> get modifiers;

  @BuiltValueField(wireName: r'note')
  String? get note;

  KitchenHistoryItem._();

  factory KitchenHistoryItem([void updates(KitchenHistoryItemBuilder b)]) =
      _$KitchenHistoryItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenHistoryItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenHistoryItem> get serializer =>
      _$KitchenHistoryItemSerializer();
}

class _$KitchenHistoryItemSerializer
    implements PrimitiveSerializer<KitchenHistoryItem> {
  @override
  final Iterable<Type> types = const [KitchenHistoryItem, _$KitchenHistoryItem];

  @override
  final String wireName = r'KitchenHistoryItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenHistoryItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'station_name';
    yield object.stationName == null
        ? null
        : serializers.serialize(
            object.stationName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'modifiers';
    yield serializers.serialize(
      object.modifiers,
      specifiedType: const FullType(BuiltList, [
        FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenHistoryItem object, {
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
    required KitchenHistoryItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quantity = valueDes;
          break;
        case r'station_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.stationName = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>>;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenHistoryItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenHistoryItemBuilder();
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
