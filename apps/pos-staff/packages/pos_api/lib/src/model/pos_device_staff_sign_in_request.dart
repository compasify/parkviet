//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_staff_sign_in_request.g.dart';

/// PosDeviceStaffSignInRequest
///
/// Properties:
/// * [membershipId]
/// * [pin]
@BuiltValue()
abstract class PosDeviceStaffSignInRequest
    implements
        Built<PosDeviceStaffSignInRequest, PosDeviceStaffSignInRequestBuilder> {
  @BuiltValueField(wireName: r'membership_id')
  String get membershipId;

  @BuiltValueField(wireName: r'pin')
  String get pin;

  PosDeviceStaffSignInRequest._();

  factory PosDeviceStaffSignInRequest(
          [void updates(PosDeviceStaffSignInRequestBuilder b)]) =
      _$PosDeviceStaffSignInRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDeviceStaffSignInRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDeviceStaffSignInRequest> get serializer =>
      _$PosDeviceStaffSignInRequestSerializer();
}

class _$PosDeviceStaffSignInRequestSerializer
    implements PrimitiveSerializer<PosDeviceStaffSignInRequest> {
  @override
  final Iterable<Type> types = const [
    PosDeviceStaffSignInRequest,
    _$PosDeviceStaffSignInRequest
  ];

  @override
  final String wireName = r'PosDeviceStaffSignInRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDeviceStaffSignInRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'membership_id';
    yield serializers.serialize(
      object.membershipId,
      specifiedType: const FullType(String),
    );
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDeviceStaffSignInRequest object, {
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
    required PosDeviceStaffSignInRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'membership_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.membershipId = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosDeviceStaffSignInRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDeviceStaffSignInRequestBuilder();
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
