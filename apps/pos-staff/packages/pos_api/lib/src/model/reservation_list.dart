//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/reservation_list_meta.dart';
import 'package:pos_api/src/model/reservation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_list.g.dart';

/// ReservationList
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class ReservationList
    implements Built<ReservationList, ReservationListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Reservation> get data;

  @BuiltValueField(wireName: r'meta')
  ReservationListMeta get meta;

  ReservationList._();

  factory ReservationList([void updates(ReservationListBuilder b)]) =
      _$ReservationList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationList> get serializer =>
      _$ReservationListSerializer();
}

class _$ReservationListSerializer
    implements PrimitiveSerializer<ReservationList> {
  @override
  final Iterable<Type> types = const [ReservationList, _$ReservationList];

  @override
  final String wireName = r'ReservationList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Reservation)]),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(ReservationListMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationList object, {
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
    required ReservationListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Reservation)]),
          ) as BuiltList<Reservation>;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationListMeta),
          ) as ReservationListMeta;
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
  ReservationList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationListBuilder();
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
