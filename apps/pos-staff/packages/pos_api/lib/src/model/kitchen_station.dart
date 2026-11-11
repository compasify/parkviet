//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_station.g.dart';

/// KitchenStation
///
/// Properties:
/// * [expoStationId] - The pass (an `expo` station of the branch) this station hands its finished items to.
/// * [id]
/// * [branchId]
/// * [name]
/// * [kind]
/// * [printerId]
/// * [printerName]
/// * [kdsEnabled]
/// * [isDefault] - Where a menu item goes when no route names it.
/// * [warnAfterMinutes]
/// * [lateAfterMinutes]
/// * [position]
/// * [active]
@BuiltValue()
abstract class KitchenStation
    implements Built<KitchenStation, KitchenStationBuilder> {
  /// The pass (an `expo` station of the branch) this station hands its finished items to.
  @BuiltValueField(wireName: r'expo_station_id')
  String? get expoStationId;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  KitchenStationKindEnum get kind;
  // enum kindEnum {  prep,  bar,  expo,  };

  @BuiltValueField(wireName: r'printer_id')
  String? get printerId;

  @BuiltValueField(wireName: r'printer_name')
  String? get printerName;

  @BuiltValueField(wireName: r'kds_enabled')
  bool get kdsEnabled;

  /// Where a menu item goes when no route names it.
  @BuiltValueField(wireName: r'is_default')
  bool get isDefault;

  @BuiltValueField(wireName: r'warn_after_minutes')
  int get warnAfterMinutes;

  @BuiltValueField(wireName: r'late_after_minutes')
  int get lateAfterMinutes;

  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'active')
  bool get active;

  KitchenStation._();

  factory KitchenStation([void updates(KitchenStationBuilder b)]) =
      _$KitchenStation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenStationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenStation> get serializer =>
      _$KitchenStationSerializer();
}

class _$KitchenStationSerializer
    implements PrimitiveSerializer<KitchenStation> {
  @override
  final Iterable<Type> types = const [KitchenStation, _$KitchenStation];

  @override
  final String wireName = r'KitchenStation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenStation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expo_station_id';
    yield object.expoStationId == null
        ? null
        : serializers.serialize(
            object.expoStationId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(KitchenStationKindEnum),
    );
    yield r'printer_id';
    yield object.printerId == null
        ? null
        : serializers.serialize(
            object.printerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'printer_name';
    yield object.printerName == null
        ? null
        : serializers.serialize(
            object.printerName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'kds_enabled';
    yield serializers.serialize(
      object.kdsEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'is_default';
    yield serializers.serialize(
      object.isDefault,
      specifiedType: const FullType(bool),
    );
    yield r'warn_after_minutes';
    yield serializers.serialize(
      object.warnAfterMinutes,
      specifiedType: const FullType(int),
    );
    yield r'late_after_minutes';
    yield serializers.serialize(
      object.lateAfterMinutes,
      specifiedType: const FullType(int),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenStation object, {
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
    required KitchenStationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expo_station_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.expoStationId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenStationKindEnum),
          ) as KitchenStationKindEnum;
          result.kind = valueDes;
          break;
        case r'printer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.printerId = valueDes;
          break;
        case r'printer_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.printerName = valueDes;
          break;
        case r'kds_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.kdsEnabled = valueDes;
          break;
        case r'is_default':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDefault = valueDes;
          break;
        case r'warn_after_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.warnAfterMinutes = valueDes;
          break;
        case r'late_after_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.lateAfterMinutes = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenStation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenStationBuilder();
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

class KitchenStationKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'prep')
  static const KitchenStationKindEnum prep = _$kitchenStationKindEnum_prep;
  @BuiltValueEnumConst(wireName: r'bar')
  static const KitchenStationKindEnum bar = _$kitchenStationKindEnum_bar;
  @BuiltValueEnumConst(wireName: r'expo')
  static const KitchenStationKindEnum expo = _$kitchenStationKindEnum_expo;

  static Serializer<KitchenStationKindEnum> get serializer =>
      _$kitchenStationKindEnumSerializer;

  const KitchenStationKindEnum._(String name) : super(name);

  static BuiltSet<KitchenStationKindEnum> get values =>
      _$kitchenStationKindEnumValues;
  static KitchenStationKindEnum valueOf(String name) =>
      _$kitchenStationKindEnumValueOf(name);
}
