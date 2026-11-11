//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/system_status_printing.dart';
import 'package:pos_api/src/model/system_status_outbound.dart';
import 'package:pos_api/src/model/system_status_database.dart';
import 'package:pos_api/src/model/system_status_jobs.dart';
import 'package:pos_api/src/model/system_status_server.dart';
import 'package:pos_api/src/model/system_status_realtime.dart';
import 'package:pos_api/src/model/system_status_vietqr.dart';
import 'package:pos_api/src/model/system_status_backup.dart';
import 'package:pos_api/src/model/system_status_version.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status.g.dart';

/// SystemStatus
///
/// Properties:
/// * [generatedAt]
/// * [version]
/// * [server]
/// * [database]
/// * [jobs]
/// * [realtime]
/// * [printing]
/// * [outbound]
/// * [vietqr]
/// * [backup]
@BuiltValue()
abstract class SystemStatus
    implements Built<SystemStatus, SystemStatusBuilder> {
  @BuiltValueField(wireName: r'generated_at')
  DateTime get generatedAt;

  @BuiltValueField(wireName: r'version')
  SystemStatusVersion get version;

  @BuiltValueField(wireName: r'server')
  SystemStatusServer get server;

  @BuiltValueField(wireName: r'database')
  SystemStatusDatabase get database;

  @BuiltValueField(wireName: r'jobs')
  SystemStatusJobs get jobs;

  @BuiltValueField(wireName: r'realtime')
  SystemStatusRealtime get realtime;

  @BuiltValueField(wireName: r'printing')
  SystemStatusPrinting get printing;

  @BuiltValueField(wireName: r'outbound')
  SystemStatusOutbound get outbound;

  @BuiltValueField(wireName: r'vietqr')
  SystemStatusVietqr get vietqr;

  @BuiltValueField(wireName: r'backup')
  SystemStatusBackup get backup;

  SystemStatus._();

  factory SystemStatus([void updates(SystemStatusBuilder b)]) = _$SystemStatus;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatus> get serializer => _$SystemStatusSerializer();
}

class _$SystemStatusSerializer implements PrimitiveSerializer<SystemStatus> {
  @override
  final Iterable<Type> types = const [SystemStatus, _$SystemStatus];

  @override
  final String wireName = r'SystemStatus';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'generated_at';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(SystemStatusVersion),
    );
    yield r'server';
    yield serializers.serialize(
      object.server,
      specifiedType: const FullType(SystemStatusServer),
    );
    yield r'database';
    yield serializers.serialize(
      object.database,
      specifiedType: const FullType(SystemStatusDatabase),
    );
    yield r'jobs';
    yield serializers.serialize(
      object.jobs,
      specifiedType: const FullType(SystemStatusJobs),
    );
    yield r'realtime';
    yield serializers.serialize(
      object.realtime,
      specifiedType: const FullType(SystemStatusRealtime),
    );
    yield r'printing';
    yield serializers.serialize(
      object.printing,
      specifiedType: const FullType(SystemStatusPrinting),
    );
    yield r'outbound';
    yield serializers.serialize(
      object.outbound,
      specifiedType: const FullType(SystemStatusOutbound),
    );
    yield r'vietqr';
    yield serializers.serialize(
      object.vietqr,
      specifiedType: const FullType(SystemStatusVietqr),
    );
    yield r'backup';
    yield serializers.serialize(
      object.backup,
      specifiedType: const FullType(SystemStatusBackup),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatus object, {
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
    required SystemStatusBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'generated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusVersion),
          ) as SystemStatusVersion;
          result.version.replace(valueDes);
          break;
        case r'server':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusServer),
          ) as SystemStatusServer;
          result.server.replace(valueDes);
          break;
        case r'database':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusDatabase),
          ) as SystemStatusDatabase;
          result.database.replace(valueDes);
          break;
        case r'jobs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusJobs),
          ) as SystemStatusJobs;
          result.jobs.replace(valueDes);
          break;
        case r'realtime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusRealtime),
          ) as SystemStatusRealtime;
          result.realtime.replace(valueDes);
          break;
        case r'printing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusPrinting),
          ) as SystemStatusPrinting;
          result.printing.replace(valueDes);
          break;
        case r'outbound':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusOutbound),
          ) as SystemStatusOutbound;
          result.outbound.replace(valueDes);
          break;
        case r'vietqr':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusVietqr),
          ) as SystemStatusVietqr;
          result.vietqr.replace(valueDes);
          break;
        case r'backup':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemStatusBackup),
          ) as SystemStatusBackup;
          result.backup.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusBuilder();
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
