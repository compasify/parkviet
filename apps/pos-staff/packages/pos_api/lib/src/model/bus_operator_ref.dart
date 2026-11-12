//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bus_operator_ref.g.dart';

/// BusOperatorRef
///
/// Properties:
/// * [id]
/// * [name]
@BuiltValue()
abstract class BusOperatorRef
    implements Built<BusOperatorRef, BusOperatorRefBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  BusOperatorRef._();

  factory BusOperatorRef([void updates(BusOperatorRefBuilder b)]) =
      _$BusOperatorRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BusOperatorRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BusOperatorRef> get serializer =>
      _$BusOperatorRefSerializer();
}

class _$BusOperatorRefSerializer
    implements PrimitiveSerializer<BusOperatorRef> {
  @override
  final Iterable<Type> types = const [BusOperatorRef, _$BusOperatorRef];

  @override
  final String wireName = r'BusOperatorRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BusOperatorRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BusOperatorRef object, {
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
    required BusOperatorRefBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  BusOperatorRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BusOperatorRefBuilder();
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
