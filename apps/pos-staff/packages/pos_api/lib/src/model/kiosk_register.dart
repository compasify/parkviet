//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kiosk_device_ref.dart';
import 'package:pos_api/src/model/kiosk_shift_ref.dart';
import 'package:pos_api/src/model/kiosk_register_ref.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_register.g.dart';

/// KioskRegister
///
/// Properties:
/// * [register]
/// * [device]
/// * [provisioned] - A device is paired and its service account active.
/// * [shift]
/// * [waitingOrders] - Orders left for the counter on this kiosk.
@BuiltValue()
abstract class KioskRegister
    implements Built<KioskRegister, KioskRegisterBuilder> {
  @BuiltValueField(wireName: r'register')
  KioskRegisterRef get register;

  @BuiltValueField(wireName: r'device')
  KioskDeviceRef? get device;

  /// A device is paired and its service account active.
  @BuiltValueField(wireName: r'provisioned')
  bool get provisioned;

  @BuiltValueField(wireName: r'shift')
  KioskShiftRef? get shift;

  /// Orders left for the counter on this kiosk.
  @BuiltValueField(wireName: r'waiting_orders')
  int get waitingOrders;

  KioskRegister._();

  factory KioskRegister([void updates(KioskRegisterBuilder b)]) =
      _$KioskRegister;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskRegisterBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskRegister> get serializer =>
      _$KioskRegisterSerializer();
}

class _$KioskRegisterSerializer implements PrimitiveSerializer<KioskRegister> {
  @override
  final Iterable<Type> types = const [KioskRegister, _$KioskRegister];

  @override
  final String wireName = r'KioskRegister';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskRegister object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'register';
    yield serializers.serialize(
      object.register,
      specifiedType: const FullType(KioskRegisterRef),
    );
    yield r'device';
    yield object.device == null
        ? null
        : serializers.serialize(
            object.device,
            specifiedType: const FullType.nullable(KioskDeviceRef),
          );
    yield r'provisioned';
    yield serializers.serialize(
      object.provisioned,
      specifiedType: const FullType(bool),
    );
    yield r'shift';
    yield object.shift == null
        ? null
        : serializers.serialize(
            object.shift,
            specifiedType: const FullType.nullable(KioskShiftRef),
          );
    yield r'waiting_orders';
    yield serializers.serialize(
      object.waitingOrders,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskRegister object, {
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
    required KioskRegisterBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'register':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskRegisterRef),
          ) as KioskRegisterRef;
          result.register.replace(valueDes);
          break;
        case r'device':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KioskDeviceRef),
          ) as KioskDeviceRef?;
          if (valueDes == null) continue;
          result.device.replace(valueDes);
          break;
        case r'provisioned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.provisioned = valueDes;
          break;
        case r'shift':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KioskShiftRef),
          ) as KioskShiftRef?;
          if (valueDes == null) continue;
          result.shift.replace(valueDes);
          break;
        case r'waiting_orders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.waitingOrders = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskRegister deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskRegisterBuilder();
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
