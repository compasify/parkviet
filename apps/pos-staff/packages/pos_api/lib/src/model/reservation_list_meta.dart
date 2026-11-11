//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_list_meta.g.dart';

/// ReservationListMeta
///
/// Properties:
/// * [from]
/// * [to]
@BuiltValue()
abstract class ReservationListMeta
    implements Built<ReservationListMeta, ReservationListMetaBuilder> {
  @BuiltValueField(wireName: r'from')
  DateTime get from;

  @BuiltValueField(wireName: r'to')
  DateTime get to;

  ReservationListMeta._();

  factory ReservationListMeta([void updates(ReservationListMetaBuilder b)]) =
      _$ReservationListMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationListMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationListMeta> get serializer =>
      _$ReservationListMetaSerializer();
}

class _$ReservationListMetaSerializer
    implements PrimitiveSerializer<ReservationListMeta> {
  @override
  final Iterable<Type> types = const [
    ReservationListMeta,
    _$ReservationListMeta
  ];

  @override
  final String wireName = r'ReservationListMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationListMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'from';
    yield serializers.serialize(
      object.from,
      specifiedType: const FullType(DateTime),
    );
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationListMeta object, {
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
    required ReservationListMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.from = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.to = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationListMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationListMetaBuilder();
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
