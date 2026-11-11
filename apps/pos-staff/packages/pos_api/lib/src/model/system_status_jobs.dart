//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status_jobs.g.dart';

/// SystemStatusJobs
///
/// Properties:
/// * [ok] - A Solid Queue process heartbeated recently
/// * [inPuma]
/// * [processes]
/// * [ready]
/// * [oldestReadyAgeSeconds]
/// * [failed]
@BuiltValue()
abstract class SystemStatusJobs
    implements Built<SystemStatusJobs, SystemStatusJobsBuilder> {
  /// A Solid Queue process heartbeated recently
  @BuiltValueField(wireName: r'ok')
  bool get ok;

  @BuiltValueField(wireName: r'in_puma')
  bool? get inPuma;

  @BuiltValueField(wireName: r'processes')
  int? get processes;

  @BuiltValueField(wireName: r'ready')
  int? get ready;

  @BuiltValueField(wireName: r'oldest_ready_age_seconds')
  int? get oldestReadyAgeSeconds;

  @BuiltValueField(wireName: r'failed')
  int? get failed;

  SystemStatusJobs._();

  factory SystemStatusJobs([void updates(SystemStatusJobsBuilder b)]) =
      _$SystemStatusJobs;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusJobsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatusJobs> get serializer =>
      _$SystemStatusJobsSerializer();
}

class _$SystemStatusJobsSerializer
    implements PrimitiveSerializer<SystemStatusJobs> {
  @override
  final Iterable<Type> types = const [SystemStatusJobs, _$SystemStatusJobs];

  @override
  final String wireName = r'SystemStatusJobs';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatusJobs object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ok';
    yield serializers.serialize(
      object.ok,
      specifiedType: const FullType(bool),
    );
    yield r'in_puma';
    yield object.inPuma == null
        ? null
        : serializers.serialize(
            object.inPuma,
            specifiedType: const FullType.nullable(bool),
          );
    yield r'processes';
    yield object.processes == null
        ? null
        : serializers.serialize(
            object.processes,
            specifiedType: const FullType.nullable(int),
          );
    yield r'ready';
    yield object.ready == null
        ? null
        : serializers.serialize(
            object.ready,
            specifiedType: const FullType.nullable(int),
          );
    yield r'oldest_ready_age_seconds';
    yield object.oldestReadyAgeSeconds == null
        ? null
        : serializers.serialize(
            object.oldestReadyAgeSeconds,
            specifiedType: const FullType.nullable(int),
          );
    yield r'failed';
    yield object.failed == null
        ? null
        : serializers.serialize(
            object.failed,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatusJobs object, {
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
    required SystemStatusJobsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        case r'in_puma':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.inPuma = valueDes;
          break;
        case r'processes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.processes = valueDes;
          break;
        case r'ready':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.ready = valueDes;
          break;
        case r'oldest_ready_age_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.oldestReadyAgeSeconds = valueDes;
          break;
        case r'failed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.failed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatusJobs deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusJobsBuilder();
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
