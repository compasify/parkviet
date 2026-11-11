//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_ref.g.dart';

/// The table an order sits at.
///
/// Properties:
/// * [id]
/// * [name]
/// * [kind]
/// * [areaId]
@BuiltValue()
abstract class ResourceRef implements Built<ResourceRef, ResourceRefBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  ResourceRefKindEnum get kind;
  // enum kindEnum {  table,  room,  billiard,  vip,  };

  @BuiltValueField(wireName: r'area_id')
  String? get areaId;

  ResourceRef._();

  factory ResourceRef([void updates(ResourceRefBuilder b)]) = _$ResourceRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceRef> get serializer => _$ResourceRefSerializer();
}

class _$ResourceRefSerializer implements PrimitiveSerializer<ResourceRef> {
  @override
  final Iterable<Type> types = const [ResourceRef, _$ResourceRef];

  @override
  final String wireName = r'ResourceRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ResourceRefKindEnum),
    );
    yield r'area_id';
    yield object.areaId == null
        ? null
        : serializers.serialize(
            object.areaId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceRef object, {
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
    required ResourceRefBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceRefKindEnum),
          ) as ResourceRefKindEnum;
          result.kind = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.areaId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResourceRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceRefBuilder();
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

class ResourceRefKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'table')
  static const ResourceRefKindEnum table = _$resourceRefKindEnum_table;
  @BuiltValueEnumConst(wireName: r'room')
  static const ResourceRefKindEnum room = _$resourceRefKindEnum_room;
  @BuiltValueEnumConst(wireName: r'billiard')
  static const ResourceRefKindEnum billiard = _$resourceRefKindEnum_billiard;
  @BuiltValueEnumConst(wireName: r'vip')
  static const ResourceRefKindEnum vip = _$resourceRefKindEnum_vip;

  static Serializer<ResourceRefKindEnum> get serializer =>
      _$resourceRefKindEnumSerializer;

  const ResourceRefKindEnum._(String name) : super(name);

  static BuiltSet<ResourceRefKindEnum> get values =>
      _$resourceRefKindEnumValues;
  static ResourceRefKindEnum valueOf(String name) =>
      _$resourceRefKindEnumValueOf(name);
}
