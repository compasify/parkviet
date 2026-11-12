//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'attendant_staff.g.dart';

/// AttendantStaff
///
/// Properties:
/// * [id]
/// * [name]
@BuiltValue()
abstract class AttendantStaff
    implements Built<AttendantStaff, AttendantStaffBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  AttendantStaff._();

  factory AttendantStaff([void updates(AttendantStaffBuilder b)]) =
      _$AttendantStaff;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AttendantStaffBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AttendantStaff> get serializer =>
      _$AttendantStaffSerializer();
}

class _$AttendantStaffSerializer
    implements PrimitiveSerializer<AttendantStaff> {
  @override
  final Iterable<Type> types = const [AttendantStaff, _$AttendantStaff];

  @override
  final String wireName = r'AttendantStaff';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AttendantStaff object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
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
    AttendantStaff object, {
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
    required AttendantStaffBuilder result,
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
  AttendantStaff deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AttendantStaffBuilder();
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
