//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'prebill_input.g.dart';

/// PrebillInput
///
/// Properties:
/// * [approvalId] - Needed for a reprint and for a cancel.
/// * [printerId]
/// * [receiptTemplateId]
/// * [unmask]
@BuiltValue()
abstract class PrebillInput
    implements Built<PrebillInput, PrebillInputBuilder> {
  /// Needed for a reprint and for a cancel.
  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  @BuiltValueField(wireName: r'printer_id')
  String? get printerId;

  @BuiltValueField(wireName: r'receipt_template_id')
  String? get receiptTemplateId;

  @BuiltValueField(wireName: r'unmask')
  PrebillInputUnmaskEnum? get unmask;
  // enum unmaskEnum {  true,  false,  };

  PrebillInput._();

  factory PrebillInput([void updates(PrebillInputBuilder b)]) = _$PrebillInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrebillInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrebillInput> get serializer => _$PrebillInputSerializer();
}

class _$PrebillInputSerializer implements PrimitiveSerializer<PrebillInput> {
  @override
  final Iterable<Type> types = const [PrebillInput, _$PrebillInput];

  @override
  final String wireName = r'PrebillInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrebillInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.approvalId != null) {
      yield r'approval_id';
      yield serializers.serialize(
        object.approvalId,
        specifiedType: const FullType(String),
      );
    }
    if (object.printerId != null) {
      yield r'printer_id';
      yield serializers.serialize(
        object.printerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.receiptTemplateId != null) {
      yield r'receipt_template_id';
      yield serializers.serialize(
        object.receiptTemplateId,
        specifiedType: const FullType(String),
      );
    }
    if (object.unmask != null) {
      yield r'unmask';
      yield serializers.serialize(
        object.unmask,
        specifiedType: const FullType(PrebillInputUnmaskEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PrebillInput object, {
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
    required PrebillInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        case r'printer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.printerId = valueDes;
          break;
        case r'receipt_template_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.receiptTemplateId = valueDes;
          break;
        case r'unmask':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PrebillInputUnmaskEnum),
          ) as PrebillInputUnmaskEnum?;
          if (valueDes == null) continue;
          result.unmask = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrebillInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrebillInputBuilder();
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

class PrebillInputUnmaskEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'true')
  static const PrebillInputUnmaskEnum true_ = _$prebillInputUnmaskEnum_true_;
  @BuiltValueEnumConst(wireName: r'false')
  static const PrebillInputUnmaskEnum false_ = _$prebillInputUnmaskEnum_false_;

  static Serializer<PrebillInputUnmaskEnum> get serializer =>
      _$prebillInputUnmaskEnumSerializer;

  const PrebillInputUnmaskEnum._(String name) : super(name);

  static BuiltSet<PrebillInputUnmaskEnum> get values =>
      _$prebillInputUnmaskEnumValues;
  static PrebillInputUnmaskEnum valueOf(String name) =>
      _$prebillInputUnmaskEnumValueOf(name);
}
