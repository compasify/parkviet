//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'course_label.g.dart';

/// CourseLabel
///
/// Properties:
/// * [position]
/// * [name]
@BuiltValue()
abstract class CourseLabel implements Built<CourseLabel, CourseLabelBuilder> {
  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'name')
  String get name;

  CourseLabel._();

  factory CourseLabel([void updates(CourseLabelBuilder b)]) = _$CourseLabel;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CourseLabelBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CourseLabel> get serializer => _$CourseLabelSerializer();
}

class _$CourseLabelSerializer implements PrimitiveSerializer<CourseLabel> {
  @override
  final Iterable<Type> types = const [CourseLabel, _$CourseLabel];

  @override
  final String wireName = r'CourseLabel';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CourseLabel object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CourseLabel object, {
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
    required CourseLabelBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CourseLabel deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CourseLabelBuilder();
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
