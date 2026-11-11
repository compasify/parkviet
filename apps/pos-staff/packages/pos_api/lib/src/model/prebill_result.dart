//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/prebill_outcome.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'prebill_result.g.dart';

/// PrebillResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PrebillResult
    implements Built<PrebillResult, PrebillResultBuilder> {
  @BuiltValueField(wireName: r'data')
  PrebillOutcome get data;

  PrebillResult._();

  factory PrebillResult([void updates(PrebillResultBuilder b)]) =
      _$PrebillResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrebillResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrebillResult> get serializer =>
      _$PrebillResultSerializer();
}

class _$PrebillResultSerializer implements PrimitiveSerializer<PrebillResult> {
  @override
  final Iterable<Type> types = const [PrebillResult, _$PrebillResult];

  @override
  final String wireName = r'PrebillResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrebillResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PrebillOutcome),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrebillResult object, {
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
    required PrebillResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrebillOutcome),
          ) as PrebillOutcome;
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
  PrebillResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrebillResultBuilder();
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
