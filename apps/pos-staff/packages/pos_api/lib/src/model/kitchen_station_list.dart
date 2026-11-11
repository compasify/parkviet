//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_station.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_station_list.g.dart';

/// KitchenStationList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class KitchenStationList
    implements Built<KitchenStationList, KitchenStationListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<KitchenStation> get data;

  KitchenStationList._();

  factory KitchenStationList([void updates(KitchenStationListBuilder b)]) =
      _$KitchenStationList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenStationListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenStationList> get serializer =>
      _$KitchenStationListSerializer();
}

class _$KitchenStationListSerializer
    implements PrimitiveSerializer<KitchenStationList> {
  @override
  final Iterable<Type> types = const [KitchenStationList, _$KitchenStationList];

  @override
  final String wireName = r'KitchenStationList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenStationList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(KitchenStation)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenStationList object, {
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
    required KitchenStationListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenStation)]),
          ) as BuiltList<KitchenStation>;
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
  KitchenStationList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenStationListBuilder();
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
