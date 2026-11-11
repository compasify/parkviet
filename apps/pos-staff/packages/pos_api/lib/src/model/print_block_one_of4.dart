//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/print_block_one_of4_parties_inner.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_block_one_of4.g.dart';

/// PrintBlockOneOf4
///
/// Properties:
/// * [kind]
/// * [parties]
@BuiltValue()
abstract class PrintBlockOneOf4
    implements Built<PrintBlockOneOf4, PrintBlockOneOf4Builder> {
  @BuiltValueField(wireName: r'kind')
  JsonObject? get kind;

  @BuiltValueField(wireName: r'parties')
  BuiltList<PrintBlockOneOf4PartiesInner> get parties;

  PrintBlockOneOf4._();

  factory PrintBlockOneOf4([void updates(PrintBlockOneOf4Builder b)]) =
      _$PrintBlockOneOf4;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockOneOf4Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlockOneOf4> get serializer =>
      _$PrintBlockOneOf4Serializer();
}

class _$PrintBlockOneOf4Serializer
    implements PrimitiveSerializer<PrintBlockOneOf4> {
  @override
  final Iterable<Type> types = const [PrintBlockOneOf4, _$PrintBlockOneOf4];

  @override
  final String wireName = r'PrintBlockOneOf4';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlockOneOf4 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield object.kind == null
        ? null
        : serializers.serialize(
            object.kind,
            specifiedType: const FullType.nullable(JsonObject),
          );
    yield r'parties';
    yield serializers.serialize(
      object.parties,
      specifiedType:
          const FullType(BuiltList, [FullType(PrintBlockOneOf4PartiesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintBlockOneOf4 object, {
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
    required PrintBlockOneOf4Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'parties':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(PrintBlockOneOf4PartiesInner)]),
          ) as BuiltList<PrintBlockOneOf4PartiesInner>;
          result.parties.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintBlockOneOf4 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockOneOf4Builder();
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
