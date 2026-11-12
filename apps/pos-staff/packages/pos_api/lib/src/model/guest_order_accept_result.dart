//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/guest_order_accept_meta.dart';
import 'package:pos_api/src/model/guest_order.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_order_accept_result.g.dart';

/// GuestOrderAcceptResult
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class GuestOrderAcceptResult
    implements Built<GuestOrderAcceptResult, GuestOrderAcceptResultBuilder> {
  @BuiltValueField(wireName: r'data')
  GuestOrder get data;

  @BuiltValueField(wireName: r'meta')
  GuestOrderAcceptMeta get meta;

  GuestOrderAcceptResult._();

  factory GuestOrderAcceptResult(
          [void updates(GuestOrderAcceptResultBuilder b)]) =
      _$GuestOrderAcceptResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestOrderAcceptResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestOrderAcceptResult> get serializer =>
      _$GuestOrderAcceptResultSerializer();
}

class _$GuestOrderAcceptResultSerializer
    implements PrimitiveSerializer<GuestOrderAcceptResult> {
  @override
  final Iterable<Type> types = const [
    GuestOrderAcceptResult,
    _$GuestOrderAcceptResult
  ];

  @override
  final String wireName = r'GuestOrderAcceptResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestOrderAcceptResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(GuestOrder),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(GuestOrderAcceptMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestOrderAcceptResult object, {
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
    required GuestOrderAcceptResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GuestOrder),
          ) as GuestOrder;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GuestOrderAcceptMeta),
          ) as GuestOrderAcceptMeta;
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
  GuestOrderAcceptResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestOrderAcceptResultBuilder();
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
