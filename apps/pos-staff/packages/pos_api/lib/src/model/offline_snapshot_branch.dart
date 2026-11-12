//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_snapshot_branch.g.dart';

/// OfflineSnapshotBranch
///
/// Properties:
/// * [id]
/// * [name]
/// * [code]
/// * [timezone]
@BuiltValue()
abstract class OfflineSnapshotBranch
    implements Built<OfflineSnapshotBranch, OfflineSnapshotBranchBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  OfflineSnapshotBranch._();

  factory OfflineSnapshotBranch(
      [void updates(OfflineSnapshotBranchBuilder b)]) = _$OfflineSnapshotBranch;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSnapshotBranchBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSnapshotBranch> get serializer =>
      _$OfflineSnapshotBranchSerializer();
}

class _$OfflineSnapshotBranchSerializer
    implements PrimitiveSerializer<OfflineSnapshotBranch> {
  @override
  final Iterable<Type> types = const [
    OfflineSnapshotBranch,
    _$OfflineSnapshotBranch
  ];

  @override
  final String wireName = r'OfflineSnapshotBranch';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSnapshotBranch object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'timezone';
    yield object.timezone == null
        ? null
        : serializers.serialize(
            object.timezone,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSnapshotBranch object, {
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
    required OfflineSnapshotBranchBuilder result,
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
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timezone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSnapshotBranch deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSnapshotBranchBuilder();
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
