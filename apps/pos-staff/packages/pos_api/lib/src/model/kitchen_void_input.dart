//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_void_input.g.dart';

/// KitchenVoidInput
///
/// Properties:
/// * [quantity]
/// * [reasonCode] - One of the branch's `void_reasons`, or `khac` with a note.
/// * [note]
/// * [approvalId]
/// * [expectedRevision]
/// * [leaseGeneration]
/// * [editorId]
@BuiltValue()
abstract class KitchenVoidInput
    implements Built<KitchenVoidInput, KitchenVoidInputBuilder> {
  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  /// One of the branch's `void_reasons`, or `khac` with a note.
  @BuiltValueField(wireName: r'reason_code')
  String get reasonCode;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  @BuiltValueField(wireName: r'expected_revision')
  int? get expectedRevision;

  @BuiltValueField(wireName: r'lease_generation')
  int? get leaseGeneration;

  @BuiltValueField(wireName: r'editor_id')
  String? get editorId;

  KitchenVoidInput._();

  factory KitchenVoidInput([void updates(KitchenVoidInputBuilder b)]) =
      _$KitchenVoidInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenVoidInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenVoidInput> get serializer =>
      _$KitchenVoidInputSerializer();
}

class _$KitchenVoidInputSerializer
    implements PrimitiveSerializer<KitchenVoidInput> {
  @override
  final Iterable<Type> types = const [KitchenVoidInput, _$KitchenVoidInput];

  @override
  final String wireName = r'KitchenVoidInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenVoidInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    yield r'reason_code';
    yield serializers.serialize(
      object.reasonCode,
      specifiedType: const FullType(String),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.approvalId != null) {
      yield r'approval_id';
      yield serializers.serialize(
        object.approvalId,
        specifiedType: const FullType(String),
      );
    }
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
    KitchenVoidInput object, {
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
    required KitchenVoidInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reasonCode = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
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
  KitchenVoidInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenVoidInputBuilder();
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
