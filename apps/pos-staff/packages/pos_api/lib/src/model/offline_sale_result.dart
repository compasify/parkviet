//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/offline_sale.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_sale_result.g.dart';

/// OfflineSaleResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class OfflineSaleResult
    implements Built<OfflineSaleResult, OfflineSaleResultBuilder> {
  @BuiltValueField(wireName: r'data')
  OfflineSale get data;

  OfflineSaleResult._();

  factory OfflineSaleResult([void updates(OfflineSaleResultBuilder b)]) =
      _$OfflineSaleResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSaleResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSaleResult> get serializer =>
      _$OfflineSaleResultSerializer();
}

class _$OfflineSaleResultSerializer
    implements PrimitiveSerializer<OfflineSaleResult> {
  @override
  final Iterable<Type> types = const [OfflineSaleResult, _$OfflineSaleResult];

  @override
  final String wireName = r'OfflineSaleResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSaleResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OfflineSale),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSaleResult object, {
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
    required OfflineSaleResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSale),
          ) as OfflineSale;
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
  OfflineSaleResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSaleResultBuilder();
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
