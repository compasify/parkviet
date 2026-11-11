//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_history_entry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_history.g.dart';

/// KitchenHistory
///
/// Properties:
/// * [workspaceId]
/// * [entries]
@BuiltValue()
abstract class KitchenHistory
    implements Built<KitchenHistory, KitchenHistoryBuilder> {
  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'entries')
  BuiltList<KitchenHistoryEntry> get entries;

  KitchenHistory._();

  factory KitchenHistory([void updates(KitchenHistoryBuilder b)]) =
      _$KitchenHistory;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenHistoryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenHistory> get serializer =>
      _$KitchenHistorySerializer();
}

class _$KitchenHistorySerializer
    implements PrimitiveSerializer<KitchenHistory> {
  @override
  final Iterable<Type> types = const [KitchenHistory, _$KitchenHistory];

  @override
  final String wireName = r'KitchenHistory';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenHistory object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'entries';
    yield serializers.serialize(
      object.entries,
      specifiedType: const FullType(BuiltList, [FullType(KitchenHistoryEntry)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenHistory object, {
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
    required KitchenHistoryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(KitchenHistoryEntry)]),
          ) as BuiltList<KitchenHistoryEntry>;
          result.entries.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenHistory deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenHistoryBuilder();
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
