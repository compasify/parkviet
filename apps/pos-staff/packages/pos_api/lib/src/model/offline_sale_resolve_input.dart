//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/offline_sale_line.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_sale_resolve_input.g.dart';

/// OfflineSaleResolveInput
///
/// Properties:
/// * [mode]
/// * [approvalId]
/// * [handedAmount]
/// * [lines]
/// * [note]
@BuiltValue()
abstract class OfflineSaleResolveInput
    implements Built<OfflineSaleResolveInput, OfflineSaleResolveInputBuilder> {
  @BuiltValueField(wireName: r'mode')
  OfflineSaleResolveInputModeEnum get mode;
  // enum modeEnum {  accept_collected,  current_price,  edited,  };

  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  @BuiltValueField(wireName: r'handed_amount')
  String? get handedAmount;

  @BuiltValueField(wireName: r'lines')
  BuiltList<OfflineSaleLine>? get lines;

  @BuiltValueField(wireName: r'note')
  String? get note;

  OfflineSaleResolveInput._();

  factory OfflineSaleResolveInput(
          [void updates(OfflineSaleResolveInputBuilder b)]) =
      _$OfflineSaleResolveInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSaleResolveInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSaleResolveInput> get serializer =>
      _$OfflineSaleResolveInputSerializer();
}

class _$OfflineSaleResolveInputSerializer
    implements PrimitiveSerializer<OfflineSaleResolveInput> {
  @override
  final Iterable<Type> types = const [
    OfflineSaleResolveInput,
    _$OfflineSaleResolveInput
  ];

  @override
  final String wireName = r'OfflineSaleResolveInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSaleResolveInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(OfflineSaleResolveInputModeEnum),
    );
    if (object.approvalId != null) {
      yield r'approval_id';
      yield serializers.serialize(
        object.approvalId,
        specifiedType: const FullType(String),
      );
    }
    if (object.handedAmount != null) {
      yield r'handed_amount';
      yield serializers.serialize(
        object.handedAmount,
        specifiedType: const FullType(String),
      );
    }
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType(BuiltList, [FullType(OfflineSaleLine)]),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSaleResolveInput object, {
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
    required OfflineSaleResolveInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfflineSaleResolveInputModeEnum),
          ) as OfflineSaleResolveInputModeEnum;
          result.mode = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        case r'handed_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.handedAmount = valueDes;
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(OfflineSaleLine)]),
          ) as BuiltList<OfflineSaleLine>?;
          if (valueDes == null) continue;
          result.lines.replace(valueDes);
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSaleResolveInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSaleResolveInputBuilder();
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

class OfflineSaleResolveInputModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'accept_collected')
  static const OfflineSaleResolveInputModeEnum acceptCollected =
      _$offlineSaleResolveInputModeEnum_acceptCollected;
  @BuiltValueEnumConst(wireName: r'current_price')
  static const OfflineSaleResolveInputModeEnum currentPrice =
      _$offlineSaleResolveInputModeEnum_currentPrice;
  @BuiltValueEnumConst(wireName: r'edited')
  static const OfflineSaleResolveInputModeEnum edited =
      _$offlineSaleResolveInputModeEnum_edited;

  static Serializer<OfflineSaleResolveInputModeEnum> get serializer =>
      _$offlineSaleResolveInputModeEnumSerializer;

  const OfflineSaleResolveInputModeEnum._(String name) : super(name);

  static BuiltSet<OfflineSaleResolveInputModeEnum> get values =>
      _$offlineSaleResolveInputModeEnumValues;
  static OfflineSaleResolveInputModeEnum valueOf(String name) =>
      _$offlineSaleResolveInputModeEnumValueOf(name);
}
