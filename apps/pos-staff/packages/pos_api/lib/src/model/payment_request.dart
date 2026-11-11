//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_request.g.dart';

/// PaymentRequest
///
/// Properties:
/// * [id]
/// * [status]
/// * [note]
/// * [requestedById]
/// * [requestedAt]
/// * [resolvedAt]
@BuiltValue()
abstract class PaymentRequest
    implements Built<PaymentRequest, PaymentRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  PaymentRequestStatusEnum get status;
  // enum statusEnum {  open,  done,  canceled,  };

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'requested_by_id')
  String get requestedById;

  @BuiltValueField(wireName: r'requested_at')
  DateTime get requestedAt;

  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  PaymentRequest._();

  factory PaymentRequest([void updates(PaymentRequestBuilder b)]) =
      _$PaymentRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentRequest> get serializer =>
      _$PaymentRequestSerializer();
}

class _$PaymentRequestSerializer
    implements PrimitiveSerializer<PaymentRequest> {
  @override
  final Iterable<Type> types = const [PaymentRequest, _$PaymentRequest];

  @override
  final String wireName = r'PaymentRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PaymentRequestStatusEnum),
    );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
    yield r'requested_by_id';
    yield serializers.serialize(
      object.requestedById,
      specifiedType: const FullType(String),
    );
    yield r'requested_at';
    yield serializers.serialize(
      object.requestedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'resolved_at';
    yield object.resolvedAt == null
        ? null
        : serializers.serialize(
            object.resolvedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentRequest object, {
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
    required PaymentRequestBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentRequestStatusEnum),
          ) as PaymentRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'requested_by_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestedById = valueDes;
          break;
        case r'requested_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.requestedAt = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentRequestBuilder();
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

class PaymentRequestStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const PaymentRequestStatusEnum open = _$paymentRequestStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'done')
  static const PaymentRequestStatusEnum done = _$paymentRequestStatusEnum_done;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const PaymentRequestStatusEnum canceled =
      _$paymentRequestStatusEnum_canceled;

  static Serializer<PaymentRequestStatusEnum> get serializer =>
      _$paymentRequestStatusEnumSerializer;

  const PaymentRequestStatusEnum._(String name) : super(name);

  static BuiltSet<PaymentRequestStatusEnum> get values =>
      _$paymentRequestStatusEnumValues;
  static PaymentRequestStatusEnum valueOf(String name) =>
      _$paymentRequestStatusEnumValueOf(name);
}
