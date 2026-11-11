//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/table_pins.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_pins_result.g.dart';

/// TablePinsResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class TablePinsResult
    implements Built<TablePinsResult, TablePinsResultBuilder> {
  @BuiltValueField(wireName: r'data')
  TablePins get data;

  TablePinsResult._();

  factory TablePinsResult([void updates(TablePinsResultBuilder b)]) =
      _$TablePinsResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TablePinsResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TablePinsResult> get serializer =>
      _$TablePinsResultSerializer();
}

class _$TablePinsResultSerializer
    implements PrimitiveSerializer<TablePinsResult> {
  @override
  final Iterable<Type> types = const [TablePinsResult, _$TablePinsResult];

  @override
  final String wireName = r'TablePinsResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TablePinsResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TablePins),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TablePinsResult object, {
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
    required TablePinsResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TablePins),
          ) as TablePins;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TablePinsResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TablePinsResultBuilder();
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
