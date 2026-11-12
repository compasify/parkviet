//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_snapshot_store.g.dart';

/// OfflineSnapshotStore
///
/// Properties:
/// * [id]
/// * [name]
/// * [currency]
/// * [profile]
@BuiltValue()
abstract class OfflineSnapshotStore
    implements Built<OfflineSnapshotStore, OfflineSnapshotStoreBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'profile')
  BuiltMap<String, String?> get profile;

  OfflineSnapshotStore._();

  factory OfflineSnapshotStore([void updates(OfflineSnapshotStoreBuilder b)]) =
      _$OfflineSnapshotStore;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSnapshotStoreBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSnapshotStore> get serializer =>
      _$OfflineSnapshotStoreSerializer();
}

class _$OfflineSnapshotStoreSerializer
    implements PrimitiveSerializer<OfflineSnapshotStore> {
  @override
  final Iterable<Type> types = const [
    OfflineSnapshotStore,
    _$OfflineSnapshotStore
  ];

  @override
  final String wireName = r'OfflineSnapshotStore';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSnapshotStore object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null
        ? null
        : serializers.serialize(
            object.name,
            specifiedType: const FullType.nullable(String),
          );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'profile';
    yield serializers.serialize(
      object.profile,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSnapshotStore object, {
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
    required OfflineSnapshotStoreBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'profile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(String)]),
          ) as BuiltMap<String, String?>;
          result.profile.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSnapshotStore deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSnapshotStoreBuilder();
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
