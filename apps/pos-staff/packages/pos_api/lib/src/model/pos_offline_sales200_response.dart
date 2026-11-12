//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/offline_sale.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_offline_sales200_response.g.dart';

/// PosOfflineSales200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosOfflineSales200Response
    implements
        Built<PosOfflineSales200Response, PosOfflineSales200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OfflineSale> get data;

  PosOfflineSales200Response._();

  factory PosOfflineSales200Response(
          [void updates(PosOfflineSales200ResponseBuilder b)]) =
      _$PosOfflineSales200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosOfflineSales200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosOfflineSales200Response> get serializer =>
      _$PosOfflineSales200ResponseSerializer();
}

class _$PosOfflineSales200ResponseSerializer
    implements PrimitiveSerializer<PosOfflineSales200Response> {
  @override
  final Iterable<Type> types = const [
    PosOfflineSales200Response,
    _$PosOfflineSales200Response
  ];

  @override
  final String wireName = r'PosOfflineSales200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosOfflineSales200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OfflineSale)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosOfflineSales200Response object, {
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
    required PosOfflineSales200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OfflineSale)]),
          ) as BuiltList<OfflineSale>;
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
  PosOfflineSales200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosOfflineSales200ResponseBuilder();
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
