//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/reservation_deposit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_reservation.g.dart';

/// WorkspaceReservation
///
/// Properties:
/// * [id]
/// * [guestName]
/// * [partySize]
/// * [status]
/// * [revision]
/// * [depositHeld]
/// * [deposits]
@BuiltValue()
abstract class WorkspaceReservation
    implements Built<WorkspaceReservation, WorkspaceReservationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'guest_name')
  String get guestName;

  @BuiltValueField(wireName: r'party_size')
  int get partySize;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'deposit_held')
  String get depositHeld;

  @BuiltValueField(wireName: r'deposits')
  BuiltList<ReservationDeposit> get deposits;

  WorkspaceReservation._();

  factory WorkspaceReservation([void updates(WorkspaceReservationBuilder b)]) =
      _$WorkspaceReservation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceReservationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceReservation> get serializer =>
      _$WorkspaceReservationSerializer();
}

class _$WorkspaceReservationSerializer
    implements PrimitiveSerializer<WorkspaceReservation> {
  @override
  final Iterable<Type> types = const [
    WorkspaceReservation,
    _$WorkspaceReservation
  ];

  @override
  final String wireName = r'WorkspaceReservation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceReservation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'guest_name';
    yield serializers.serialize(
      object.guestName,
      specifiedType: const FullType(String),
    );
    yield r'party_size';
    yield serializers.serialize(
      object.partySize,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'deposit_held';
    yield serializers.serialize(
      object.depositHeld,
      specifiedType: const FullType(String),
    );
    yield r'deposits';
    yield serializers.serialize(
      object.deposits,
      specifiedType: const FullType(BuiltList, [FullType(ReservationDeposit)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceReservation object, {
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
    required WorkspaceReservationBuilder result,
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
        case r'guest_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.guestName = valueDes;
          break;
        case r'party_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.partySize = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'deposit_held':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.depositHeld = valueDes;
          break;
        case r'deposits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ReservationDeposit)]),
          ) as BuiltList<ReservationDeposit>;
          result.deposits.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceReservation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceReservationBuilder();
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
