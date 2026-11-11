//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource.g.dart';

/// Resource
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [areaId]
/// * [kind]
/// * [name]
/// * [capacity]
/// * [shape]
/// * [x]
/// * [y]
/// * [w]
/// * [h]
/// * [rotation]
/// * [manualStatus]
/// * [resourceTypeCode]
/// * [status]
/// * [position]
/// * [minimumSpend] - A VIP table's minimum spend; the shortfall is charged as a fee.
@BuiltValue()
abstract class Resource implements Built<Resource, ResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'area_id')
  String get areaId;

  @BuiltValueField(wireName: r'kind')
  ResourceKindEnum get kind;
  // enum kindEnum {  table,  room,  billiard,  vip,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'capacity')
  int get capacity;

  @BuiltValueField(wireName: r'shape')
  ResourceShapeEnum get shape;
  // enum shapeEnum {  rect,  round,  };

  @BuiltValueField(wireName: r'x')
  int get x;

  @BuiltValueField(wireName: r'y')
  int get y;

  @BuiltValueField(wireName: r'w')
  int get w;

  @BuiltValueField(wireName: r'h')
  int get h;

  @BuiltValueField(wireName: r'rotation')
  int get rotation;

  @BuiltValueField(wireName: r'manual_status')
  ResourceManualStatusEnum get manualStatus;
  // enum manualStatusEnum {  available,  cleaning,  out_of_service,  };

  @BuiltValueField(wireName: r'resource_type_code')
  String? get resourceTypeCode;

  @BuiltValueField(wireName: r'status')
  ResourceStatusEnum get status;
  // enum statusEnum {  active,  archived,  };

  @BuiltValueField(wireName: r'position')
  int get position;

  /// A VIP table's minimum spend; the shortfall is charged as a fee.
  @BuiltValueField(wireName: r'minimum_spend')
  String? get minimumSpend;

  Resource._();

  factory Resource([void updates(ResourceBuilder b)]) = _$Resource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Resource> get serializer => _$ResourceSerializer();
}

class _$ResourceSerializer implements PrimitiveSerializer<Resource> {
  @override
  final Iterable<Type> types = const [Resource, _$Resource];

  @override
  final String wireName = r'Resource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Resource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'area_id';
    yield serializers.serialize(
      object.areaId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ResourceKindEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'capacity';
    yield serializers.serialize(
      object.capacity,
      specifiedType: const FullType(int),
    );
    yield r'shape';
    yield serializers.serialize(
      object.shape,
      specifiedType: const FullType(ResourceShapeEnum),
    );
    yield r'x';
    yield serializers.serialize(
      object.x,
      specifiedType: const FullType(int),
    );
    yield r'y';
    yield serializers.serialize(
      object.y,
      specifiedType: const FullType(int),
    );
    yield r'w';
    yield serializers.serialize(
      object.w,
      specifiedType: const FullType(int),
    );
    yield r'h';
    yield serializers.serialize(
      object.h,
      specifiedType: const FullType(int),
    );
    yield r'rotation';
    yield serializers.serialize(
      object.rotation,
      specifiedType: const FullType(int),
    );
    yield r'manual_status';
    yield serializers.serialize(
      object.manualStatus,
      specifiedType: const FullType(ResourceManualStatusEnum),
    );
    yield r'resource_type_code';
    yield object.resourceTypeCode == null
        ? null
        : serializers.serialize(
            object.resourceTypeCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ResourceStatusEnum),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    if (object.minimumSpend != null) {
      yield r'minimum_spend';
      yield serializers.serialize(
        object.minimumSpend,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Resource object, {
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
    required ResourceBuilder result,
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
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.areaId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceKindEnum),
          ) as ResourceKindEnum;
          result.kind = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'capacity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.capacity = valueDes;
          break;
        case r'shape':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceShapeEnum),
          ) as ResourceShapeEnum;
          result.shape = valueDes;
          break;
        case r'x':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.x = valueDes;
          break;
        case r'y':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.y = valueDes;
          break;
        case r'w':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.w = valueDes;
          break;
        case r'h':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.h = valueDes;
          break;
        case r'rotation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rotation = valueDes;
          break;
        case r'manual_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceManualStatusEnum),
          ) as ResourceManualStatusEnum;
          result.manualStatus = valueDes;
          break;
        case r'resource_type_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resourceTypeCode = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceStatusEnum),
          ) as ResourceStatusEnum;
          result.status = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'minimum_spend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.minimumSpend = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Resource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceBuilder();
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

class ResourceKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'table')
  static const ResourceKindEnum table = _$resourceKindEnum_table;
  @BuiltValueEnumConst(wireName: r'room')
  static const ResourceKindEnum room = _$resourceKindEnum_room;
  @BuiltValueEnumConst(wireName: r'billiard')
  static const ResourceKindEnum billiard = _$resourceKindEnum_billiard;
  @BuiltValueEnumConst(wireName: r'vip')
  static const ResourceKindEnum vip = _$resourceKindEnum_vip;

  static Serializer<ResourceKindEnum> get serializer =>
      _$resourceKindEnumSerializer;

  const ResourceKindEnum._(String name) : super(name);

  static BuiltSet<ResourceKindEnum> get values => _$resourceKindEnumValues;
  static ResourceKindEnum valueOf(String name) =>
      _$resourceKindEnumValueOf(name);
}

class ResourceShapeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'rect')
  static const ResourceShapeEnum rect = _$resourceShapeEnum_rect;
  @BuiltValueEnumConst(wireName: r'round')
  static const ResourceShapeEnum round = _$resourceShapeEnum_round;

  static Serializer<ResourceShapeEnum> get serializer =>
      _$resourceShapeEnumSerializer;

  const ResourceShapeEnum._(String name) : super(name);

  static BuiltSet<ResourceShapeEnum> get values => _$resourceShapeEnumValues;
  static ResourceShapeEnum valueOf(String name) =>
      _$resourceShapeEnumValueOf(name);
}

class ResourceManualStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'available')
  static const ResourceManualStatusEnum available =
      _$resourceManualStatusEnum_available;
  @BuiltValueEnumConst(wireName: r'cleaning')
  static const ResourceManualStatusEnum cleaning =
      _$resourceManualStatusEnum_cleaning;
  @BuiltValueEnumConst(wireName: r'out_of_service')
  static const ResourceManualStatusEnum outOfService =
      _$resourceManualStatusEnum_outOfService;

  static Serializer<ResourceManualStatusEnum> get serializer =>
      _$resourceManualStatusEnumSerializer;

  const ResourceManualStatusEnum._(String name) : super(name);

  static BuiltSet<ResourceManualStatusEnum> get values =>
      _$resourceManualStatusEnumValues;
  static ResourceManualStatusEnum valueOf(String name) =>
      _$resourceManualStatusEnumValueOf(name);
}

class ResourceStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const ResourceStatusEnum active = _$resourceStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'archived')
  static const ResourceStatusEnum archived = _$resourceStatusEnum_archived;

  static Serializer<ResourceStatusEnum> get serializer =>
      _$resourceStatusEnumSerializer;

  const ResourceStatusEnum._(String name) : super(name);

  static BuiltSet<ResourceStatusEnum> get values => _$resourceStatusEnumValues;
  static ResourceStatusEnum valueOf(String name) =>
      _$resourceStatusEnumValueOf(name);
}
