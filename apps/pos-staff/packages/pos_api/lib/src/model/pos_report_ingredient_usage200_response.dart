//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/ingredient_usage_row.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_report_ingredient_usage200_response.g.dart';

/// PosReportIngredientUsage200Response
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class PosReportIngredientUsage200Response
    implements
        Built<PosReportIngredientUsage200Response,
            PosReportIngredientUsage200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<IngredientUsageRow> get data;

  @BuiltValueField(wireName: r'meta')
  JsonObject get meta;

  PosReportIngredientUsage200Response._();

  factory PosReportIngredientUsage200Response(
          [void updates(PosReportIngredientUsage200ResponseBuilder b)]) =
      _$PosReportIngredientUsage200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosReportIngredientUsage200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosReportIngredientUsage200Response> get serializer =>
      _$PosReportIngredientUsage200ResponseSerializer();
}

class _$PosReportIngredientUsage200ResponseSerializer
    implements PrimitiveSerializer<PosReportIngredientUsage200Response> {
  @override
  final Iterable<Type> types = const [
    PosReportIngredientUsage200Response,
    _$PosReportIngredientUsage200Response
  ];

  @override
  final String wireName = r'PosReportIngredientUsage200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosReportIngredientUsage200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(IngredientUsageRow)]),
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
    PosReportIngredientUsage200Response object, {
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
    required PosReportIngredientUsage200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(IngredientUsageRow)]),
          ) as BuiltList<IngredientUsageRow>;
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
  PosReportIngredientUsage200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosReportIngredientUsage200ResponseBuilder();
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
