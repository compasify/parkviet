//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/ready_feed.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ready_feed_result.g.dart';

/// ReadyFeedResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class ReadyFeedResult
    implements Built<ReadyFeedResult, ReadyFeedResultBuilder> {
  @BuiltValueField(wireName: r'data')
  ReadyFeed get data;

  ReadyFeedResult._();

  factory ReadyFeedResult([void updates(ReadyFeedResultBuilder b)]) =
      _$ReadyFeedResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReadyFeedResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReadyFeedResult> get serializer =>
      _$ReadyFeedResultSerializer();
}

class _$ReadyFeedResultSerializer
    implements PrimitiveSerializer<ReadyFeedResult> {
  @override
  final Iterable<Type> types = const [ReadyFeedResult, _$ReadyFeedResult];

  @override
  final String wireName = r'ReadyFeedResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReadyFeedResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ReadyFeed),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReadyFeedResult object, {
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
    required ReadyFeedResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadyFeed),
          ) as ReadyFeed;
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
  ReadyFeedResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReadyFeedResultBuilder();
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
