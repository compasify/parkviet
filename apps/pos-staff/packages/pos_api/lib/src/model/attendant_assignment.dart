//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/attendant_staff.dart';
import 'package:pos_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'attendant_assignment.g.dart';

/// Who serves a room from when to when; an open turn has no end. Never on the bill.
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [resourceId]
/// * [resourceName]
/// * [timedSessionId]
/// * [staff]
/// * [startedAt]
/// * [endedAt]
/// * [minutes] - Whole minutes served up to the server's now, or to the end.
/// * [businessDate]
/// * [note]
@BuiltValue()
abstract class AttendantAssignment
    implements Built<AttendantAssignment, AttendantAssignmentBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  @BuiltValueField(wireName: r'resource_name')
  String get resourceName;

  @BuiltValueField(wireName: r'timed_session_id')
  String? get timedSessionId;

  @BuiltValueField(wireName: r'staff')
  AttendantStaff get staff;

  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  /// Whole minutes served up to the server's now, or to the end.
  @BuiltValueField(wireName: r'minutes')
  int get minutes;

  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  @BuiltValueField(wireName: r'note')
  String? get note;

  AttendantAssignment._();

  factory AttendantAssignment([void updates(AttendantAssignmentBuilder b)]) =
      _$AttendantAssignment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AttendantAssignmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AttendantAssignment> get serializer =>
      _$AttendantAssignmentSerializer();
}

class _$AttendantAssignmentSerializer
    implements PrimitiveSerializer<AttendantAssignment> {
  @override
  final Iterable<Type> types = const [
    AttendantAssignment,
    _$AttendantAssignment
  ];

  @override
  final String wireName = r'AttendantAssignment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AttendantAssignment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
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
    yield r'resource_name';
    yield serializers.serialize(
      object.resourceName,
      specifiedType: const FullType(String),
    );
    yield r'timed_session_id';
    yield object.timedSessionId == null
        ? null
        : serializers.serialize(
            object.timedSessionId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'staff';
    yield serializers.serialize(
      object.staff,
      specifiedType: const FullType(AttendantStaff),
    );
    yield r'started_at';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ended_at';
    yield object.endedAt == null
        ? null
        : serializers.serialize(
            object.endedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'minutes';
    yield serializers.serialize(
      object.minutes,
      specifiedType: const FullType(int),
    );
    yield r'business_date';
    yield serializers.serialize(
      object.businessDate,
      specifiedType: const FullType(Date),
    );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    AttendantAssignment object, {
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
    required AttendantAssignmentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
        case r'resource_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceName = valueDes;
          break;
        case r'timed_session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timedSessionId = valueDes;
          break;
        case r'staff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AttendantStaff),
          ) as AttendantStaff;
          result.staff.replace(valueDes);
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
        case r'minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minutes = valueDes;
          break;
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.businessDate = valueDes;
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
  AttendantAssignment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AttendantAssignmentBuilder();
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
