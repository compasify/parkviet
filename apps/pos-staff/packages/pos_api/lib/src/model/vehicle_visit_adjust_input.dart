//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_visit_adjust_input.g.dart';

/// VehicleVisitAdjustInput
///
/// Properties:
/// * [expectedRevision]
/// * [guestCount]
/// * [commissionAmount]
/// * [note]
/// * [approvalId]
@BuiltValue()
abstract class VehicleVisitAdjustInput
    implements Built<VehicleVisitAdjustInput, VehicleVisitAdjustInputBuilder> {
  @BuiltValueField(wireName: r'expected_revision')
  int get expectedRevision;

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  @BuiltValueField(wireName: r'commission_amount')
  String? get commissionAmount;

  @BuiltValueField(wireName: r'note')
  String get note;

  @BuiltValueField(wireName: r'approval_id')
  String get approvalId;

  VehicleVisitAdjustInput._();

  factory VehicleVisitAdjustInput(
          [void updates(VehicleVisitAdjustInputBuilder b)]) =
      _$VehicleVisitAdjustInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleVisitAdjustInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleVisitAdjustInput> get serializer =>
      _$VehicleVisitAdjustInputSerializer();
}

class _$VehicleVisitAdjustInputSerializer
    implements PrimitiveSerializer<VehicleVisitAdjustInput> {
  @override
  final Iterable<Type> types = const [
    VehicleVisitAdjustInput,
    _$VehicleVisitAdjustInput
  ];

  @override
  final String wireName = r'VehicleVisitAdjustInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleVisitAdjustInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expected_revision';
    yield serializers.serialize(
      object.expectedRevision,
      specifiedType: const FullType(int),
    );
    if (object.guestCount != null) {
      yield r'guest_count';
      yield serializers.serialize(
        object.guestCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.commissionAmount != null) {
      yield r'commission_amount';
      yield serializers.serialize(
        object.commissionAmount,
        specifiedType: const FullType(String),
      );
    }
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
    yield r'approval_id';
    yield serializers.serialize(
      object.approvalId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleVisitAdjustInput object, {
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
    required VehicleVisitAdjustInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expected_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedRevision = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'commission_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.commissionAmount = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.approvalId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleVisitAdjustInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleVisitAdjustInputBuilder();
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
