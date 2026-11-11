//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_held_line.g.dart';

/// KitchenHeldLine
///
/// Properties:
/// * [saleLineId]
/// * [name]
/// * [quantity]
/// * [seat]
@BuiltValue()
abstract class KitchenHeldLine
    implements Built<KitchenHeldLine, KitchenHeldLineBuilder> {
  @BuiltValueField(wireName: r'sale_line_id')
  String get saleLineId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'seat')
  int? get seat;

  KitchenHeldLine._();

  factory KitchenHeldLine([void updates(KitchenHeldLineBuilder b)]) =
      _$KitchenHeldLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenHeldLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenHeldLine> get serializer =>
      _$KitchenHeldLineSerializer();
}

class _$KitchenHeldLineSerializer
    implements PrimitiveSerializer<KitchenHeldLine> {
  @override
  final Iterable<Type> types = const [KitchenHeldLine, _$KitchenHeldLine];

  @override
  final String wireName = r'KitchenHeldLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenHeldLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sale_line_id';
    yield serializers.serialize(
      object.saleLineId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'seat';
    yield object.seat == null
        ? null
        : serializers.serialize(
            object.seat,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenHeldLine object, {
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
    required KitchenHeldLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sale_line_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.saleLineId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quantity = valueDes;
          break;
        case r'seat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.seat = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenHeldLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenHeldLineBuilder();
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
