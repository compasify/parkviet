//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_order_accept_meta.g.dart';

/// GuestOrderAcceptMeta
///
/// Properties:
/// * [workspace]
/// * [kitchenTicketCount]
@BuiltValue()
abstract class GuestOrderAcceptMeta
    implements Built<GuestOrderAcceptMeta, GuestOrderAcceptMetaBuilder> {
  @BuiltValueField(wireName: r'workspace')
  Workspace? get workspace;

  @BuiltValueField(wireName: r'kitchen_ticket_count')
  int? get kitchenTicketCount;

  GuestOrderAcceptMeta._();

  factory GuestOrderAcceptMeta([void updates(GuestOrderAcceptMetaBuilder b)]) =
      _$GuestOrderAcceptMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestOrderAcceptMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestOrderAcceptMeta> get serializer =>
      _$GuestOrderAcceptMetaSerializer();
}

class _$GuestOrderAcceptMetaSerializer
    implements PrimitiveSerializer<GuestOrderAcceptMeta> {
  @override
  final Iterable<Type> types = const [
    GuestOrderAcceptMeta,
    _$GuestOrderAcceptMeta
  ];

  @override
  final String wireName = r'GuestOrderAcceptMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestOrderAcceptMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.workspace != null) {
      yield r'workspace';
      yield serializers.serialize(
        object.workspace,
        specifiedType: const FullType(Workspace),
      );
    }
    if (object.kitchenTicketCount != null) {
      yield r'kitchen_ticket_count';
      yield serializers.serialize(
        object.kitchenTicketCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestOrderAcceptMeta object, {
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
    required GuestOrderAcceptMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Workspace),
          ) as Workspace?;
          if (valueDes == null) continue;
          result.workspace.replace(valueDes);
          break;
        case r'kitchen_ticket_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.kitchenTicketCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GuestOrderAcceptMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestOrderAcceptMetaBuilder();
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
