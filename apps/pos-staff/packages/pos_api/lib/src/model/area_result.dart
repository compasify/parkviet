//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/area.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'area_result.g.dart';

/// AreaResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class AreaResult implements Built<AreaResult, AreaResultBuilder> {
  @BuiltValueField(wireName: r'data')
  Area get data;

  AreaResult._();

  factory AreaResult([void updates(AreaResultBuilder b)]) = _$AreaResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AreaResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AreaResult> get serializer => _$AreaResultSerializer();
}

class _$AreaResultSerializer implements PrimitiveSerializer<AreaResult> {
  @override
  final Iterable<Type> types = const [AreaResult, _$AreaResult];

  @override
  final String wireName = r'AreaResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AreaResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Area),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AreaResult object, {
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
    required AreaResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Area),
          ) as Area;
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
  AreaResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AreaResultBuilder();
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
