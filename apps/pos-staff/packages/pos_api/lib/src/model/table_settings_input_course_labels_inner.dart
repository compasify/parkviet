//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_settings_input_course_labels_inner.g.dart';

/// TableSettingsInputCourseLabelsInner
///
/// Properties:
/// * [name]
@BuiltValue()
abstract class TableSettingsInputCourseLabelsInner
    implements
        Built<TableSettingsInputCourseLabelsInner,
            TableSettingsInputCourseLabelsInnerBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  TableSettingsInputCourseLabelsInner._();

  factory TableSettingsInputCourseLabelsInner(
          [void updates(TableSettingsInputCourseLabelsInnerBuilder b)]) =
      _$TableSettingsInputCourseLabelsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableSettingsInputCourseLabelsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableSettingsInputCourseLabelsInner> get serializer =>
      _$TableSettingsInputCourseLabelsInnerSerializer();
}

class _$TableSettingsInputCourseLabelsInnerSerializer
    implements PrimitiveSerializer<TableSettingsInputCourseLabelsInner> {
  @override
  final Iterable<Type> types = const [
    TableSettingsInputCourseLabelsInner,
    _$TableSettingsInputCourseLabelsInner
  ];

  @override
  final String wireName = r'TableSettingsInputCourseLabelsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableSettingsInputCourseLabelsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TableSettingsInputCourseLabelsInner object, {
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
    required TableSettingsInputCourseLabelsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  TableSettingsInputCourseLabelsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableSettingsInputCourseLabelsInnerBuilder();
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
