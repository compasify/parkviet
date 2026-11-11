//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'context_administration.g.dart';

/// ContextAdministration
///
/// Properties:
/// * [read]
/// * [write]
@BuiltValue()
abstract class ContextAdministration
    implements Built<ContextAdministration, ContextAdministrationBuilder> {
  @BuiltValueField(wireName: r'read')
  bool get read;

  @BuiltValueField(wireName: r'write')
  bool get write;

  ContextAdministration._();

  factory ContextAdministration(
      [void updates(ContextAdministrationBuilder b)]) = _$ContextAdministration;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContextAdministrationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ContextAdministration> get serializer =>
      _$ContextAdministrationSerializer();
}

class _$ContextAdministrationSerializer
    implements PrimitiveSerializer<ContextAdministration> {
  @override
  final Iterable<Type> types = const [
    ContextAdministration,
    _$ContextAdministration
  ];

  @override
  final String wireName = r'ContextAdministration';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContextAdministration object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'read';
    yield serializers.serialize(
      object.read,
      specifiedType: const FullType(bool),
    );
    yield r'write';
    yield serializers.serialize(
      object.write,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ContextAdministration object, {
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
    required ContextAdministrationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'read':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.read = valueDes;
          break;
        case r'write':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.write = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ContextAdministration deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContextAdministrationBuilder();
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
