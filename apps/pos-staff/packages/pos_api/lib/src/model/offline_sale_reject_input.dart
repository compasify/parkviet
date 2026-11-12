//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_sale_reject_input.g.dart';

/// OfflineSaleRejectInput
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class OfflineSaleRejectInput
    implements Built<OfflineSaleRejectInput, OfflineSaleRejectInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  OfflineSaleRejectInput._();

  factory OfflineSaleRejectInput(
          [void updates(OfflineSaleRejectInputBuilder b)]) =
      _$OfflineSaleRejectInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSaleRejectInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSaleRejectInput> get serializer =>
      _$OfflineSaleRejectInputSerializer();
}

class _$OfflineSaleRejectInputSerializer
    implements PrimitiveSerializer<OfflineSaleRejectInput> {
  @override
  final Iterable<Type> types = const [
    OfflineSaleRejectInput,
    _$OfflineSaleRejectInput
  ];

  @override
  final String wireName = r'OfflineSaleRejectInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSaleRejectInput object, {
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
    OfflineSaleRejectInput object, {
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
    required OfflineSaleRejectInputBuilder result,
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
  OfflineSaleRejectInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSaleRejectInputBuilder();
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
