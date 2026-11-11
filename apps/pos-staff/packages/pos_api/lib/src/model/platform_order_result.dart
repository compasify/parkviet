//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/platform_order.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_order_result.g.dart';

/// PlatformOrderResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PlatformOrderResult
    implements Built<PlatformOrderResult, PlatformOrderResultBuilder> {
  @BuiltValueField(wireName: r'data')
  PlatformOrder get data;

  PlatformOrderResult._();

  factory PlatformOrderResult([void updates(PlatformOrderResultBuilder b)]) =
      _$PlatformOrderResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformOrderResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformOrderResult> get serializer =>
      _$PlatformOrderResultSerializer();
}

class _$PlatformOrderResultSerializer
    implements PrimitiveSerializer<PlatformOrderResult> {
  @override
  final Iterable<Type> types = const [
    PlatformOrderResult,
    _$PlatformOrderResult
  ];

  @override
  final String wireName = r'PlatformOrderResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformOrderResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PlatformOrder),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformOrderResult object, {
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
    required PlatformOrderResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformOrder),
          ) as PlatformOrder;
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
  PlatformOrderResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformOrderResultBuilder();
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
