//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/einvoice_setting_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_settings_save_request.g.dart';

/// PosEinvoiceSettingsSaveRequest
///
/// Properties:
/// * [einvoiceType]
/// * [branchId]
/// * [setting]
@BuiltValue()
abstract class PosEinvoiceSettingsSaveRequest
    implements
        Built<PosEinvoiceSettingsSaveRequest,
            PosEinvoiceSettingsSaveRequestBuilder> {
  @BuiltValueField(wireName: r'einvoice_type')
  PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum? get einvoiceType;
  // enum einvoiceTypeEnum {  none,  cash_register,  coded,  };

  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'setting')
  EinvoiceSettingInput? get setting;

  PosEinvoiceSettingsSaveRequest._();

  factory PosEinvoiceSettingsSaveRequest(
          [void updates(PosEinvoiceSettingsSaveRequestBuilder b)]) =
      _$PosEinvoiceSettingsSaveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceSettingsSaveRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceSettingsSaveRequest> get serializer =>
      _$PosEinvoiceSettingsSaveRequestSerializer();
}

class _$PosEinvoiceSettingsSaveRequestSerializer
    implements PrimitiveSerializer<PosEinvoiceSettingsSaveRequest> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceSettingsSaveRequest,
    _$PosEinvoiceSettingsSaveRequest
  ];

  @override
  final String wireName = r'PosEinvoiceSettingsSaveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceSettingsSaveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.einvoiceType != null) {
      yield r'einvoice_type';
      yield serializers.serialize(
        object.einvoiceType,
        specifiedType:
            const FullType(PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum),
      );
    }
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.setting != null) {
      yield r'setting';
      yield serializers.serialize(
        object.setting,
        specifiedType: const FullType(EinvoiceSettingInput),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceSettingsSaveRequest object, {
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
    required PosEinvoiceSettingsSaveRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'einvoice_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum),
          ) as PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum?;
          if (valueDes == null) continue;
          result.einvoiceType = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'setting':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(EinvoiceSettingInput),
          ) as EinvoiceSettingInput?;
          if (valueDes == null) continue;
          result.setting.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosEinvoiceSettingsSaveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceSettingsSaveRequestBuilder();
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

class PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'none')
  static const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum none =
      _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'cash_register')
  static const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum cashRegister =
      _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_cashRegister;
  @BuiltValueEnumConst(wireName: r'coded')
  static const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum coded =
      _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_coded;

  static Serializer<PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum>
      get serializer =>
          _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnumSerializer;

  const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum._(String name)
      : super(name);

  static BuiltSet<PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum> get values =>
      _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnumValues;
  static PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum valueOf(String name) =>
      _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnumValueOf(name);
}
