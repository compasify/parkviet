//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_commission_snapshot.g.dart';

/// VehicleCommissionSnapshot
///
/// Properties:
/// * [amount]
/// * [qualified]
/// * [reason]
/// * [guestCount]
/// * [revenue]
@BuiltValue()
abstract class VehicleCommissionSnapshot
    implements
        Built<VehicleCommissionSnapshot, VehicleCommissionSnapshotBuilder> {
  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'qualified')
  bool? get qualified;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  @BuiltValueField(wireName: r'revenue')
  String? get revenue;

  VehicleCommissionSnapshot._();

  factory VehicleCommissionSnapshot(
          [void updates(VehicleCommissionSnapshotBuilder b)]) =
      _$VehicleCommissionSnapshot;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleCommissionSnapshotBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleCommissionSnapshot> get serializer =>
      _$VehicleCommissionSnapshotSerializer();
}

class _$VehicleCommissionSnapshotSerializer
    implements PrimitiveSerializer<VehicleCommissionSnapshot> {
  @override
  final Iterable<Type> types = const [
    VehicleCommissionSnapshot,
    _$VehicleCommissionSnapshot
  ];

  @override
  final String wireName = r'VehicleCommissionSnapshot';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleCommissionSnapshot object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType(String),
      );
    }
    if (object.qualified != null) {
      yield r'qualified';
      yield serializers.serialize(
        object.qualified,
        specifiedType: const FullType(bool),
      );
    }
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.guestCount != null) {
      yield r'guest_count';
      yield serializers.serialize(
        object.guestCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.revenue != null) {
      yield r'revenue';
      yield serializers.serialize(
        object.revenue,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleCommissionSnapshot object, {
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
    required VehicleCommissionSnapshotBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.amount = valueDes;
          break;
        case r'qualified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.qualified = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'revenue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.revenue = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleCommissionSnapshot deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleCommissionSnapshotBuilder();
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
