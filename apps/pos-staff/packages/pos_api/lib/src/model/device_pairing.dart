//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/device_pairing_qr.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_pairing.g.dart';

/// DevicePairing
///
/// Properties:
/// * [id]
/// * [code]
/// * [expiresAt]
/// * [mode]
/// * [qr]
@BuiltValue()
abstract class DevicePairing
    implements Built<DevicePairing, DevicePairingBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'expires_at')
  String get expiresAt;

  @BuiltValueField(wireName: r'mode')
  String get mode;

  @BuiltValueField(wireName: r'qr')
  DevicePairingQr get qr;

  DevicePairing._();

  factory DevicePairing([void updates(DevicePairingBuilder b)]) =
      _$DevicePairing;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DevicePairingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DevicePairing> get serializer =>
      _$DevicePairingSerializer();
}

class _$DevicePairingSerializer implements PrimitiveSerializer<DevicePairing> {
  @override
  final Iterable<Type> types = const [DevicePairing, _$DevicePairing];

  @override
  final String wireName = r'DevicePairing';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DevicePairing object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(String),
    );
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(String),
    );
    yield r'qr';
    yield serializers.serialize(
      object.qr,
      specifiedType: const FullType(DevicePairingQr),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DevicePairing object, {
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
    required DevicePairingBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expiresAt = valueDes;
          break;
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mode = valueDes;
          break;
        case r'qr':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DevicePairingQr),
          ) as DevicePairingQr;
          result.qr.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DevicePairing deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DevicePairingBuilder();
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
