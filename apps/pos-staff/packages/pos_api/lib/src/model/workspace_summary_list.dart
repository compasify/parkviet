//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/workspace_page_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_summary_list.g.dart';

/// WorkspaceSummaryList
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class WorkspaceSummaryList
    implements Built<WorkspaceSummaryList, WorkspaceSummaryListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<WorkspaceSummary> get data;

  @BuiltValueField(wireName: r'meta')
  WorkspacePageMeta? get meta;

  WorkspaceSummaryList._();

  factory WorkspaceSummaryList([void updates(WorkspaceSummaryListBuilder b)]) =
      _$WorkspaceSummaryList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceSummaryListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceSummaryList> get serializer =>
      _$WorkspaceSummaryListSerializer();
}

class _$WorkspaceSummaryListSerializer
    implements PrimitiveSerializer<WorkspaceSummaryList> {
  @override
  final Iterable<Type> types = const [
    WorkspaceSummaryList,
    _$WorkspaceSummaryList
  ];

  @override
  final String wireName = r'WorkspaceSummaryList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceSummaryList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(WorkspaceSummary)]),
    );
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(WorkspacePageMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceSummaryList object, {
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
    required WorkspaceSummaryListBuilder result,
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
                const FullType(BuiltList, [FullType(WorkspaceSummary)]),
          ) as BuiltList<WorkspaceSummary>;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(WorkspacePageMeta),
          ) as WorkspacePageMeta?;
          if (valueDes == null) continue;
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
  WorkspaceSummaryList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceSummaryListBuilder();
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
