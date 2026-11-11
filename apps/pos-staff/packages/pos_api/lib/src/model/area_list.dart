//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/area.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'area_list.g.dart';

/// AreaList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class AreaList implements Built<AreaList, AreaListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Area> get data;

  AreaList._();

  factory AreaList([void updates(AreaListBuilder b)]) = _$AreaList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AreaListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AreaList> get serializer => _$AreaListSerializer();
}

class _$AreaListSerializer implements PrimitiveSerializer<AreaList> {
  @override
  final Iterable<Type> types = const [AreaList, _$AreaList];

  @override
  final String wireName = r'AreaList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AreaList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Area)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AreaList object, {
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
    required AreaListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Area)]),
          ) as BuiltList<Area>;
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
  AreaList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AreaListBuilder();
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
