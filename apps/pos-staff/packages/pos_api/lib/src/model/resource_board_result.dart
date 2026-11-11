//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/resource_board.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_board_result.g.dart';

/// ResourceBoardResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class ResourceBoardResult
    implements Built<ResourceBoardResult, ResourceBoardResultBuilder> {
  @BuiltValueField(wireName: r'data')
  ResourceBoard get data;

  ResourceBoardResult._();

  factory ResourceBoardResult([void updates(ResourceBoardResultBuilder b)]) =
      _$ResourceBoardResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceBoardResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceBoardResult> get serializer =>
      _$ResourceBoardResultSerializer();
}

class _$ResourceBoardResultSerializer
    implements PrimitiveSerializer<ResourceBoardResult> {
  @override
  final Iterable<Type> types = const [
    ResourceBoardResult,
    _$ResourceBoardResult
  ];

  @override
  final String wireName = r'ResourceBoardResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceBoardResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ResourceBoard),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceBoardResult object, {
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
    required ResourceBoardResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ResourceBoard),
          ) as ResourceBoard;
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
  ResourceBoardResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceBoardResultBuilder();
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
