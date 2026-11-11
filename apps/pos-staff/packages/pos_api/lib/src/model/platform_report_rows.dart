//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/platform_report_row.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_report_rows.g.dart';

/// PlatformReportRows
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class PlatformReportRows
    implements Built<PlatformReportRows, PlatformReportRowsBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PlatformReportRow> get data;

  @BuiltValueField(wireName: r'meta')
  JsonObject get meta;

  PlatformReportRows._();

  factory PlatformReportRows([void updates(PlatformReportRowsBuilder b)]) =
      _$PlatformReportRows;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformReportRowsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformReportRows> get serializer =>
      _$PlatformReportRowsSerializer();
}

class _$PlatformReportRowsSerializer
    implements PrimitiveSerializer<PlatformReportRows> {
  @override
  final Iterable<Type> types = const [PlatformReportRows, _$PlatformReportRows];

  @override
  final String wireName = r'PlatformReportRows';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformReportRows object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PlatformReportRow)]),
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
    PlatformReportRows object, {
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
    required PlatformReportRowsBuilder result,
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
                const FullType(BuiltList, [FullType(PlatformReportRow)]),
          ) as BuiltList<PlatformReportRow>;
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
  PlatformReportRows deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformReportRowsBuilder();
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
