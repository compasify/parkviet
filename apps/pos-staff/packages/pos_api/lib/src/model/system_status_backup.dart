//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status_backup.g.dart';

/// SystemStatusBackup
///
/// Properties:
/// * [configured] - POS_BACKUP_DIR is set and mounted
/// * [lastAt]
/// * [count]
@BuiltValue()
abstract class SystemStatusBackup
    implements Built<SystemStatusBackup, SystemStatusBackupBuilder> {
  /// POS_BACKUP_DIR is set and mounted
  @BuiltValueField(wireName: r'configured')
  bool get configured;

  @BuiltValueField(wireName: r'last_at')
  DateTime? get lastAt;

  @BuiltValueField(wireName: r'count')
  int get count;

  SystemStatusBackup._();

  factory SystemStatusBackup([void updates(SystemStatusBackupBuilder b)]) =
      _$SystemStatusBackup;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusBackupBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatusBackup> get serializer =>
      _$SystemStatusBackupSerializer();
}

class _$SystemStatusBackupSerializer
    implements PrimitiveSerializer<SystemStatusBackup> {
  @override
  final Iterable<Type> types = const [SystemStatusBackup, _$SystemStatusBackup];

  @override
  final String wireName = r'SystemStatusBackup';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatusBackup object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'configured';
    yield serializers.serialize(
      object.configured,
      specifiedType: const FullType(bool),
    );
    yield r'last_at';
    yield object.lastAt == null
        ? null
        : serializers.serialize(
            object.lastAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatusBackup object, {
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
    required SystemStatusBackupBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'configured':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.configured = valueDes;
          break;
        case r'last_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastAt = valueDes;
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatusBackup deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusBackupBuilder();
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
