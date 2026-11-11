//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/bottle_keep.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bottle_keep_result.g.dart';

/// BottleKeepResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class BottleKeepResult
    implements Built<BottleKeepResult, BottleKeepResultBuilder> {
  @BuiltValueField(wireName: r'data')
  BottleKeep get data;

  BottleKeepResult._();

  factory BottleKeepResult([void updates(BottleKeepResultBuilder b)]) =
      _$BottleKeepResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BottleKeepResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BottleKeepResult> get serializer =>
      _$BottleKeepResultSerializer();
}

class _$BottleKeepResultSerializer
    implements PrimitiveSerializer<BottleKeepResult> {
  @override
  final Iterable<Type> types = const [BottleKeepResult, _$BottleKeepResult];

  @override
  final String wireName = r'BottleKeepResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BottleKeepResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BottleKeep),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BottleKeepResult object, {
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
    required BottleKeepResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BottleKeep),
          ) as BottleKeep;
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
  BottleKeepResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BottleKeepResultBuilder();
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
