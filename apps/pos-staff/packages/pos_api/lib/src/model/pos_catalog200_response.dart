//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/catalog_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_catalog200_response.g.dart';

/// PosCatalog200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosCatalog200Response
    implements Built<PosCatalog200Response, PosCatalog200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<CatalogItem> get data;

  PosCatalog200Response._();

  factory PosCatalog200Response(
      [void updates(PosCatalog200ResponseBuilder b)]) = _$PosCatalog200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosCatalog200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosCatalog200Response> get serializer =>
      _$PosCatalog200ResponseSerializer();
}

class _$PosCatalog200ResponseSerializer
    implements PrimitiveSerializer<PosCatalog200Response> {
  @override
  final Iterable<Type> types = const [
    PosCatalog200Response,
    _$PosCatalog200Response
  ];

  @override
  final String wireName = r'PosCatalog200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosCatalog200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(CatalogItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosCatalog200Response object, {
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
    required PosCatalog200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CatalogItem)]),
          ) as BuiltList<CatalogItem>;
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
  PosCatalog200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosCatalog200ResponseBuilder();
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
