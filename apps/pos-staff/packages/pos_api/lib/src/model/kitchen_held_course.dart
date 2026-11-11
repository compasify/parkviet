//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_held_line.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_held_course.g.dart';

/// KitchenHeldCourse
///
/// Properties:
/// * [workspaceId]
/// * [resourceName]
/// * [areaId]
/// * [course]
/// * [courseName]
/// * [heldSince]
/// * [lines]
@BuiltValue()
abstract class KitchenHeldCourse
    implements Built<KitchenHeldCourse, KitchenHeldCourseBuilder> {
  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'resource_name')
  String? get resourceName;

  @BuiltValueField(wireName: r'area_id')
  String? get areaId;

  @BuiltValueField(wireName: r'course')
  int get course;

  @BuiltValueField(wireName: r'course_name')
  String get courseName;

  @BuiltValueField(wireName: r'held_since')
  DateTime get heldSince;

  @BuiltValueField(wireName: r'lines')
  BuiltList<KitchenHeldLine> get lines;

  KitchenHeldCourse._();

  factory KitchenHeldCourse([void updates(KitchenHeldCourseBuilder b)]) =
      _$KitchenHeldCourse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenHeldCourseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenHeldCourse> get serializer =>
      _$KitchenHeldCourseSerializer();
}

class _$KitchenHeldCourseSerializer
    implements PrimitiveSerializer<KitchenHeldCourse> {
  @override
  final Iterable<Type> types = const [KitchenHeldCourse, _$KitchenHeldCourse];

  @override
  final String wireName = r'KitchenHeldCourse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenHeldCourse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'resource_name';
    yield object.resourceName == null
        ? null
        : serializers.serialize(
            object.resourceName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'area_id';
    yield object.areaId == null
        ? null
        : serializers.serialize(
            object.areaId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'course';
    yield serializers.serialize(
      object.course,
      specifiedType: const FullType(int),
    );
    yield r'course_name';
    yield serializers.serialize(
      object.courseName,
      specifiedType: const FullType(String),
    );
    yield r'held_since';
    yield serializers.serialize(
      object.heldSince,
      specifiedType: const FullType(DateTime),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(KitchenHeldLine)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenHeldCourse object, {
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
    required KitchenHeldCourseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'resource_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resourceName = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.areaId = valueDes;
          break;
        case r'course':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.course = valueDes;
          break;
        case r'course_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.courseName = valueDes;
          break;
        case r'held_since':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.heldSince = valueDes;
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenHeldLine)]),
          ) as BuiltList<KitchenHeldLine>;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenHeldCourse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenHeldCourseBuilder();
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
