//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_pins.g.dart';

/// TablePins
///
/// Properties:
/// * [pinned] - Tables the device follows.
/// * [serving] - Tables with an open order the signed-in person added to.
@BuiltValue()
abstract class TablePins implements Built<TablePins, TablePinsBuilder> {
  /// Tables the device follows.
  @BuiltValueField(wireName: r'pinned')
  BuiltList<String> get pinned;

  /// Tables with an open order the signed-in person added to.
  @BuiltValueField(wireName: r'serving')
  BuiltList<String> get serving;

  TablePins._();

  factory TablePins([void updates(TablePinsBuilder b)]) = _$TablePins;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TablePinsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TablePins> get serializer => _$TablePinsSerializer();
}

class _$TablePinsSerializer implements PrimitiveSerializer<TablePins> {
  @override
  final Iterable<Type> types = const [TablePins, _$TablePins];

  @override
  final String wireName = r'TablePins';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TablePins object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pinned';
    yield serializers.serialize(
      object.pinned,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'serving';
    yield serializers.serialize(
      object.serving,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TablePins object, {
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
    required TablePinsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pinned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.pinned.replace(valueDes);
          break;
        case r'serving':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.serving.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TablePins deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TablePinsBuilder();
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
