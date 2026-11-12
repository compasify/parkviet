//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_shift_closure.g.dart';

/// The closure of the kiosk's shift on a zero count.
///
/// Properties:
/// * [id]
@BuiltValue()
abstract class KioskShiftClosure
    implements Built<KioskShiftClosure, KioskShiftClosureBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  KioskShiftClosure._();

  factory KioskShiftClosure([void updates(KioskShiftClosureBuilder b)]) =
      _$KioskShiftClosure;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskShiftClosureBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskShiftClosure> get serializer =>
      _$KioskShiftClosureSerializer();
}

class _$KioskShiftClosureSerializer
    implements PrimitiveSerializer<KioskShiftClosure> {
  @override
  final Iterable<Type> types = const [KioskShiftClosure, _$KioskShiftClosure];

  @override
  final String wireName = r'KioskShiftClosure';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskShiftClosure object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskShiftClosure object, {
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
    required KioskShiftClosureBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskShiftClosure deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskShiftClosureBuilder();
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
