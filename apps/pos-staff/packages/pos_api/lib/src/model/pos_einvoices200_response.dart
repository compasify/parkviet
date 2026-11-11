//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/einvoice.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoices200_response.g.dart';

/// PosEinvoices200Response
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class PosEinvoices200Response
    implements Built<PosEinvoices200Response, PosEinvoices200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Einvoice> get data;

  @BuiltValueField(wireName: r'meta')
  JsonObject get meta;

  PosEinvoices200Response._();

  factory PosEinvoices200Response(
          [void updates(PosEinvoices200ResponseBuilder b)]) =
      _$PosEinvoices200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoices200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoices200Response> get serializer =>
      _$PosEinvoices200ResponseSerializer();
}

class _$PosEinvoices200ResponseSerializer
    implements PrimitiveSerializer<PosEinvoices200Response> {
  @override
  final Iterable<Type> types = const [
    PosEinvoices200Response,
    _$PosEinvoices200Response
  ];

  @override
  final String wireName = r'PosEinvoices200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoices200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Einvoice)]),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoices200Response object, {
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
    required PosEinvoices200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Einvoice)]),
          ) as BuiltList<Einvoice>;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.meta = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosEinvoices200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoices200ResponseBuilder();
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
