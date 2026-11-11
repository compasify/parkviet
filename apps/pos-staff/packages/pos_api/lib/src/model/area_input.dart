//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'area_input.g.dart';

/// AreaInput
///
/// Properties:
/// * [branchId] - Required when creating.
/// * [name]
/// * [position]
/// * [floorWidth]
/// * [floorHeight]
@BuiltValue()
abstract class AreaInput implements Built<AreaInput, AreaInputBuilder> {
  /// Required when creating.
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'position')
  int? get position;

  @BuiltValueField(wireName: r'floor_width')
  int? get floorWidth;

  @BuiltValueField(wireName: r'floor_height')
  int? get floorHeight;

  AreaInput._();

  factory AreaInput([void updates(AreaInputBuilder b)]) = _$AreaInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AreaInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AreaInput> get serializer => _$AreaInputSerializer();
}

class _$AreaInputSerializer implements PrimitiveSerializer<AreaInput> {
  @override
  final Iterable<Type> types = const [AreaInput, _$AreaInput];

  @override
  final String wireName = r'AreaInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AreaInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
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
    if (object.position != null) {
      yield r'position';
      yield serializers.serialize(
        object.position,
        specifiedType: const FullType(int),
      );
    }
    if (object.floorWidth != null) {
      yield r'floor_width';
      yield serializers.serialize(
        object.floorWidth,
        specifiedType: const FullType(int),
      );
    }
    if (object.floorHeight != null) {
      yield r'floor_height';
      yield serializers.serialize(
        object.floorHeight,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AreaInput object, {
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
    required AreaInputBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.position = valueDes;
          break;
        case r'floor_width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.floorWidth = valueDes;
          break;
        case r'floor_height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
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
  AreaInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AreaInputBuilder();
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
