//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_settle_order_input.g.dart';

/// PlatformSettleOrderInput
///
/// Properties:
/// * [id]
/// * [commissionAmount] - What the platform actually kept. Absent keeps the estimate.
@BuiltValue()
abstract class PlatformSettleOrderInput
    implements
        Built<PlatformSettleOrderInput, PlatformSettleOrderInputBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// What the platform actually kept. Absent keeps the estimate.
  @BuiltValueField(wireName: r'commission_amount')
  String? get commissionAmount;

  PlatformSettleOrderInput._();

  factory PlatformSettleOrderInput(
          [void updates(PlatformSettleOrderInputBuilder b)]) =
      _$PlatformSettleOrderInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformSettleOrderInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformSettleOrderInput> get serializer =>
      _$PlatformSettleOrderInputSerializer();
}

class _$PlatformSettleOrderInputSerializer
    implements PrimitiveSerializer<PlatformSettleOrderInput> {
  @override
  final Iterable<Type> types = const [
    PlatformSettleOrderInput,
    _$PlatformSettleOrderInput
  ];

  @override
  final String wireName = r'PlatformSettleOrderInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformSettleOrderInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.commissionAmount != null) {
      yield r'commission_amount';
      yield serializers.serialize(
        object.commissionAmount,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformSettleOrderInput object, {
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
    required PlatformSettleOrderInputBuilder result,
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
        case r'commission_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.commissionAmount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformSettleOrderInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformSettleOrderInputBuilder();
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
