//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_branch.g.dart';

/// OwnerBranch
///
/// Properties:
/// * [id]
/// * [name]
/// * [code]
/// * [timezone]
/// * [canReadReports]
/// * [canApprove]
/// * [canManageReservations] - May confirm and cancel the branch's bookings.
@BuiltValue()
abstract class OwnerBranch implements Built<OwnerBranch, OwnerBranchBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'timezone')
  String get timezone;

  @BuiltValueField(wireName: r'can_read_reports')
  bool get canReadReports;

  @BuiltValueField(wireName: r'can_approve')
  bool get canApprove;

  /// May confirm and cancel the branch's bookings.
  @BuiltValueField(wireName: r'can_manage_reservations')
  bool get canManageReservations;

  OwnerBranch._();

  factory OwnerBranch([void updates(OwnerBranchBuilder b)]) = _$OwnerBranch;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerBranchBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerBranch> get serializer => _$OwnerBranchSerializer();
}

class _$OwnerBranchSerializer implements PrimitiveSerializer<OwnerBranch> {
  @override
  final Iterable<Type> types = const [OwnerBranch, _$OwnerBranch];

  @override
  final String wireName = r'OwnerBranch';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerBranch object, {
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
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'timezone';
    yield serializers.serialize(
      object.timezone,
      specifiedType: const FullType(String),
    );
    yield r'can_read_reports';
    yield serializers.serialize(
      object.canReadReports,
      specifiedType: const FullType(bool),
    );
    yield r'can_approve';
    yield serializers.serialize(
      object.canApprove,
      specifiedType: const FullType(bool),
    );
    yield r'can_manage_reservations';
    yield serializers.serialize(
      object.canManageReservations,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerBranch object, {
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
    required OwnerBranchBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timezone = valueDes;
          break;
        case r'can_read_reports':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canReadReports = valueDes;
          break;
        case r'can_approve':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canApprove = valueDes;
          break;
        case r'can_manage_reservations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canManageReservations = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnerBranch deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerBranchBuilder();
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
