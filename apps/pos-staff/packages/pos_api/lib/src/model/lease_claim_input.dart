//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'lease_claim_input.g.dart';

/// LeaseClaimInput
///
/// Properties:
/// * [editorId] - This screen's editor id; move and merge send it back with the lease generation.
/// * [takeover]
@BuiltValue()
abstract class LeaseClaimInput
    implements Built<LeaseClaimInput, LeaseClaimInputBuilder> {
  /// This screen's editor id; move and merge send it back with the lease generation.
  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  @BuiltValueField(wireName: r'takeover')
  bool? get takeover;

  LeaseClaimInput._();

  factory LeaseClaimInput([void updates(LeaseClaimInputBuilder b)]) =
      _$LeaseClaimInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LeaseClaimInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LeaseClaimInput> get serializer =>
      _$LeaseClaimInputSerializer();
}

class _$LeaseClaimInputSerializer
    implements PrimitiveSerializer<LeaseClaimInput> {
  @override
  final Iterable<Type> types = const [LeaseClaimInput, _$LeaseClaimInput];

  @override
  final String wireName = r'LeaseClaimInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LeaseClaimInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
    if (object.takeover != null) {
      yield r'takeover';
      yield serializers.serialize(
        object.takeover,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LeaseClaimInput object, {
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
    required LeaseClaimInputBuilder result,
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
        case r'takeover':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.takeover = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LeaseClaimInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LeaseClaimInputBuilder();
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
