//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_input.g.dart';

/// ResourceInput
///
/// Properties:
/// * [branchId] - Required when creating.
/// * [areaId] - Required when creating.
/// * [name]
/// * [kind]
/// * [capacity]
/// * [shape]
/// * [x]
/// * [y]
/// * [w]
/// * [h]
/// * [rotation]
/// * [position]
/// * [resourceTypeCode]
@BuiltValue()
abstract class ResourceInput
    implements Built<ResourceInput, ResourceInputBuilder> {
  /// Required when creating.
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  /// Required when creating.
  @BuiltValueField(wireName: r'area_id')
  String? get areaId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'kind')
  ResourceInputKindEnum? get kind;
  // enum kindEnum {  table,  room,  billiard,  vip,  };

  @BuiltValueField(wireName: r'capacity')
  int? get capacity;

  @BuiltValueField(wireName: r'shape')
  ResourceInputShapeEnum? get shape;
  // enum shapeEnum {  rect,  round,  };

  @BuiltValueField(wireName: r'x')
  int? get x;

  @BuiltValueField(wireName: r'y')
  int? get y;

  @BuiltValueField(wireName: r'w')
  int? get w;

  @BuiltValueField(wireName: r'h')
  int? get h;

  @BuiltValueField(wireName: r'rotation')
  int? get rotation;

  @BuiltValueField(wireName: r'position')
  int? get position;

  @BuiltValueField(wireName: r'resource_type_code')
  String? get resourceTypeCode;

  ResourceInput._();

  factory ResourceInput([void updates(ResourceInputBuilder b)]) =
      _$ResourceInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceInput> get serializer =>
      _$ResourceInputSerializer();
}

class _$ResourceInputSerializer implements PrimitiveSerializer<ResourceInput> {
  @override
  final Iterable<Type> types = const [ResourceInput, _$ResourceInput];

  @override
  final String wireName = r'ResourceInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.areaId != null) {
      yield r'area_id';
      yield serializers.serialize(
        object.areaId,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(ResourceInputKindEnum),
      );
    }
    if (object.capacity != null) {
      yield r'capacity';
      yield serializers.serialize(
        object.capacity,
        specifiedType: const FullType(int),
      );
    }
    if (object.shape != null) {
      yield r'shape';
      yield serializers.serialize(
        object.shape,
        specifiedType: const FullType(ResourceInputShapeEnum),
      );
    }
    if (object.x != null) {
      yield r'x';
      yield serializers.serialize(
        object.x,
        specifiedType: const FullType(int),
      );
    }
    if (object.y != null) {
      yield r'y';
      yield serializers.serialize(
        object.y,
        specifiedType: const FullType(int),
      );
    }
    if (object.w != null) {
      yield r'w';
      yield serializers.serialize(
        object.w,
        specifiedType: const FullType(int),
      );
    }
    if (object.h != null) {
      yield r'h';
      yield serializers.serialize(
        object.h,
        specifiedType: const FullType(int),
      );
    }
    if (object.rotation != null) {
      yield r'rotation';
      yield serializers.serialize(
        object.rotation,
        specifiedType: const FullType(int),
      );
    }
    if (object.position != null) {
      yield r'position';
      yield serializers.serialize(
        object.position,
        specifiedType: const FullType(int),
      );
    }
    if (object.resourceTypeCode != null) {
      yield r'resource_type_code';
      yield serializers.serialize(
        object.resourceTypeCode,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceInput object, {
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
    required ResourceInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.areaId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ResourceInputKindEnum),
          ) as ResourceInputKindEnum?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'capacity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.capacity = valueDes;
          break;
        case r'shape':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ResourceInputShapeEnum),
          ) as ResourceInputShapeEnum?;
          if (valueDes == null) continue;
          result.shape = valueDes;
          break;
        case r'x':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.x = valueDes;
          break;
        case r'y':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.y = valueDes;
          break;
        case r'w':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.w = valueDes;
          break;
        case r'h':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.h = valueDes;
          break;
        case r'rotation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.rotation = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.position = valueDes;
          break;
        case r'resource_type_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resourceTypeCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResourceInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceInputBuilder();
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

class ResourceInputKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'table')
  static const ResourceInputKindEnum table = _$resourceInputKindEnum_table;
  @BuiltValueEnumConst(wireName: r'room')
  static const ResourceInputKindEnum room = _$resourceInputKindEnum_room;
  @BuiltValueEnumConst(wireName: r'billiard')
  static const ResourceInputKindEnum billiard =
      _$resourceInputKindEnum_billiard;
  @BuiltValueEnumConst(wireName: r'vip')
  static const ResourceInputKindEnum vip = _$resourceInputKindEnum_vip;

  static Serializer<ResourceInputKindEnum> get serializer =>
      _$resourceInputKindEnumSerializer;

  const ResourceInputKindEnum._(String name) : super(name);

  static BuiltSet<ResourceInputKindEnum> get values =>
      _$resourceInputKindEnumValues;
  static ResourceInputKindEnum valueOf(String name) =>
      _$resourceInputKindEnumValueOf(name);
}

class ResourceInputShapeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'rect')
  static const ResourceInputShapeEnum rect = _$resourceInputShapeEnum_rect;
  @BuiltValueEnumConst(wireName: r'round')
  static const ResourceInputShapeEnum round = _$resourceInputShapeEnum_round;

  static Serializer<ResourceInputShapeEnum> get serializer =>
      _$resourceInputShapeEnumSerializer;

  const ResourceInputShapeEnum._(String name) : super(name);

  static BuiltSet<ResourceInputShapeEnum> get values =>
      _$resourceInputShapeEnumValues;
  static ResourceInputShapeEnum valueOf(String name) =>
      _$resourceInputShapeEnumValueOf(name);
}
