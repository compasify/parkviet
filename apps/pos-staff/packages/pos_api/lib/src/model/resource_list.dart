//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/resource.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_list.g.dart';

/// ResourceList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class ResourceList
    implements Built<ResourceList, ResourceListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Resource> get data;

  ResourceList._();

  factory ResourceList([void updates(ResourceListBuilder b)]) = _$ResourceList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceList> get serializer => _$ResourceListSerializer();
}

class _$ResourceListSerializer implements PrimitiveSerializer<ResourceList> {
  @override
  final Iterable<Type> types = const [ResourceList, _$ResourceList];

  @override
  final String wireName = r'ResourceList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Resource)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceList object, {
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
    required ResourceListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Resource)]),
          ) as BuiltList<Resource>;
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
  ResourceList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceListBuilder();
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
