//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_block_one_of4_parties_inner.g.dart';

/// PrintBlockOneOf4PartiesInner
///
/// Properties:
/// * [party]
/// * [label]
@BuiltValue()
abstract class PrintBlockOneOf4PartiesInner
    implements
        Built<PrintBlockOneOf4PartiesInner,
            PrintBlockOneOf4PartiesInnerBuilder> {
  @BuiltValueField(wireName: r'party')
  PrintBlockOneOf4PartiesInnerPartyEnum get party;
  // enum partyEnum {  buyer,  seller,  cashier,  };

  @BuiltValueField(wireName: r'label')
  String get label;

  PrintBlockOneOf4PartiesInner._();

  factory PrintBlockOneOf4PartiesInner(
          [void updates(PrintBlockOneOf4PartiesInnerBuilder b)]) =
      _$PrintBlockOneOf4PartiesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintBlockOneOf4PartiesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintBlockOneOf4PartiesInner> get serializer =>
      _$PrintBlockOneOf4PartiesInnerSerializer();
}

class _$PrintBlockOneOf4PartiesInnerSerializer
    implements PrimitiveSerializer<PrintBlockOneOf4PartiesInner> {
  @override
  final Iterable<Type> types = const [
    PrintBlockOneOf4PartiesInner,
    _$PrintBlockOneOf4PartiesInner
  ];

  @override
  final String wireName = r'PrintBlockOneOf4PartiesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintBlockOneOf4PartiesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'party';
    yield serializers.serialize(
      object.party,
      specifiedType: const FullType(PrintBlockOneOf4PartiesInnerPartyEnum),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintBlockOneOf4PartiesInner object, {
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
    required PrintBlockOneOf4PartiesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'party':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PrintBlockOneOf4PartiesInnerPartyEnum),
          ) as PrintBlockOneOf4PartiesInnerPartyEnum;
          result.party = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintBlockOneOf4PartiesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintBlockOneOf4PartiesInnerBuilder();
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

class PrintBlockOneOf4PartiesInnerPartyEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'buyer')
  static const PrintBlockOneOf4PartiesInnerPartyEnum buyer =
      _$printBlockOneOf4PartiesInnerPartyEnum_buyer;
  @BuiltValueEnumConst(wireName: r'seller')
  static const PrintBlockOneOf4PartiesInnerPartyEnum seller =
      _$printBlockOneOf4PartiesInnerPartyEnum_seller;
  @BuiltValueEnumConst(wireName: r'cashier')
  static const PrintBlockOneOf4PartiesInnerPartyEnum cashier =
      _$printBlockOneOf4PartiesInnerPartyEnum_cashier;

  static Serializer<PrintBlockOneOf4PartiesInnerPartyEnum> get serializer =>
      _$printBlockOneOf4PartiesInnerPartyEnumSerializer;

  const PrintBlockOneOf4PartiesInnerPartyEnum._(String name) : super(name);

  static BuiltSet<PrintBlockOneOf4PartiesInnerPartyEnum> get values =>
      _$printBlockOneOf4PartiesInnerPartyEnumValues;
  static PrintBlockOneOf4PartiesInnerPartyEnum valueOf(String name) =>
      _$printBlockOneOf4PartiesInnerPartyEnumValueOf(name);
}
