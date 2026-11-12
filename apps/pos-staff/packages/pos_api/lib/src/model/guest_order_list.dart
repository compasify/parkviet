//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/guest_order.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_order_list.g.dart';

/// GuestOrderList
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class GuestOrderList
    implements Built<GuestOrderList, GuestOrderListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GuestOrder> get data;

  @BuiltValueField(wireName: r'meta')
  BuiltMap<String, JsonObject?> get meta;

  GuestOrderList._();

  factory GuestOrderList([void updates(GuestOrderListBuilder b)]) =
      _$GuestOrderList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestOrderListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestOrderList> get serializer =>
      _$GuestOrderListSerializer();
}

class _$GuestOrderListSerializer
    implements PrimitiveSerializer<GuestOrderList> {
  @override
  final Iterable<Type> types = const [GuestOrderList, _$GuestOrderList];

  @override
  final String wireName = r'GuestOrderList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestOrderList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(GuestOrder)]),
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
    GuestOrderList object, {
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
    required GuestOrderListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GuestOrder)]),
          ) as BuiltList<GuestOrder>;
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
  GuestOrderList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestOrderListBuilder();
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
