//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'attendant_assignment_start_input.g.dart';

/// AttendantAssignmentStartInput
///
/// Properties:
/// * [branchId]
/// * [resourceId]
/// * [staffId] - An active member of the branch who serves the room.
/// * [note]
@BuiltValue()
abstract class AttendantAssignmentStartInput
    implements
        Built<AttendantAssignmentStartInput,
            AttendantAssignmentStartInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  /// An active member of the branch who serves the room.
  @BuiltValueField(wireName: r'staff_id')
  String get staffId;

  @BuiltValueField(wireName: r'note')
  String? get note;

  AttendantAssignmentStartInput._();

  factory AttendantAssignmentStartInput(
          [void updates(AttendantAssignmentStartInputBuilder b)]) =
      _$AttendantAssignmentStartInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AttendantAssignmentStartInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AttendantAssignmentStartInput> get serializer =>
      _$AttendantAssignmentStartInputSerializer();
}

class _$AttendantAssignmentStartInputSerializer
    implements PrimitiveSerializer<AttendantAssignmentStartInput> {
  @override
  final Iterable<Type> types = const [
    AttendantAssignmentStartInput,
    _$AttendantAssignmentStartInput
  ];

  @override
  final String wireName = r'AttendantAssignmentStartInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AttendantAssignmentStartInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    yield r'staff_id';
    yield serializers.serialize(
      object.staffId,
      specifiedType: const FullType(String),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AttendantAssignmentStartInput object, {
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
    required AttendantAssignmentStartInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'staff_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.staffId = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AttendantAssignmentStartInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AttendantAssignmentStartInputBuilder();
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
