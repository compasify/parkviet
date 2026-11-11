//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/menu_margin_row.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_report_menu_margin200_response.g.dart';

/// PosReportMenuMargin200Response
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class PosReportMenuMargin200Response
    implements
        Built<PosReportMenuMargin200Response,
            PosReportMenuMargin200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MenuMarginRow> get data;

  @BuiltValueField(wireName: r'meta')
  JsonObject get meta;

  PosReportMenuMargin200Response._();

  factory PosReportMenuMargin200Response(
          [void updates(PosReportMenuMargin200ResponseBuilder b)]) =
      _$PosReportMenuMargin200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosReportMenuMargin200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosReportMenuMargin200Response> get serializer =>
      _$PosReportMenuMargin200ResponseSerializer();
}

class _$PosReportMenuMargin200ResponseSerializer
    implements PrimitiveSerializer<PosReportMenuMargin200Response> {
  @override
  final Iterable<Type> types = const [
    PosReportMenuMargin200Response,
    _$PosReportMenuMargin200Response
  ];

  @override
  final String wireName = r'PosReportMenuMargin200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosReportMenuMargin200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(MenuMarginRow)]),
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
    PosReportMenuMargin200Response object, {
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
    required PosReportMenuMargin200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MenuMarginRow)]),
          ) as BuiltList<MenuMarginRow>;
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
  PosReportMenuMargin200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosReportMenuMargin200ResponseBuilder();
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
