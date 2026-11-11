//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_station_input.g.dart';

/// KitchenStationInput
///
/// Properties:
/// * [name]
/// * [kind]
/// * [printerId]
/// * [kdsEnabled]
/// * [isDefault]
/// * [warnAfterMinutes]
/// * [lateAfterMinutes]
/// * [position]
/// * [active]
@BuiltValue(instantiable: false)
abstract class KitchenStationInput {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'kind')
  KitchenStationInputKindEnum? get kind;
  // enum kindEnum {  prep,  bar,  expo,  };

  @BuiltValueField(wireName: r'printer_id')
  String? get printerId;

  @BuiltValueField(wireName: r'kds_enabled')
  bool? get kdsEnabled;

  @BuiltValueField(wireName: r'is_default')
  bool? get isDefault;

  @BuiltValueField(wireName: r'warn_after_minutes')
  int? get warnAfterMinutes;

  @BuiltValueField(wireName: r'late_after_minutes')
  int? get lateAfterMinutes;

  @BuiltValueField(wireName: r'position')
  int? get position;

  @BuiltValueField(wireName: r'active')
  bool? get active;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenStationInput> get serializer =>
      _$KitchenStationInputSerializer();
}

class _$KitchenStationInputSerializer
    implements PrimitiveSerializer<KitchenStationInput> {
  @override
  final Iterable<Type> types = const [KitchenStationInput];

  @override
  final String wireName = r'KitchenStationInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenStationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(KitchenStationInputKindEnum),
      );
    }
    if (object.printerId != null) {
      yield r'printer_id';
      yield serializers.serialize(
        object.printerId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.kdsEnabled != null) {
      yield r'kds_enabled';
      yield serializers.serialize(
        object.kdsEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isDefault != null) {
      yield r'is_default';
      yield serializers.serialize(
        object.isDefault,
        specifiedType: const FullType(bool),
      );
    }
    if (object.warnAfterMinutes != null) {
      yield r'warn_after_minutes';
      yield serializers.serialize(
        object.warnAfterMinutes,
        specifiedType: const FullType(int),
      );
    }
    if (object.lateAfterMinutes != null) {
      yield r'late_after_minutes';
      yield serializers.serialize(
        object.lateAfterMinutes,
        specifiedType: const FullType(int),
      );
    }
    if (object.position != null) {
      yield r'position';
      yield serializers.serialize(
        object.position,
        specifiedType: const FullType(int),
      );
    }
    if (object.active != null) {
      yield r'active';
      yield serializers.serialize(
        object.active,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenStationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  @override
  KitchenStationInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized,
        specifiedType: FullType($KitchenStationInput)) as $KitchenStationInput;
  }
}

/// a concrete implementation of [KitchenStationInput], since [KitchenStationInput] is not instantiable
@BuiltValue(instantiable: true)
abstract class $KitchenStationInput
    implements
        KitchenStationInput,
        Built<$KitchenStationInput, $KitchenStationInputBuilder> {
  $KitchenStationInput._();

  factory $KitchenStationInput(
          [void Function($KitchenStationInputBuilder)? updates]) =
      _$$KitchenStationInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($KitchenStationInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$KitchenStationInput> get serializer =>
      _$$KitchenStationInputSerializer();
}

class _$$KitchenStationInputSerializer
    implements PrimitiveSerializer<$KitchenStationInput> {
  @override
  final Iterable<Type> types = const [
    $KitchenStationInput,
    _$$KitchenStationInput
  ];

  @override
  final String wireName = r'$KitchenStationInput';

  @override
  Object serialize(
    Serializers serializers,
    $KitchenStationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object,
        specifiedType: FullType(KitchenStationInput))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required KitchenStationInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KitchenStationInputKindEnum),
          ) as KitchenStationInputKindEnum?;
          if (valueDes == null) continue;
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
        case r'kds_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.kdsEnabled = valueDes;
          break;
        case r'is_default':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isDefault = valueDes;
          break;
        case r'warn_after_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warnAfterMinutes = valueDes;
          break;
        case r'late_after_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.lateAfterMinutes = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.position = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
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
  $KitchenStationInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $KitchenStationInputBuilder();
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

class KitchenStationInputKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'prep')
  static const KitchenStationInputKindEnum prep =
      _$kitchenStationInputKindEnum_prep;
  @BuiltValueEnumConst(wireName: r'bar')
  static const KitchenStationInputKindEnum bar =
      _$kitchenStationInputKindEnum_bar;
  @BuiltValueEnumConst(wireName: r'expo')
  static const KitchenStationInputKindEnum expo =
      _$kitchenStationInputKindEnum_expo;

  static Serializer<KitchenStationInputKindEnum> get serializer =>
      _$kitchenStationInputKindEnumSerializer;

  const KitchenStationInputKindEnum._(String name) : super(name);

  static BuiltSet<KitchenStationInputKindEnum> get values =>
      _$kitchenStationInputKindEnumValues;
  static KitchenStationInputKindEnum valueOf(String name) =>
      _$kitchenStationInputKindEnumValueOf(name);
}
