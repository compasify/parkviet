//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'line_kitchen_status.g.dart';

/// Sent quantity of a table order line by kitchen status; absent statuses have none.
///
/// Properties:
/// * [new_]
/// * [preparing]
/// * [ready]
/// * [served]
@BuiltValue()
abstract class LineKitchenStatus
    implements Built<LineKitchenStatus, LineKitchenStatusBuilder> {
  @BuiltValueField(wireName: r'new')
  String? get new_;

  @BuiltValueField(wireName: r'preparing')
  String? get preparing;

  @BuiltValueField(wireName: r'ready')
  String? get ready;

  @BuiltValueField(wireName: r'served')
  String? get served;

  LineKitchenStatus._();

  factory LineKitchenStatus([void updates(LineKitchenStatusBuilder b)]) =
      _$LineKitchenStatus;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LineKitchenStatusBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LineKitchenStatus> get serializer =>
      _$LineKitchenStatusSerializer();
}

class _$LineKitchenStatusSerializer
    implements PrimitiveSerializer<LineKitchenStatus> {
  @override
  final Iterable<Type> types = const [LineKitchenStatus, _$LineKitchenStatus];

  @override
  final String wireName = r'LineKitchenStatus';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LineKitchenStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.new_ != null) {
      yield r'new';
      yield serializers.serialize(
        object.new_,
        specifiedType: const FullType(String),
      );
    }
    if (object.preparing != null) {
      yield r'preparing';
      yield serializers.serialize(
        object.preparing,
        specifiedType: const FullType(String),
      );
    }
    if (object.ready != null) {
      yield r'ready';
      yield serializers.serialize(
        object.ready,
        specifiedType: const FullType(String),
      );
    }
    if (object.served != null) {
      yield r'served';
      yield serializers.serialize(
        object.served,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LineKitchenStatus object, {
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
    required LineKitchenStatusBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'new':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.new_ = valueDes;
          break;
        case r'preparing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.preparing = valueDes;
          break;
        case r'ready':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ready = valueDes;
          break;
        case r'served':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.served = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LineKitchenStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LineKitchenStatusBuilder();
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
