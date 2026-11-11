//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/platform_order.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_order_list.g.dart';

/// PlatformOrderList
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class PlatformOrderList
    implements Built<PlatformOrderList, PlatformOrderListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PlatformOrder> get data;

  @BuiltValueField(wireName: r'meta')
  BuiltMap<String, JsonObject?> get meta;

  PlatformOrderList._();

  factory PlatformOrderList([void updates(PlatformOrderListBuilder b)]) =
      _$PlatformOrderList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformOrderListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformOrderList> get serializer =>
      _$PlatformOrderListSerializer();
}

class _$PlatformOrderListSerializer
    implements PrimitiveSerializer<PlatformOrderList> {
  @override
  final Iterable<Type> types = const [PlatformOrderList, _$PlatformOrderList];

  @override
  final String wireName = r'PlatformOrderList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformOrderList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PlatformOrder)]),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformOrderList object, {
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
    required PlatformOrderListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PlatformOrder)]),
          ) as BuiltList<PlatformOrder>;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformOrderList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformOrderListBuilder();
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
