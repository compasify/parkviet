//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/resource_board_tile.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/resource_board_area.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_board.g.dart';

/// ResourceBoard
///
/// Properties:
/// * [branchId]
/// * [serverNow]
/// * [areas]
/// * [resources]
@BuiltValue()
abstract class ResourceBoard
    implements Built<ResourceBoard, ResourceBoardBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'server_now')
  DateTime get serverNow;

  @BuiltValueField(wireName: r'areas')
  BuiltList<ResourceBoardArea> get areas;

  @BuiltValueField(wireName: r'resources')
  BuiltList<ResourceBoardTile> get resources;

  ResourceBoard._();

  factory ResourceBoard([void updates(ResourceBoardBuilder b)]) =
      _$ResourceBoard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceBoardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceBoard> get serializer =>
      _$ResourceBoardSerializer();
}

class _$ResourceBoardSerializer implements PrimitiveSerializer<ResourceBoard> {
  @override
  final Iterable<Type> types = const [ResourceBoard, _$ResourceBoard];

  @override
  final String wireName = r'ResourceBoard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceBoard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'server_now';
    yield serializers.serialize(
      object.serverNow,
      specifiedType: const FullType(DateTime),
    );
    yield r'areas';
    yield serializers.serialize(
      object.areas,
      specifiedType: const FullType(BuiltList, [FullType(ResourceBoardArea)]),
    );
    yield r'resources';
    yield serializers.serialize(
      object.resources,
      specifiedType: const FullType(BuiltList, [FullType(ResourceBoardTile)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceBoard object, {
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
    required ResourceBoardBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'server_now':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.serverNow = valueDes;
          break;
        case r'areas':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ResourceBoardArea)]),
          ) as BuiltList<ResourceBoardArea>;
          result.areas.replace(valueDes);
          break;
        case r'resources':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ResourceBoardTile)]),
          ) as BuiltList<ResourceBoardTile>;
          result.resources.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResourceBoard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceBoardBuilder();
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
