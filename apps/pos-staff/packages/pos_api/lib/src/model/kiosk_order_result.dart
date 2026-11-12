//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_order.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_order_result.g.dart';

/// KioskOrderResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class KioskOrderResult
    implements Built<KioskOrderResult, KioskOrderResultBuilder> {
  @BuiltValueField(wireName: r'data')
  KioskOrder get data;

  KioskOrderResult._();

  factory KioskOrderResult([void updates(KioskOrderResultBuilder b)]) =
      _$KioskOrderResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskOrderResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskOrderResult> get serializer =>
      _$KioskOrderResultSerializer();
}

class _$KioskOrderResultSerializer
    implements PrimitiveSerializer<KioskOrderResult> {
  @override
  final Iterable<Type> types = const [KioskOrderResult, _$KioskOrderResult];

  @override
  final String wireName = r'KioskOrderResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskOrderResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KioskOrder),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskOrderResult object, {
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
    required KioskOrderResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskOrder),
          ) as KioskOrder;
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
  KioskOrderResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskOrderResultBuilder();
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
