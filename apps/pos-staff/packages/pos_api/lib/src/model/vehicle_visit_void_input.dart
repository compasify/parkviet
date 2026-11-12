//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_visit_void_input.g.dart';

/// VehicleVisitVoidInput
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class VehicleVisitVoidInput
    implements Built<VehicleVisitVoidInput, VehicleVisitVoidInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  VehicleVisitVoidInput._();

  factory VehicleVisitVoidInput(
      [void updates(VehicleVisitVoidInputBuilder b)]) = _$VehicleVisitVoidInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleVisitVoidInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleVisitVoidInput> get serializer =>
      _$VehicleVisitVoidInputSerializer();
}

class _$VehicleVisitVoidInputSerializer
    implements PrimitiveSerializer<VehicleVisitVoidInput> {
  @override
  final Iterable<Type> types = const [
    VehicleVisitVoidInput,
    _$VehicleVisitVoidInput
  ];

  @override
  final String wireName = r'VehicleVisitVoidInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleVisitVoidInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleVisitVoidInput object, {
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
    required VehicleVisitVoidInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleVisitVoidInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleVisitVoidInputBuilder();
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
