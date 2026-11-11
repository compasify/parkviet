//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/ready_feed_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ready_feed.g.dart';

/// ReadyFeed
///
/// Properties:
/// * [branchId]
/// * [serverNow]
/// * [areaId]
/// * [items] - Newest first, at most 100.
@BuiltValue()
abstract class ReadyFeed implements Built<ReadyFeed, ReadyFeedBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'server_now')
  DateTime get serverNow;

  @BuiltValueField(wireName: r'area_id')
  String? get areaId;

  /// Newest first, at most 100.
  @BuiltValueField(wireName: r'items')
  BuiltList<ReadyFeedItem> get items;

  ReadyFeed._();

  factory ReadyFeed([void updates(ReadyFeedBuilder b)]) = _$ReadyFeed;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReadyFeedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReadyFeed> get serializer => _$ReadyFeedSerializer();
}

class _$ReadyFeedSerializer implements PrimitiveSerializer<ReadyFeed> {
  @override
  final Iterable<Type> types = const [ReadyFeed, _$ReadyFeed];

  @override
  final String wireName = r'ReadyFeed';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReadyFeed object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'server_now';
    yield serializers.serialize(
      object.serverNow,
      specifiedType: const FullType(DateTime),
    );
    yield r'area_id';
    yield object.areaId == null
        ? null
        : serializers.serialize(
            object.areaId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ReadyFeedItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReadyFeed object, {
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
    required ReadyFeedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'server_now':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.serverNow = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.areaId = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ReadyFeedItem)]),
          ) as BuiltList<ReadyFeedItem>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReadyFeed deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReadyFeedBuilder();
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
