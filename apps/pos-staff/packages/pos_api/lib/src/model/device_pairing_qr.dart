//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_pairing_qr.g.dart';

/// DevicePairingQr
///
/// Properties:
/// * [v]
/// * [kind]
/// * [url]
/// * [code]
@BuiltValue()
abstract class DevicePairingQr
    implements Built<DevicePairingQr, DevicePairingQrBuilder> {
  @BuiltValueField(wireName: r'v')
  int get v;

  @BuiltValueField(wireName: r'kind')
  String get kind;

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'code')
  String get code;

  DevicePairingQr._();

  factory DevicePairingQr([void updates(DevicePairingQrBuilder b)]) =
      _$DevicePairingQr;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DevicePairingQrBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DevicePairingQr> get serializer =>
      _$DevicePairingQrSerializer();
}

class _$DevicePairingQrSerializer
    implements PrimitiveSerializer<DevicePairingQr> {
  @override
  final Iterable<Type> types = const [DevicePairingQr, _$DevicePairingQr];

  @override
  final String wireName = r'DevicePairingQr';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DevicePairingQr object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'v';
    yield serializers.serialize(
      object.v,
      specifiedType: const FullType(int),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(String),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DevicePairingQr object, {
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
    required DevicePairingQrBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'v':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.v = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kind = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DevicePairingQr deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DevicePairingQrBuilder();
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
