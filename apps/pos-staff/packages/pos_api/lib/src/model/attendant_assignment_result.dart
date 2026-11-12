//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/attendant_assignment.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'attendant_assignment_result.g.dart';

/// AttendantAssignmentResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class AttendantAssignmentResult
    implements
        Built<AttendantAssignmentResult, AttendantAssignmentResultBuilder> {
  @BuiltValueField(wireName: r'data')
  AttendantAssignment get data;

  AttendantAssignmentResult._();

  factory AttendantAssignmentResult(
          [void updates(AttendantAssignmentResultBuilder b)]) =
      _$AttendantAssignmentResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AttendantAssignmentResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AttendantAssignmentResult> get serializer =>
      _$AttendantAssignmentResultSerializer();
}

class _$AttendantAssignmentResultSerializer
    implements PrimitiveSerializer<AttendantAssignmentResult> {
  @override
  final Iterable<Type> types = const [
    AttendantAssignmentResult,
    _$AttendantAssignmentResult
  ];

  @override
  final String wireName = r'AttendantAssignmentResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AttendantAssignmentResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AttendantAssignment),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AttendantAssignmentResult object, {
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
    required AttendantAssignmentResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AttendantAssignment),
          ) as AttendantAssignment;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AttendantAssignmentResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AttendantAssignmentResultBuilder();
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
