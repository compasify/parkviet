//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace.dart';
import 'package:pos_api/src/model/kitchen_send_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_send_result.g.dart';

/// KitchenSendResult
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class KitchenSendResult
    implements Built<KitchenSendResult, KitchenSendResultBuilder> {
  @BuiltValueField(wireName: r'data')
  Workspace get data;

  @BuiltValueField(wireName: r'meta')
  KitchenSendMeta get meta;

  KitchenSendResult._();

  factory KitchenSendResult([void updates(KitchenSendResultBuilder b)]) =
      _$KitchenSendResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenSendResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenSendResult> get serializer =>
      _$KitchenSendResultSerializer();
}

class _$KitchenSendResultSerializer
    implements PrimitiveSerializer<KitchenSendResult> {
  @override
  final Iterable<Type> types = const [KitchenSendResult, _$KitchenSendResult];

  @override
  final String wireName = r'KitchenSendResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenSendResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Workspace),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(KitchenSendMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenSendResult object, {
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
    required KitchenSendResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Workspace),
          ) as Workspace;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenSendMeta),
          ) as KitchenSendMeta;
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
  KitchenSendResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenSendResultBuilder();
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
