//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/guest_request.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_request_list.g.dart';

/// GuestRequestList
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class GuestRequestList
    implements Built<GuestRequestList, GuestRequestListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<GuestRequest> get data;

  @BuiltValueField(wireName: r'meta')
  BuiltMap<String, JsonObject?> get meta;

  GuestRequestList._();

  factory GuestRequestList([void updates(GuestRequestListBuilder b)]) =
      _$GuestRequestList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestRequestListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestRequestList> get serializer =>
      _$GuestRequestListSerializer();
}

class _$GuestRequestListSerializer
    implements PrimitiveSerializer<GuestRequestList> {
  @override
  final Iterable<Type> types = const [GuestRequestList, _$GuestRequestList];

  @override
  final String wireName = r'GuestRequestList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestRequestList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(GuestRequest)]),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestRequestList object, {
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
    required GuestRequestListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GuestRequest)]),
          ) as BuiltList<GuestRequest>;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GuestRequestList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestRequestListBuilder();
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
