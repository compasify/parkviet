//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_shift_ref.g.dart';

/// KioskShiftRef
///
/// Properties:
/// * [id]
/// * [openedAt]
/// * [businessDate]
@BuiltValue()
abstract class KioskShiftRef
    implements Built<KioskShiftRef, KioskShiftRefBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'opened_at')
  String? get openedAt;

  @BuiltValueField(wireName: r'business_date')
  String? get businessDate;

  KioskShiftRef._();

  factory KioskShiftRef([void updates(KioskShiftRefBuilder b)]) =
      _$KioskShiftRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskShiftRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskShiftRef> get serializer =>
      _$KioskShiftRefSerializer();
}

class _$KioskShiftRefSerializer implements PrimitiveSerializer<KioskShiftRef> {
  @override
  final Iterable<Type> types = const [KioskShiftRef, _$KioskShiftRef];

  @override
  final String wireName = r'KioskShiftRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskShiftRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'opened_at';
    yield object.openedAt == null
        ? null
        : serializers.serialize(
            object.openedAt,
            specifiedType: const FullType.nullable(String),
          );
    yield r'business_date';
    yield object.businessDate == null
        ? null
        : serializers.serialize(
            object.businessDate,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskShiftRef object, {
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
    required KioskShiftRefBuilder result,
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
        case r'opened_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.openedAt = valueDes;
          break;
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.businessDate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskShiftRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskShiftRefBuilder();
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
