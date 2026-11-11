//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_send_input.g.dart';

/// The editor fields; a table order sends none.
///
/// Properties:
/// * [expectedRevision]
/// * [leaseGeneration]
/// * [editorId]
@BuiltValue()
abstract class KitchenSendInput
    implements Built<KitchenSendInput, KitchenSendInputBuilder> {
  @BuiltValueField(wireName: r'expected_revision')
  int? get expectedRevision;

  @BuiltValueField(wireName: r'lease_generation')
  int? get leaseGeneration;

  @BuiltValueField(wireName: r'editor_id')
  String? get editorId;

  KitchenSendInput._();

  factory KitchenSendInput([void updates(KitchenSendInputBuilder b)]) =
      _$KitchenSendInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenSendInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenSendInput> get serializer =>
      _$KitchenSendInputSerializer();
}

class _$KitchenSendInputSerializer
    implements PrimitiveSerializer<KitchenSendInput> {
  @override
  final Iterable<Type> types = const [KitchenSendInput, _$KitchenSendInput];

  @override
  final String wireName = r'KitchenSendInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenSendInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.expectedRevision != null) {
      yield r'expected_revision';
      yield serializers.serialize(
        object.expectedRevision,
        specifiedType: const FullType(int),
      );
    }
    if (object.leaseGeneration != null) {
      yield r'lease_generation';
      yield serializers.serialize(
        object.leaseGeneration,
        specifiedType: const FullType(int),
      );
    }
    if (object.editorId != null) {
      yield r'editor_id';
      yield serializers.serialize(
        object.editorId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenSendInput object, {
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
    required KitchenSendInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expected_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.expectedRevision = valueDes;
          break;
        case r'lease_generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.leaseGeneration = valueDes;
          break;
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  KitchenSendInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenSendInputBuilder();
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
