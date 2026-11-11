//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_settings.g.dart';

/// KitchenSettings
///
/// Properties:
/// * [branchId]
/// * [kitchenSendTrigger] - `on_complete` sends what is left as the sale completes; `manual` waits for \"send to kitchen\".
/// * [moduleEnabled] - Whether `fnb.kitchen` is on at the branch.
@BuiltValue()
abstract class KitchenSettings
    implements Built<KitchenSettings, KitchenSettingsBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  /// `on_complete` sends what is left as the sale completes; `manual` waits for \"send to kitchen\".
  @BuiltValueField(wireName: r'kitchen_send_trigger')
  KitchenSettingsKitchenSendTriggerEnum get kitchenSendTrigger;
  // enum kitchenSendTriggerEnum {  on_complete,  manual,  };

  /// Whether `fnb.kitchen` is on at the branch.
  @BuiltValueField(wireName: r'module_enabled')
  bool get moduleEnabled;

  KitchenSettings._();

  factory KitchenSettings([void updates(KitchenSettingsBuilder b)]) =
      _$KitchenSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenSettings> get serializer =>
      _$KitchenSettingsSerializer();
}

class _$KitchenSettingsSerializer
    implements PrimitiveSerializer<KitchenSettings> {
  @override
  final Iterable<Type> types = const [KitchenSettings, _$KitchenSettings];

  @override
  final String wireName = r'KitchenSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'kitchen_send_trigger';
    yield serializers.serialize(
      object.kitchenSendTrigger,
      specifiedType: const FullType(KitchenSettingsKitchenSendTriggerEnum),
    );
    yield r'module_enabled';
    yield serializers.serialize(
      object.moduleEnabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenSettings object, {
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
    required KitchenSettingsBuilder result,
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
        case r'kitchen_send_trigger':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(KitchenSettingsKitchenSendTriggerEnum),
          ) as KitchenSettingsKitchenSendTriggerEnum;
          result.kitchenSendTrigger = valueDes;
          break;
        case r'module_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.moduleEnabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenSettingsBuilder();
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

/// `on_complete` sends what is left as the sale completes; `manual` waits for \"send to kitchen\".
class KitchenSettingsKitchenSendTriggerEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'on_complete')
  static const KitchenSettingsKitchenSendTriggerEnum onComplete =
      _$kitchenSettingsKitchenSendTriggerEnum_onComplete;
  @BuiltValueEnumConst(wireName: r'manual')
  static const KitchenSettingsKitchenSendTriggerEnum manual =
      _$kitchenSettingsKitchenSendTriggerEnum_manual;

  static Serializer<KitchenSettingsKitchenSendTriggerEnum> get serializer =>
      _$kitchenSettingsKitchenSendTriggerEnumSerializer;

  const KitchenSettingsKitchenSendTriggerEnum._(String name) : super(name);

  static BuiltSet<KitchenSettingsKitchenSendTriggerEnum> get values =>
      _$kitchenSettingsKitchenSendTriggerEnumValues;
  static KitchenSettingsKitchenSendTriggerEnum valueOf(String name) =>
      _$kitchenSettingsKitchenSendTriggerEnumValueOf(name);
}
