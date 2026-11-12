//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/guest_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_request_result.g.dart';

/// GuestRequestResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class GuestRequestResult
    implements Built<GuestRequestResult, GuestRequestResultBuilder> {
  @BuiltValueField(wireName: r'data')
  GuestRequest get data;

  GuestRequestResult._();

  factory GuestRequestResult([void updates(GuestRequestResultBuilder b)]) =
      _$GuestRequestResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestRequestResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestRequestResult> get serializer =>
      _$GuestRequestResultSerializer();
}

class _$GuestRequestResultSerializer
    implements PrimitiveSerializer<GuestRequestResult> {
  @override
  final Iterable<Type> types = const [GuestRequestResult, _$GuestRequestResult];

  @override
  final String wireName = r'GuestRequestResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestRequestResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(GuestRequest),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestRequestResult object, {
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
    required GuestRequestResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GuestRequest),
          ) as GuestRequest;
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
  GuestRequestResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestRequestResultBuilder();
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
