//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'available_resource.g.dart';

/// AvailableResource
///
/// Properties:
/// * [id]
/// * [name]
/// * [kind]
/// * [areaId]
/// * [capacity] - 0 when unknown.
@BuiltValue()
abstract class AvailableResource
    implements Built<AvailableResource, AvailableResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  AvailableResourceKindEnum get kind;
  // enum kindEnum {  table,  room,  billiard,  vip,  };

  @BuiltValueField(wireName: r'area_id')
  String? get areaId;

  /// 0 when unknown.
  @BuiltValueField(wireName: r'capacity')
  int get capacity;

  AvailableResource._();

  factory AvailableResource([void updates(AvailableResourceBuilder b)]) =
      _$AvailableResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AvailableResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AvailableResource> get serializer =>
      _$AvailableResourceSerializer();
}

class _$AvailableResourceSerializer
    implements PrimitiveSerializer<AvailableResource> {
  @override
  final Iterable<Type> types = const [AvailableResource, _$AvailableResource];

  @override
  final String wireName = r'AvailableResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AvailableResource object, {
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
      specifiedType: const FullType(AvailableResourceKindEnum),
    );
    yield r'area_id';
    yield object.areaId == null
        ? null
        : serializers.serialize(
            object.areaId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'capacity';
    yield serializers.serialize(
      object.capacity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AvailableResource object, {
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
    required AvailableResourceBuilder result,
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
            specifiedType: const FullType(AvailableResourceKindEnum),
          ) as AvailableResourceKindEnum;
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
        case r'capacity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.capacity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AvailableResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AvailableResourceBuilder();
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

class AvailableResourceKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'table')
  static const AvailableResourceKindEnum table =
      _$availableResourceKindEnum_table;
  @BuiltValueEnumConst(wireName: r'room')
  static const AvailableResourceKindEnum room =
      _$availableResourceKindEnum_room;
  @BuiltValueEnumConst(wireName: r'billiard')
  static const AvailableResourceKindEnum billiard =
      _$availableResourceKindEnum_billiard;
  @BuiltValueEnumConst(wireName: r'vip')
  static const AvailableResourceKindEnum vip = _$availableResourceKindEnum_vip;

  static Serializer<AvailableResourceKindEnum> get serializer =>
      _$availableResourceKindEnumSerializer;

  const AvailableResourceKindEnum._(String name) : super(name);

  static BuiltSet<AvailableResourceKindEnum> get values =>
      _$availableResourceKindEnumValues;
  static AvailableResourceKindEnum valueOf(String name) =>
      _$availableResourceKindEnumValueOf(name);
}
