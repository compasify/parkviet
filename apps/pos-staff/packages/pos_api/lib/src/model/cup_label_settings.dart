//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cup_label_settings.g.dart';

/// CupLabelSettings
///
/// Properties:
/// * [branchId]
/// * [printerId]
/// * [size] - Label size in millimetres, width x height.
/// * [fields] - Optional fields that print; the item and \"n/N\" always print.
/// * [pickupMinutes] - How long a ready call number stays on the call board.
/// * [moduleEnabled] - Whether `fnb.cup_label` is on at the branch.
/// * [sizes]
/// * [availableFields]
@BuiltValue()
abstract class CupLabelSettings
    implements Built<CupLabelSettings, CupLabelSettingsBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'printer_id')
  String? get printerId;

  /// Label size in millimetres, width x height.
  @BuiltValueField(wireName: r'size')
  CupLabelSettingsSizeEnum get size;
  // enum sizeEnum {  40x30,  50x30,  58x40,  };

  /// Optional fields that print; the item and \"n/N\" always print.
  @BuiltValueField(wireName: r'fields')
  BuiltList<CupLabelSettingsFieldsEnum> get fields;
  // enum fieldsEnum {  call_number,  options,  note,  guest_name,  time,  store_name,  };

  /// How long a ready call number stays on the call board.
  @BuiltValueField(wireName: r'pickup_minutes')
  int get pickupMinutes;

  /// Whether `fnb.cup_label` is on at the branch.
  @BuiltValueField(wireName: r'module_enabled')
  bool get moduleEnabled;

  @BuiltValueField(wireName: r'sizes')
  BuiltList<String> get sizes;

  @BuiltValueField(wireName: r'available_fields')
  BuiltList<String> get availableFields;

  CupLabelSettings._();

  factory CupLabelSettings([void updates(CupLabelSettingsBuilder b)]) =
      _$CupLabelSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CupLabelSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CupLabelSettings> get serializer =>
      _$CupLabelSettingsSerializer();
}

class _$CupLabelSettingsSerializer
    implements PrimitiveSerializer<CupLabelSettings> {
  @override
  final Iterable<Type> types = const [CupLabelSettings, _$CupLabelSettings];

  @override
  final String wireName = r'CupLabelSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CupLabelSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'printer_id';
    yield object.printerId == null
        ? null
        : serializers.serialize(
            object.printerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'size';
    yield serializers.serialize(
      object.size,
      specifiedType: const FullType(CupLabelSettingsSizeEnum),
    );
    yield r'fields';
    yield serializers.serialize(
      object.fields,
      specifiedType:
          const FullType(BuiltList, [FullType(CupLabelSettingsFieldsEnum)]),
    );
    yield r'pickup_minutes';
    yield serializers.serialize(
      object.pickupMinutes,
      specifiedType: const FullType(int),
    );
    yield r'module_enabled';
    yield serializers.serialize(
      object.moduleEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'sizes';
    yield serializers.serialize(
      object.sizes,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'available_fields';
    yield serializers.serialize(
      object.availableFields,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CupLabelSettings object, {
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
    required CupLabelSettingsBuilder result,
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
            specifiedType: const FullType(CupLabelSettingsSizeEnum),
          ) as CupLabelSettingsSizeEnum;
          result.size = valueDes;
          break;
        case r'fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(CupLabelSettingsFieldsEnum)]),
          ) as BuiltList<CupLabelSettingsFieldsEnum>;
          result.fields.replace(valueDes);
          break;
        case r'pickup_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pickupMinutes = valueDes;
          break;
        case r'module_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.moduleEnabled = valueDes;
          break;
        case r'sizes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.sizes.replace(valueDes);
          break;
        case r'available_fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.availableFields.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CupLabelSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CupLabelSettingsBuilder();
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

/// Label size in millimetres, width x height.
class CupLabelSettingsSizeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'40x30')
  static const CupLabelSettingsSizeEnum n40x30 =
      _$cupLabelSettingsSizeEnum_n40x30;
  @BuiltValueEnumConst(wireName: r'50x30')
  static const CupLabelSettingsSizeEnum n50x30 =
      _$cupLabelSettingsSizeEnum_n50x30;
  @BuiltValueEnumConst(wireName: r'58x40')
  static const CupLabelSettingsSizeEnum n58x40 =
      _$cupLabelSettingsSizeEnum_n58x40;

  static Serializer<CupLabelSettingsSizeEnum> get serializer =>
      _$cupLabelSettingsSizeEnumSerializer;

  const CupLabelSettingsSizeEnum._(String name) : super(name);

  static BuiltSet<CupLabelSettingsSizeEnum> get values =>
      _$cupLabelSettingsSizeEnumValues;
  static CupLabelSettingsSizeEnum valueOf(String name) =>
      _$cupLabelSettingsSizeEnumValueOf(name);
}

class CupLabelSettingsFieldsEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'call_number')
  static const CupLabelSettingsFieldsEnum callNumber =
      _$cupLabelSettingsFieldsEnum_callNumber;
  @BuiltValueEnumConst(wireName: r'options')
  static const CupLabelSettingsFieldsEnum options =
      _$cupLabelSettingsFieldsEnum_options;
  @BuiltValueEnumConst(wireName: r'note')
  static const CupLabelSettingsFieldsEnum note =
      _$cupLabelSettingsFieldsEnum_note;
  @BuiltValueEnumConst(wireName: r'guest_name')
  static const CupLabelSettingsFieldsEnum guestName =
      _$cupLabelSettingsFieldsEnum_guestName;
  @BuiltValueEnumConst(wireName: r'time')
  static const CupLabelSettingsFieldsEnum time =
      _$cupLabelSettingsFieldsEnum_time;
  @BuiltValueEnumConst(wireName: r'store_name')
  static const CupLabelSettingsFieldsEnum storeName =
      _$cupLabelSettingsFieldsEnum_storeName;

  static Serializer<CupLabelSettingsFieldsEnum> get serializer =>
      _$cupLabelSettingsFieldsEnumSerializer;

  const CupLabelSettingsFieldsEnum._(String name) : super(name);

  static BuiltSet<CupLabelSettingsFieldsEnum> get values =>
      _$cupLabelSettingsFieldsEnumValues;
  static CupLabelSettingsFieldsEnum valueOf(String name) =>
      _$cupLabelSettingsFieldsEnumValueOf(name);
}
