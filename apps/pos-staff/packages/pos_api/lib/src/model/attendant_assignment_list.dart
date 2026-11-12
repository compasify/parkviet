//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/attendant_assignment.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/workspace_page_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'attendant_assignment_list.g.dart';

/// AttendantAssignmentList
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class AttendantAssignmentList
    implements Built<AttendantAssignmentList, AttendantAssignmentListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AttendantAssignment> get data;

  @BuiltValueField(wireName: r'meta')
  WorkspacePageMeta get meta;

  AttendantAssignmentList._();

  factory AttendantAssignmentList(
          [void updates(AttendantAssignmentListBuilder b)]) =
      _$AttendantAssignmentList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AttendantAssignmentListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AttendantAssignmentList> get serializer =>
      _$AttendantAssignmentListSerializer();
}

class _$AttendantAssignmentListSerializer
    implements PrimitiveSerializer<AttendantAssignmentList> {
  @override
  final Iterable<Type> types = const [
    AttendantAssignmentList,
    _$AttendantAssignmentList
  ];

  @override
  final String wireName = r'AttendantAssignmentList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AttendantAssignmentList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(AttendantAssignment)]),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(WorkspacePageMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AttendantAssignmentList object, {
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
    required AttendantAssignmentListBuilder result,
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
                const FullType(BuiltList, [FullType(AttendantAssignment)]),
          ) as BuiltList<AttendantAssignment>;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkspacePageMeta),
          ) as WorkspacePageMeta;
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
  AttendantAssignmentList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AttendantAssignmentListBuilder();
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
