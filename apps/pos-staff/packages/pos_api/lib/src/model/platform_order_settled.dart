//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/platform_order.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_order_settled.g.dart';

/// PlatformOrderSettled
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PlatformOrderSettled
    implements Built<PlatformOrderSettled, PlatformOrderSettledBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PlatformOrder> get data;

  PlatformOrderSettled._();

  factory PlatformOrderSettled([void updates(PlatformOrderSettledBuilder b)]) =
      _$PlatformOrderSettled;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformOrderSettledBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformOrderSettled> get serializer =>
      _$PlatformOrderSettledSerializer();
}

class _$PlatformOrderSettledSerializer
    implements PrimitiveSerializer<PlatformOrderSettled> {
  @override
  final Iterable<Type> types = const [
    PlatformOrderSettled,
    _$PlatformOrderSettled
  ];

  @override
  final String wireName = r'PlatformOrderSettled';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformOrderSettled object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PlatformOrder)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformOrderSettled object, {
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
    required PlatformOrderSettledBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PlatformOrder)]),
          ) as BuiltList<PlatformOrder>;
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
  PlatformOrderSettled deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformOrderSettledBuilder();
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
