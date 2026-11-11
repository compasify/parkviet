//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_board_area.g.dart';

/// ResourceBoardArea
///
/// Properties:
/// * [id]
/// * [name]
/// * [position]
/// * [floorWidth]
/// * [floorHeight]
@BuiltValue()
abstract class ResourceBoardArea
    implements Built<ResourceBoardArea, ResourceBoardAreaBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'floor_width')
  int get floorWidth;

  @BuiltValueField(wireName: r'floor_height')
  int get floorHeight;

  ResourceBoardArea._();

  factory ResourceBoardArea([void updates(ResourceBoardAreaBuilder b)]) =
      _$ResourceBoardArea;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceBoardAreaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceBoardArea> get serializer =>
      _$ResourceBoardAreaSerializer();
}

class _$ResourceBoardAreaSerializer
    implements PrimitiveSerializer<ResourceBoardArea> {
  @override
  final Iterable<Type> types = const [ResourceBoardArea, _$ResourceBoardArea];

  @override
  final String wireName = r'ResourceBoardArea';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceBoardArea object, {
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
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
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
    ResourceBoardArea object, {
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
    required ResourceBoardAreaBuilder result,
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
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
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
  ResourceBoardArea deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceBoardAreaBuilder();
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
