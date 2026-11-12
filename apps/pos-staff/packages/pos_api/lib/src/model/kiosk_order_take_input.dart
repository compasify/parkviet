//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_order_take_input.g.dart';

/// KioskOrderTakeInput
///
/// Properties:
/// * [editorId]
@BuiltValue()
abstract class KioskOrderTakeInput
    implements Built<KioskOrderTakeInput, KioskOrderTakeInputBuilder> {
  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  KioskOrderTakeInput._();

  factory KioskOrderTakeInput([void updates(KioskOrderTakeInputBuilder b)]) =
      _$KioskOrderTakeInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskOrderTakeInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskOrderTakeInput> get serializer =>
      _$KioskOrderTakeInputSerializer();
}

class _$KioskOrderTakeInputSerializer
    implements PrimitiveSerializer<KioskOrderTakeInput> {
  @override
  final Iterable<Type> types = const [
    KioskOrderTakeInput,
    _$KioskOrderTakeInput
  ];

  @override
  final String wireName = r'KioskOrderTakeInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskOrderTakeInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskOrderTakeInput object, {
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
    required KioskOrderTakeInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskOrderTakeInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskOrderTakeInputBuilder();
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
