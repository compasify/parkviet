//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_code_issue_meta.g.dart';

/// TableCodeIssueMeta
///
/// Properties:
/// * [token] - The code's token; shown once.
/// * [url] - What the sticker's QR holds.
/// * [printJob]
@BuiltValue()
abstract class TableCodeIssueMeta
    implements Built<TableCodeIssueMeta, TableCodeIssueMetaBuilder> {
  /// The code's token; shown once.
  @BuiltValueField(wireName: r'token')
  String? get token;

  /// What the sticker's QR holds.
  @BuiltValueField(wireName: r'url')
  String? get url;

  @BuiltValueField(wireName: r'print_job')
  BuiltMap<String, JsonObject?>? get printJob;

  TableCodeIssueMeta._();

  factory TableCodeIssueMeta([void updates(TableCodeIssueMetaBuilder b)]) =
      _$TableCodeIssueMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableCodeIssueMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableCodeIssueMeta> get serializer =>
      _$TableCodeIssueMetaSerializer();
}

class _$TableCodeIssueMetaSerializer
    implements PrimitiveSerializer<TableCodeIssueMeta> {
  @override
  final Iterable<Type> types = const [TableCodeIssueMeta, _$TableCodeIssueMeta];

  @override
  final String wireName = r'TableCodeIssueMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableCodeIssueMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield object.token == null
        ? null
        : serializers.serialize(
            object.token,
            specifiedType: const FullType.nullable(String),
          );
    yield r'url';
    yield object.url == null
        ? null
        : serializers.serialize(
            object.url,
            specifiedType: const FullType.nullable(String),
          );
    if (object.printJob != null) {
      yield r'print_job';
      yield serializers.serialize(
        object.printJob,
        specifiedType: const FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TableCodeIssueMeta object, {
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
    required TableCodeIssueMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.token = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.url = valueDes;
          break;
        case r'print_job':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.printJob.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableCodeIssueMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableCodeIssueMetaBuilder();
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
