//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_cup_label_settings_update_request.g.dart';

/// PosCupLabelSettingsUpdateRequest
///
/// Properties:
/// * [branchId]
/// * [printerId]
/// * [size]
/// * [fields]
/// * [pickupMinutes]
@BuiltValue()
abstract class PosCupLabelSettingsUpdateRequest
    implements
        Built<PosCupLabelSettingsUpdateRequest,
            PosCupLabelSettingsUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'printer_id')
  String? get printerId;

  @BuiltValueField(wireName: r'size')
  PosCupLabelSettingsUpdateRequestSizeEnum? get size;
  // enum sizeEnum {  40x30,  50x30,  58x40,  };

  @BuiltValueField(wireName: r'fields')
  BuiltList<PosCupLabelSettingsUpdateRequestFieldsEnum>? get fields;
  // enum fieldsEnum {  call_number,  options,  note,  guest_name,  time,  store_name,  };

  @BuiltValueField(wireName: r'pickup_minutes')
  int? get pickupMinutes;

  PosCupLabelSettingsUpdateRequest._();

  factory PosCupLabelSettingsUpdateRequest(
          [void updates(PosCupLabelSettingsUpdateRequestBuilder b)]) =
      _$PosCupLabelSettingsUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosCupLabelSettingsUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosCupLabelSettingsUpdateRequest> get serializer =>
      _$PosCupLabelSettingsUpdateRequestSerializer();
}

class _$PosCupLabelSettingsUpdateRequestSerializer
    implements PrimitiveSerializer<PosCupLabelSettingsUpdateRequest> {
  @override
  final Iterable<Type> types = const [
    PosCupLabelSettingsUpdateRequest,
    _$PosCupLabelSettingsUpdateRequest
  ];

  @override
  final String wireName = r'PosCupLabelSettingsUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosCupLabelSettingsUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    if (object.printerId != null) {
      yield r'printer_id';
      yield serializers.serialize(
        object.printerId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.size != null) {
      yield r'size';
      yield serializers.serialize(
        object.size,
        specifiedType: const FullType(PosCupLabelSettingsUpdateRequestSizeEnum),
      );
    }
    if (object.fields != null) {
      yield r'fields';
      yield serializers.serialize(
        object.fields,
        specifiedType: const FullType(
            BuiltList, [FullType(PosCupLabelSettingsUpdateRequestFieldsEnum)]),
      );
    }
    if (object.pickupMinutes != null) {
      yield r'pickup_minutes';
      yield serializers.serialize(
        object.pickupMinutes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosCupLabelSettingsUpdateRequest object, {
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
    required PosCupLabelSettingsUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'printer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.printerId = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PosCupLabelSettingsUpdateRequestSizeEnum),
          ) as PosCupLabelSettingsUpdateRequestSizeEnum?;
          if (valueDes == null) continue;
          result.size = valueDes;
          break;
        case r'fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList,
                [FullType(PosCupLabelSettingsUpdateRequestFieldsEnum)]),
          ) as BuiltList<PosCupLabelSettingsUpdateRequestFieldsEnum>?;
          if (valueDes == null) continue;
          result.fields.replace(valueDes);
          break;
        case r'pickup_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.pickupMinutes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosCupLabelSettingsUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosCupLabelSettingsUpdateRequestBuilder();
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

class PosCupLabelSettingsUpdateRequestSizeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'40x30')
  static const PosCupLabelSettingsUpdateRequestSizeEnum n40x30 =
      _$posCupLabelSettingsUpdateRequestSizeEnum_n40x30;
  @BuiltValueEnumConst(wireName: r'50x30')
  static const PosCupLabelSettingsUpdateRequestSizeEnum n50x30 =
      _$posCupLabelSettingsUpdateRequestSizeEnum_n50x30;
  @BuiltValueEnumConst(wireName: r'58x40')
  static const PosCupLabelSettingsUpdateRequestSizeEnum n58x40 =
      _$posCupLabelSettingsUpdateRequestSizeEnum_n58x40;

  static Serializer<PosCupLabelSettingsUpdateRequestSizeEnum> get serializer =>
      _$posCupLabelSettingsUpdateRequestSizeEnumSerializer;

  const PosCupLabelSettingsUpdateRequestSizeEnum._(String name) : super(name);

  static BuiltSet<PosCupLabelSettingsUpdateRequestSizeEnum> get values =>
      _$posCupLabelSettingsUpdateRequestSizeEnumValues;
  static PosCupLabelSettingsUpdateRequestSizeEnum valueOf(String name) =>
      _$posCupLabelSettingsUpdateRequestSizeEnumValueOf(name);
}

class PosCupLabelSettingsUpdateRequestFieldsEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'call_number')
  static const PosCupLabelSettingsUpdateRequestFieldsEnum callNumber =
      _$posCupLabelSettingsUpdateRequestFieldsEnum_callNumber;
  @BuiltValueEnumConst(wireName: r'options')
  static const PosCupLabelSettingsUpdateRequestFieldsEnum options =
      _$posCupLabelSettingsUpdateRequestFieldsEnum_options;
  @BuiltValueEnumConst(wireName: r'note')
  static const PosCupLabelSettingsUpdateRequestFieldsEnum note =
      _$posCupLabelSettingsUpdateRequestFieldsEnum_note;
  @BuiltValueEnumConst(wireName: r'guest_name')
  static const PosCupLabelSettingsUpdateRequestFieldsEnum guestName =
      _$posCupLabelSettingsUpdateRequestFieldsEnum_guestName;
  @BuiltValueEnumConst(wireName: r'time')
  static const PosCupLabelSettingsUpdateRequestFieldsEnum time =
      _$posCupLabelSettingsUpdateRequestFieldsEnum_time;
  @BuiltValueEnumConst(wireName: r'store_name')
  static const PosCupLabelSettingsUpdateRequestFieldsEnum storeName =
      _$posCupLabelSettingsUpdateRequestFieldsEnum_storeName;

  static Serializer<PosCupLabelSettingsUpdateRequestFieldsEnum>
      get serializer => _$posCupLabelSettingsUpdateRequestFieldsEnumSerializer;

  const PosCupLabelSettingsUpdateRequestFieldsEnum._(String name) : super(name);

  static BuiltSet<PosCupLabelSettingsUpdateRequestFieldsEnum> get values =>
      _$posCupLabelSettingsUpdateRequestFieldsEnumValues;
  static PosCupLabelSettingsUpdateRequestFieldsEnum valueOf(String name) =>
      _$posCupLabelSettingsUpdateRequestFieldsEnumValueOf(name);
}
