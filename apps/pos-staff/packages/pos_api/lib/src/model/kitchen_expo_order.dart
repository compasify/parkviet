//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_expo_item.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_expo_order.g.dart';

/// KitchenExpoOrder
///
/// Properties:
/// * [workspaceId]
/// * [areaId] - The area of the order's table, for a pass that runs one area.
/// * [header] - The ticket header (table, call number…), as on KitchenTicket.
/// * [serviceMode]
/// * [readySince]
/// * [items]
@BuiltValue()
abstract class KitchenExpoOrder
    implements Built<KitchenExpoOrder, KitchenExpoOrderBuilder> {
  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  /// The area of the order's table, for a pass that runs one area.
  @BuiltValueField(wireName: r'area_id')
  String? get areaId;

  /// The ticket header (table, call number…), as on KitchenTicket.
  @BuiltValueField(wireName: r'header')
  BuiltMap<String, JsonObject?> get header;

  @BuiltValueField(wireName: r'service_mode')
  String get serviceMode;

  @BuiltValueField(wireName: r'ready_since')
  DateTime? get readySince;

  @BuiltValueField(wireName: r'items')
  BuiltList<KitchenExpoItem> get items;

  KitchenExpoOrder._();

  factory KitchenExpoOrder([void updates(KitchenExpoOrderBuilder b)]) =
      _$KitchenExpoOrder;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenExpoOrderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenExpoOrder> get serializer =>
      _$KitchenExpoOrderSerializer();
}

class _$KitchenExpoOrderSerializer
    implements PrimitiveSerializer<KitchenExpoOrder> {
  @override
  final Iterable<Type> types = const [KitchenExpoOrder, _$KitchenExpoOrder];

  @override
  final String wireName = r'KitchenExpoOrder';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenExpoOrder object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'area_id';
    yield object.areaId == null
        ? null
        : serializers.serialize(
            object.areaId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'header';
    yield serializers.serialize(
      object.header,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'service_mode';
    yield serializers.serialize(
      object.serviceMode,
      specifiedType: const FullType(String),
    );
    yield r'ready_since';
    yield object.readySince == null
        ? null
        : serializers.serialize(
            object.readySince,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(KitchenExpoItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenExpoOrder object, {
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
    required KitchenExpoOrderBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.areaId = valueDes;
          break;
        case r'header':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.header.replace(valueDes);
          break;
        case r'service_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serviceMode = valueDes;
          break;
        case r'ready_since':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readySince = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenExpoItem)]),
          ) as BuiltList<KitchenExpoItem>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenExpoOrder deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenExpoOrderBuilder();
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
