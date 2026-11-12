//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/owner_open_order.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_open_order_result.g.dart';

/// OwnerOpenOrderResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class OwnerOpenOrderResult
    implements Built<OwnerOpenOrderResult, OwnerOpenOrderResultBuilder> {
  @BuiltValueField(wireName: r'data')
  OwnerOpenOrder get data;

  OwnerOpenOrderResult._();

  factory OwnerOpenOrderResult([void updates(OwnerOpenOrderResultBuilder b)]) =
      _$OwnerOpenOrderResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerOpenOrderResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerOpenOrderResult> get serializer =>
      _$OwnerOpenOrderResultSerializer();
}

class _$OwnerOpenOrderResultSerializer
    implements PrimitiveSerializer<OwnerOpenOrderResult> {
  @override
  final Iterable<Type> types = const [
    OwnerOpenOrderResult,
    _$OwnerOpenOrderResult
  ];

  @override
  final String wireName = r'OwnerOpenOrderResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerOpenOrderResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OwnerOpenOrder),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerOpenOrderResult object, {
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
    required OwnerOpenOrderResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnerOpenOrder),
          ) as OwnerOpenOrder;
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
  OwnerOpenOrderResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerOpenOrderResultBuilder();
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
