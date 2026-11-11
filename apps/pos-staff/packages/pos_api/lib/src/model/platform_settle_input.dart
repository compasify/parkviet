//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/platform_settle_order_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_settle_input.g.dart';

/// PlatformSettleInput
///
/// Properties:
/// * [branchId]
/// * [reference]
/// * [orders]
@BuiltValue()
abstract class PlatformSettleInput
    implements Built<PlatformSettleInput, PlatformSettleInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'orders')
  BuiltList<PlatformSettleOrderInput> get orders;

  PlatformSettleInput._();

  factory PlatformSettleInput([void updates(PlatformSettleInputBuilder b)]) =
      _$PlatformSettleInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformSettleInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformSettleInput> get serializer =>
      _$PlatformSettleInputSerializer();
}

class _$PlatformSettleInputSerializer
    implements PrimitiveSerializer<PlatformSettleInput> {
  @override
  final Iterable<Type> types = const [
    PlatformSettleInput,
    _$PlatformSettleInput
  ];

  @override
  final String wireName = r'PlatformSettleInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformSettleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    if (object.reference != null) {
      yield r'reference';
      yield serializers.serialize(
        object.reference,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'orders';
    yield serializers.serialize(
      object.orders,
      specifiedType:
          const FullType(BuiltList, [FullType(PlatformSettleOrderInput)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformSettleInput object, {
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
    required PlatformSettleInputBuilder result,
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
        case r'reference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reference = valueDes;
          break;
        case r'orders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(PlatformSettleOrderInput)]),
          ) as BuiltList<PlatformSettleOrderInput>;
          result.orders.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformSettleInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformSettleInputBuilder();
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
