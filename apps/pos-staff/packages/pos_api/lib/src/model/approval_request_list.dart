//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/approval_request.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'approval_request_list.g.dart';

/// ApprovalRequestList
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class ApprovalRequestList
    implements Built<ApprovalRequestList, ApprovalRequestListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ApprovalRequest> get data;

  @BuiltValueField(wireName: r'meta')
  BuiltMap<String, JsonObject?> get meta;

  ApprovalRequestList._();

  factory ApprovalRequestList([void updates(ApprovalRequestListBuilder b)]) =
      _$ApprovalRequestList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApprovalRequestListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApprovalRequestList> get serializer =>
      _$ApprovalRequestListSerializer();
}

class _$ApprovalRequestListSerializer
    implements PrimitiveSerializer<ApprovalRequestList> {
  @override
  final Iterable<Type> types = const [
    ApprovalRequestList,
    _$ApprovalRequestList
  ];

  @override
  final String wireName = r'ApprovalRequestList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApprovalRequestList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(ApprovalRequest)]),
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
    ApprovalRequestList object, {
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
    required ApprovalRequestListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ApprovalRequest)]),
          ) as BuiltList<ApprovalRequest>;
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
  ApprovalRequestList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApprovalRequestListBuilder();
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
