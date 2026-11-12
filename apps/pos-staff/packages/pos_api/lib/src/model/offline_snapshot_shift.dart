//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_snapshot_shift.g.dart';

/// OfflineSnapshotShift
///
/// Properties:
/// * [id]
/// * [openedAt]
@BuiltValue()
abstract class OfflineSnapshotShift
    implements Built<OfflineSnapshotShift, OfflineSnapshotShiftBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'opened_at')
  DateTime? get openedAt;

  OfflineSnapshotShift._();

  factory OfflineSnapshotShift([void updates(OfflineSnapshotShiftBuilder b)]) =
      _$OfflineSnapshotShift;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSnapshotShiftBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSnapshotShift> get serializer =>
      _$OfflineSnapshotShiftSerializer();
}

class _$OfflineSnapshotShiftSerializer
    implements PrimitiveSerializer<OfflineSnapshotShift> {
  @override
  final Iterable<Type> types = const [
    OfflineSnapshotShift,
    _$OfflineSnapshotShift
  ];

  @override
  final String wireName = r'OfflineSnapshotShift';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSnapshotShift object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'opened_at';
    yield object.openedAt == null
        ? null
        : serializers.serialize(
            object.openedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSnapshotShift object, {
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
    required OfflineSnapshotShiftBuilder result,
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
        case r'opened_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.openedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSnapshotShift deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSnapshotShiftBuilder();
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
