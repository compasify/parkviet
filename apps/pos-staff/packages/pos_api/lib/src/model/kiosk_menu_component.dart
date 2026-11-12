//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_menu_component.g.dart';

/// KioskMenuComponent
///
/// Properties:
/// * [name]
/// * [quantity]
@BuiltValue()
abstract class KioskMenuComponent
    implements Built<KioskMenuComponent, KioskMenuComponentBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  KioskMenuComponent._();

  factory KioskMenuComponent([void updates(KioskMenuComponentBuilder b)]) =
      _$KioskMenuComponent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskMenuComponentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskMenuComponent> get serializer =>
      _$KioskMenuComponentSerializer();
}

class _$KioskMenuComponentSerializer
    implements PrimitiveSerializer<KioskMenuComponent> {
  @override
  final Iterable<Type> types = const [KioskMenuComponent, _$KioskMenuComponent];

  @override
  final String wireName = r'KioskMenuComponent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskMenuComponent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskMenuComponent object, {
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
    required KioskMenuComponentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskMenuComponent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskMenuComponentBuilder();
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
