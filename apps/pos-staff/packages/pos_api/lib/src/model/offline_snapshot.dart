//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/offline_snapshot_branch.dart';
import 'package:pos_api/src/model/menu.dart';
import 'package:pos_api/src/model/offline_snapshot_staff.dart';
import 'package:pos_api/src/model/offline_snapshot_offline.dart';
import 'package:pos_api/src/model/offline_snapshot_register.dart';
import 'package:pos_api/src/model/offline_snapshot_store.dart';
import 'package:pos_api/src/model/offline_snapshot_shift.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_snapshot.g.dart';

/// OfflineSnapshot
///
/// Properties:
/// * [store]
/// * [branch]
/// * [register]
/// * [staff]
/// * [shift]
/// * [offline]
/// * [menu]
/// * [etag]
/// * [generatedAt]
/// * [maxAgeSeconds] - How long a counter may sell from this snapshot without the server.
@BuiltValue()
abstract class OfflineSnapshot
    implements Built<OfflineSnapshot, OfflineSnapshotBuilder> {
  @BuiltValueField(wireName: r'store')
  OfflineSnapshotStore get store;

  @BuiltValueField(wireName: r'branch')
  OfflineSnapshotBranch get branch;

  @BuiltValueField(wireName: r'register')
  OfflineSnapshotRegister get register;

  @BuiltValueField(wireName: r'staff')
  OfflineSnapshotStaff get staff;

  @BuiltValueField(wireName: r'shift')
  OfflineSnapshotShift? get shift;

  @BuiltValueField(wireName: r'offline')
  OfflineSnapshotOffline get offline;

  @BuiltValueField(wireName: r'menu')
  Menu? get menu;

  @BuiltValueField(wireName: r'etag')
  String get etag;

  @BuiltValueField(wireName: r'generated_at')
  DateTime get generatedAt;

  /// How long a counter may sell from this snapshot without the server.
  @BuiltValueField(wireName: r'max_age_seconds')
  int get maxAgeSeconds;

  OfflineSnapshot._();

  factory OfflineSnapshot([void updates(OfflineSnapshotBuilder b)]) =
      _$OfflineSnapshot;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSnapshotBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSnapshot> get serializer =>
      _$OfflineSnapshotSerializer();
}

class _$OfflineSnapshotSerializer
    implements PrimitiveSerializer<OfflineSnapshot> {
  @override
  final Iterable<Type> types = const [OfflineSnapshot, _$OfflineSnapshot];

  @override
  final String wireName = r'OfflineSnapshot';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSnapshot object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'store';
    yield serializers.serialize(
      object.store,
      specifiedType: const FullType(OfflineSnapshotStore),
    );
    yield r'branch';
    yield serializers.serialize(
      object.branch,
      specifiedType: const FullType(OfflineSnapshotBranch),
    );
    yield r'register';
    yield serializers.serialize(
      object.register,
      specifiedType: const FullType(OfflineSnapshotRegister),
    );
    yield r'staff';
    yield serializers.serialize(
      object.staff,
      specifiedType: const FullType(OfflineSnapshotStaff),
    );
    yield r'shift';
    yield object.shift == null
        ? null
        : serializers.serialize(
            object.shift,
            specifiedType: const FullType.nullable(OfflineSnapshotShift),
          );
    yield r'offline';
    yield serializers.serialize(
      object.offline,
      specifiedType: const FullType(OfflineSnapshotOffline),
    );
    yield r'menu';
    yield object.menu == null
        ? null
        : serializers.serialize(
            object.menu,
            specifiedType: const FullType.nullable(Menu),
          );
    yield r'etag';
    yield serializers.serialize(
      object.etag,
      specifiedType: const FullType(String),
    );
    yield r'generated_at';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'max_age_seconds';
    yield serializers.serialize(
      object.maxAgeSeconds,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSnapshot object, {
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
    required OfflineSnapshotBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'store':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSnapshotStore),
          ) as OfflineSnapshotStore;
          result.store.replace(valueDes);
          break;
        case r'branch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSnapshotBranch),
          ) as OfflineSnapshotBranch;
          result.branch.replace(valueDes);
          break;
        case r'register':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSnapshotRegister),
          ) as OfflineSnapshotRegister;
          result.register.replace(valueDes);
          break;
        case r'staff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSnapshotStaff),
          ) as OfflineSnapshotStaff;
          result.staff.replace(valueDes);
          break;
        case r'shift':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OfflineSnapshotShift),
          ) as OfflineSnapshotShift?;
          if (valueDes == null) continue;
          result.shift.replace(valueDes);
          break;
        case r'offline':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSnapshotOffline),
          ) as OfflineSnapshotOffline;
          result.offline.replace(valueDes);
          break;
        case r'menu':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Menu),
          ) as Menu?;
          if (valueDes == null) continue;
          result.menu.replace(valueDes);
          break;
        case r'etag':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.etag = valueDes;
          break;
        case r'generated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'max_age_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxAgeSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSnapshot deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSnapshotBuilder();
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
