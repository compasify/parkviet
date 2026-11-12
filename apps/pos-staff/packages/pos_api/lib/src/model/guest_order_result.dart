//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/guest_order.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_order_result.g.dart';

/// GuestOrderResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class GuestOrderResult
    implements Built<GuestOrderResult, GuestOrderResultBuilder> {
  @BuiltValueField(wireName: r'data')
  GuestOrder get data;

  GuestOrderResult._();

  factory GuestOrderResult([void updates(GuestOrderResultBuilder b)]) =
      _$GuestOrderResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestOrderResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestOrderResult> get serializer =>
      _$GuestOrderResultSerializer();
}

class _$GuestOrderResultSerializer
    implements PrimitiveSerializer<GuestOrderResult> {
  @override
  final Iterable<Type> types = const [GuestOrderResult, _$GuestOrderResult];

  @override
  final String wireName = r'GuestOrderResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestOrderResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(GuestOrder),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestOrderResult object, {
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
    required GuestOrderResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GuestOrder),
          ) as GuestOrder;
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
  GuestOrderResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestOrderResultBuilder();
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
