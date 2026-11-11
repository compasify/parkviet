//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_service_charge.g.dart';

/// The branch's service charge on this order; `amount` is 0 when waived or not charged.
///
/// Properties:
/// * [rate]
/// * [amount]
/// * [waived]
/// * [applies] - The order's service mode is one the branch charges.
@BuiltValue()
abstract class WorkspaceServiceCharge
    implements Built<WorkspaceServiceCharge, WorkspaceServiceChargeBuilder> {
  @BuiltValueField(wireName: r'rate')
  String? get rate;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'waived')
  bool get waived;

  /// The order's service mode is one the branch charges.
  @BuiltValueField(wireName: r'applies')
  bool get applies;

  WorkspaceServiceCharge._();

  factory WorkspaceServiceCharge(
          [void updates(WorkspaceServiceChargeBuilder b)]) =
      _$WorkspaceServiceCharge;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceServiceChargeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceServiceCharge> get serializer =>
      _$WorkspaceServiceChargeSerializer();
}

class _$WorkspaceServiceChargeSerializer
    implements PrimitiveSerializer<WorkspaceServiceCharge> {
  @override
  final Iterable<Type> types = const [
    WorkspaceServiceCharge,
    _$WorkspaceServiceCharge
  ];

  @override
  final String wireName = r'WorkspaceServiceCharge';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceServiceCharge object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rate';
    yield object.rate == null
        ? null
        : serializers.serialize(
            object.rate,
            specifiedType: const FullType.nullable(String),
          );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'waived';
    yield serializers.serialize(
      object.waived,
      specifiedType: const FullType(bool),
    );
    yield r'applies';
    yield serializers.serialize(
      object.applies,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceServiceCharge object, {
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
    required WorkspaceServiceChargeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.rate = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'waived':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.waived = valueDes;
          break;
        case r'applies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.applies = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceServiceCharge deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceServiceChargeBuilder();
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
