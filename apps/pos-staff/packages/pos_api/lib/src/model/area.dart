//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'area.g.dart';

/// Area
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [name]
/// * [position]
/// * [status]
/// * [floorWidth] - Grid columns of the floor plan.
/// * [floorHeight] - Grid rows of the floor plan.
@BuiltValue()
abstract class Area implements Built<Area, AreaBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'status')
  AreaStatusEnum get status;
  // enum statusEnum {  active,  archived,  };

  /// Grid columns of the floor plan.
  @BuiltValueField(wireName: r'floor_width')
  int get floorWidth;

  /// Grid rows of the floor plan.
  @BuiltValueField(wireName: r'floor_height')
  int get floorHeight;

  Area._();

  factory Area([void updates(AreaBuilder b)]) = _$Area;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AreaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Area> get serializer => _$AreaSerializer();
}

class _$AreaSerializer implements PrimitiveSerializer<Area> {
  @override
  final Iterable<Type> types = const [Area, _$Area];

  @override
  final String wireName = r'Area';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Area object, {
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
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AreaStatusEnum),
    );
    yield r'floor_width';
    yield serializers.serialize(
      object.floorWidth,
      specifiedType: const FullType(int),
    );
    yield r'floor_height';
    yield serializers.serialize(
      object.floorHeight,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Area object, {
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
    required AreaBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AreaStatusEnum),
          ) as AreaStatusEnum;
          result.status = valueDes;
          break;
        case r'floor_width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.floorWidth = valueDes;
          break;
        case r'floor_height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.floorHeight = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Area deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AreaBuilder();
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

class AreaStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const AreaStatusEnum active = _$areaStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'archived')
  static const AreaStatusEnum archived = _$areaStatusEnum_archived;

  static Serializer<AreaStatusEnum> get serializer =>
      _$areaStatusEnumSerializer;

  const AreaStatusEnum._(String name) : super(name);

  static BuiltSet<AreaStatusEnum> get values => _$areaStatusEnumValues;
  static AreaStatusEnum valueOf(String name) => _$areaStatusEnumValueOf(name);
}
