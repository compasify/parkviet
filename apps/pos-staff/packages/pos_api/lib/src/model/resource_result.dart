//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_result.g.dart';

/// ResourceResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class ResourceResult
    implements Built<ResourceResult, ResourceResultBuilder> {
  @BuiltValueField(wireName: r'data')
  Resource get data;

  ResourceResult._();

  factory ResourceResult([void updates(ResourceResultBuilder b)]) =
      _$ResourceResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceResult> get serializer =>
      _$ResourceResultSerializer();
}

class _$ResourceResultSerializer
    implements PrimitiveSerializer<ResourceResult> {
  @override
  final Iterable<Type> types = const [ResourceResult, _$ResourceResult];

  @override
  final String wireName = r'ResourceResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Resource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceResult object, {
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
    required ResourceResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Resource),
          ) as Resource;
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
  ResourceResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceResultBuilder();
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
