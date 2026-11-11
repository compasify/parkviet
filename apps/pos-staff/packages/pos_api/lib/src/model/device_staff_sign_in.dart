//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_staff_sign_in.g.dart';

/// DeviceStaffSignIn
///
/// Properties:
/// * [token] - Send as `X-Pos-Staff-Session`. Shown once.
/// * [expiresAt]
/// * [staffId]
/// * [name]
@BuiltValue()
abstract class DeviceStaffSignIn
    implements Built<DeviceStaffSignIn, DeviceStaffSignInBuilder> {
  /// Send as `X-Pos-Staff-Session`. Shown once.
  @BuiltValueField(wireName: r'token')
  String get token;

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'staff_id')
  String get staffId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  DeviceStaffSignIn._();

  factory DeviceStaffSignIn([void updates(DeviceStaffSignInBuilder b)]) =
      _$DeviceStaffSignIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceStaffSignInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceStaffSignIn> get serializer =>
      _$DeviceStaffSignInSerializer();
}

class _$DeviceStaffSignInSerializer
    implements PrimitiveSerializer<DeviceStaffSignIn> {
  @override
  final Iterable<Type> types = const [DeviceStaffSignIn, _$DeviceStaffSignIn];

  @override
  final String wireName = r'DeviceStaffSignIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceStaffSignIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'staff_id';
    yield serializers.serialize(
      object.staffId,
      specifiedType: const FullType(String),
    );
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceStaffSignIn object, {
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
    required DeviceStaffSignInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'staff_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.staffId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceStaffSignIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceStaffSignInBuilder();
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
