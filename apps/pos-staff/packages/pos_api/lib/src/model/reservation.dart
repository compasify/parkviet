//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/reservation_deposit.dart';
import 'package:pos_api/src/model/resource_ref.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation.g.dart';

/// Reservation
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [status]
/// * [source_]
/// * [guestName]
/// * [phone]
/// * [partySize]
/// * [note]
/// * [startsAt]
/// * [endsAt]
/// * [revision] - Approvals to refund or keep a deposit are bound to it.
/// * [customerId]
/// * [workspaceId] - The order the party was seated at.
/// * [confirmedAt] - When the booking was confirmed with the guest.
/// * [seatedAt]
/// * [canceledAt]
/// * [resources]
/// * [deposits]
/// * [depositHeld] - The deposits still held.
/// * [feeWorkspaceId] - Only after a forfeit, the holding-fee sale that kept the deposit.
@BuiltValue()
abstract class Reservation implements Built<Reservation, ReservationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'status')
  ReservationStatusEnum get status;
  // enum statusEnum {  booked,  seated,  completed,  no_show,  canceled,  };

  @BuiltValueField(wireName: r'source')
  ReservationSource_Enum get source_;
  // enum source_Enum {  phone,  walk_in,  online,  };

  @BuiltValueField(wireName: r'guest_name')
  String get guestName;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'party_size')
  int get partySize;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'starts_at')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'ends_at')
  DateTime get endsAt;

  /// Approvals to refund or keep a deposit are bound to it.
  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'customer_id')
  String? get customerId;

  /// The order the party was seated at.
  @BuiltValueField(wireName: r'workspace_id')
  String? get workspaceId;

  /// When the booking was confirmed with the guest.
  @BuiltValueField(wireName: r'confirmed_at')
  DateTime? get confirmedAt;

  @BuiltValueField(wireName: r'seated_at')
  DateTime? get seatedAt;

  @BuiltValueField(wireName: r'canceled_at')
  DateTime? get canceledAt;

  @BuiltValueField(wireName: r'resources')
  BuiltList<ResourceRef> get resources;

  @BuiltValueField(wireName: r'deposits')
  BuiltList<ReservationDeposit> get deposits;

  /// The deposits still held.
  @BuiltValueField(wireName: r'deposit_held')
  String get depositHeld;

  /// Only after a forfeit, the holding-fee sale that kept the deposit.
  @BuiltValueField(wireName: r'fee_workspace_id')
  String? get feeWorkspaceId;

  Reservation._();

  factory Reservation([void updates(ReservationBuilder b)]) = _$Reservation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Reservation> get serializer => _$ReservationSerializer();
}

class _$ReservationSerializer implements PrimitiveSerializer<Reservation> {
  @override
  final Iterable<Type> types = const [Reservation, _$Reservation];

  @override
  final String wireName = r'Reservation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Reservation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReservationStatusEnum),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(ReservationSource_Enum),
    );
    yield r'guest_name';
    yield serializers.serialize(
      object.guestName,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield object.phone == null
        ? null
        : serializers.serialize(
            object.phone,
            specifiedType: const FullType.nullable(String),
          );
    yield r'party_size';
    yield serializers.serialize(
      object.partySize,
      specifiedType: const FullType(int),
    );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
    yield r'starts_at';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ends_at';
    yield serializers.serialize(
      object.endsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'customer_id';
    yield object.customerId == null
        ? null
        : serializers.serialize(
            object.customerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'workspace_id';
    yield object.workspaceId == null
        ? null
        : serializers.serialize(
            object.workspaceId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'confirmed_at';
    yield object.confirmedAt == null
        ? null
        : serializers.serialize(
            object.confirmedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'seated_at';
    yield object.seatedAt == null
        ? null
        : serializers.serialize(
            object.seatedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'canceled_at';
    yield object.canceledAt == null
        ? null
        : serializers.serialize(
            object.canceledAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'resources';
    yield serializers.serialize(
      object.resources,
      specifiedType: const FullType(BuiltList, [FullType(ResourceRef)]),
    );
    yield r'deposits';
    yield serializers.serialize(
      object.deposits,
      specifiedType: const FullType(BuiltList, [FullType(ReservationDeposit)]),
    );
    yield r'deposit_held';
    yield serializers.serialize(
      object.depositHeld,
      specifiedType: const FullType(String),
    );
    if (object.feeWorkspaceId != null) {
      yield r'fee_workspace_id';
      yield serializers.serialize(
        object.feeWorkspaceId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Reservation object, {
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
    required ReservationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationStatusEnum),
          ) as ReservationStatusEnum;
          result.status = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationSource_Enum),
          ) as ReservationSource_Enum;
          result.source_ = valueDes;
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
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
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
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endsAt = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'customer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.customerId = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.workspaceId = valueDes;
          break;
        case r'confirmed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.confirmedAt = valueDes;
          break;
        case r'seated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.seatedAt = valueDes;
          break;
        case r'canceled_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.canceledAt = valueDes;
          break;
        case r'resources':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ResourceRef)]),
          ) as BuiltList<ResourceRef>;
          result.resources.replace(valueDes);
          break;
        case r'deposits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ReservationDeposit)]),
          ) as BuiltList<ReservationDeposit>;
          result.deposits.replace(valueDes);
          break;
        case r'deposit_held':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.depositHeld = valueDes;
          break;
        case r'fee_workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.feeWorkspaceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Reservation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationBuilder();
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

class ReservationStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'booked')
  static const ReservationStatusEnum booked = _$reservationStatusEnum_booked;
  @BuiltValueEnumConst(wireName: r'seated')
  static const ReservationStatusEnum seated = _$reservationStatusEnum_seated;
  @BuiltValueEnumConst(wireName: r'completed')
  static const ReservationStatusEnum completed =
      _$reservationStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'no_show')
  static const ReservationStatusEnum noShow = _$reservationStatusEnum_noShow;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const ReservationStatusEnum canceled =
      _$reservationStatusEnum_canceled;

  static Serializer<ReservationStatusEnum> get serializer =>
      _$reservationStatusEnumSerializer;

  const ReservationStatusEnum._(String name) : super(name);

  static BuiltSet<ReservationStatusEnum> get values =>
      _$reservationStatusEnumValues;
  static ReservationStatusEnum valueOf(String name) =>
      _$reservationStatusEnumValueOf(name);
}

class ReservationSource_Enum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'phone')
  static const ReservationSource_Enum phone = _$reservationSourceEnum_phone;
  @BuiltValueEnumConst(wireName: r'walk_in')
  static const ReservationSource_Enum walkIn = _$reservationSourceEnum_walkIn;
  @BuiltValueEnumConst(wireName: r'online')
  static const ReservationSource_Enum online = _$reservationSourceEnum_online;

  static Serializer<ReservationSource_Enum> get serializer =>
      _$reservationSourceEnumSerializer;

  const ReservationSource_Enum._(String name) : super(name);

  static BuiltSet<ReservationSource_Enum> get values =>
      _$reservationSourceEnumValues;
  static ReservationSource_Enum valueOf(String name) =>
      _$reservationSourceEnumValueOf(name);
}
