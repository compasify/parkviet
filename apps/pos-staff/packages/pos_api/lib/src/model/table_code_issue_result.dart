//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/table_code_issue_meta.dart';
import 'package:pos_api/src/model/table_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_code_issue_result.g.dart';

/// TableCodeIssueResult
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class TableCodeIssueResult
    implements Built<TableCodeIssueResult, TableCodeIssueResultBuilder> {
  @BuiltValueField(wireName: r'data')
  TableCode get data;

  @BuiltValueField(wireName: r'meta')
  TableCodeIssueMeta get meta;

  TableCodeIssueResult._();

  factory TableCodeIssueResult([void updates(TableCodeIssueResultBuilder b)]) =
      _$TableCodeIssueResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableCodeIssueResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableCodeIssueResult> get serializer =>
      _$TableCodeIssueResultSerializer();
}

class _$TableCodeIssueResultSerializer
    implements PrimitiveSerializer<TableCodeIssueResult> {
  @override
  final Iterable<Type> types = const [
    TableCodeIssueResult,
    _$TableCodeIssueResult
  ];

  @override
  final String wireName = r'TableCodeIssueResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableCodeIssueResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TableCode),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(TableCodeIssueMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TableCodeIssueResult object, {
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
    required TableCodeIssueResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TableCode),
          ) as TableCode;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TableCodeIssueMeta),
          ) as TableCodeIssueMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableCodeIssueResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableCodeIssueResultBuilder();
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
