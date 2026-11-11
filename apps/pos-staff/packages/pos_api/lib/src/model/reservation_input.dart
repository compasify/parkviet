//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_input.g.dart';

/// ReservationInput
///
/// Properties:
/// * [branchId]
/// * [resourceIds]
/// * [guestName]
/// * [phone]
/// * [partySize]
/// * [startsAt]
/// * [endsAt]
/// * [source_]
/// * [note]
/// * [customerId]
@BuiltValue()
abstract class ReservationInput
    implements Built<ReservationInput, ReservationInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'resource_ids')
  BuiltList<String> get resourceIds;

  @BuiltValueField(wireName: r'guest_name')
  String get guestName;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'party_size')
  int get partySize;

  @BuiltValueField(wireName: r'starts_at')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'ends_at')
  DateTime? get endsAt;

  @BuiltValueField(wireName: r'source')
  ReservationInputSource_Enum? get source_;
  // enum source_Enum {  phone,  walk_in,  online,  };

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'customer_id')
  String? get customerId;

  ReservationInput._();

  factory ReservationInput([void updates(ReservationInputBuilder b)]) =
      _$ReservationInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationInput> get serializer =>
      _$ReservationInputSerializer();
}

class _$ReservationInputSerializer
    implements PrimitiveSerializer<ReservationInput> {
  @override
  final Iterable<Type> types = const [ReservationInput, _$ReservationInput];

  @override
  final String wireName = r'ReservationInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'resource_ids';
    yield serializers.serialize(
      object.resourceIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'guest_name';
    yield serializers.serialize(
      object.guestName,
      specifiedType: const FullType(String),
    );
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(String),
      );
    }
    yield r'party_size';
    yield serializers.serialize(
      object.partySize,
      specifiedType: const FullType(int),
    );
    yield r'starts_at';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.endsAt != null) {
      yield r'ends_at';
      yield serializers.serialize(
        object.endsAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(ReservationInputSource_Enum),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.customerId != null) {
      yield r'customer_id';
      yield serializers.serialize(
        object.customerId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationInput object, {
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
    required ReservationInputBuilder result,
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
        case r'resource_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.resourceIds.replace(valueDes);
          break;
        case r'guest_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.guestName = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'party_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.partySize = valueDes;
          break;
        case r'starts_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startsAt = valueDes;
          break;
        case r'ends_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endsAt = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReservationInputSource_Enum),
          ) as ReservationInputSource_Enum?;
          if (valueDes == null) continue;
          result.source_ = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'customer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.customerId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationInputBuilder();
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

class ReservationInputSource_Enum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'phone')
  static const ReservationInputSource_Enum phone =
      _$reservationInputSourceEnum_phone;
  @BuiltValueEnumConst(wireName: r'walk_in')
  static const ReservationInputSource_Enum walkIn =
      _$reservationInputSourceEnum_walkIn;
  @BuiltValueEnumConst(wireName: r'online')
  static const ReservationInputSource_Enum online =
      _$reservationInputSourceEnum_online;

  static Serializer<ReservationInputSource_Enum> get serializer =>
      _$reservationInputSourceEnumSerializer;

  const ReservationInputSource_Enum._(String name) : super(name);

  static BuiltSet<ReservationInputSource_Enum> get values =>
      _$reservationInputSourceEnumValues;
  static ReservationInputSource_Enum valueOf(String name) =>
      _$reservationInputSourceEnumValueOf(name);
}
