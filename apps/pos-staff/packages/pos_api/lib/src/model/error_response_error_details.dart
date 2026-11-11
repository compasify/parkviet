//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_response_error_details.g.dart';

/// A 409 carries `reason` and, for a stale revision, `current_revision`.
///
/// Properties:
/// * [reason]
/// * [currentRevision]
/// * [retryAfterSeconds]
@BuiltValue()
abstract class ErrorResponseErrorDetails
    implements
        Built<ErrorResponseErrorDetails, ErrorResponseErrorDetailsBuilder> {
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'current_revision')
  int? get currentRevision;

  @BuiltValueField(wireName: r'retry_after_seconds')
  int? get retryAfterSeconds;

  ErrorResponseErrorDetails._();

  factory ErrorResponseErrorDetails(
          [void updates(ErrorResponseErrorDetailsBuilder b)]) =
      _$ErrorResponseErrorDetails;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorResponseErrorDetailsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorResponseErrorDetails> get serializer =>
      _$ErrorResponseErrorDetailsSerializer();
}

class _$ErrorResponseErrorDetailsSerializer
    implements PrimitiveSerializer<ErrorResponseErrorDetails> {
  @override
  final Iterable<Type> types = const [
    ErrorResponseErrorDetails,
    _$ErrorResponseErrorDetails
  ];

  @override
  final String wireName = r'ErrorResponseErrorDetails';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorResponseErrorDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
    if (object.currentRevision != null) {
      yield r'current_revision';
      yield serializers.serialize(
        object.currentRevision,
        specifiedType: const FullType(int),
      );
    }
    if (object.retryAfterSeconds != null) {
      yield r'retry_after_seconds';
      yield serializers.serialize(
        object.retryAfterSeconds,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorResponseErrorDetails object, {
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
    required ErrorResponseErrorDetailsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'current_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.currentRevision = valueDes;
          break;
        case r'retry_after_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.retryAfterSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorResponseErrorDetails deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorResponseErrorDetailsBuilder();
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
