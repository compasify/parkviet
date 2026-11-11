//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'menu_availability.g.dart';

/// MenuAvailability
///
/// Properties:
/// * [menuItemId]
/// * [branchId]
/// * [soldOut]
/// * [businessDate]
@BuiltValue()
abstract class MenuAvailability
    implements Built<MenuAvailability, MenuAvailabilityBuilder> {
  @BuiltValueField(wireName: r'menu_item_id')
  String get menuItemId;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'sold_out')
  bool get soldOut;

  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  MenuAvailability._();

  factory MenuAvailability([void updates(MenuAvailabilityBuilder b)]) =
      _$MenuAvailability;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MenuAvailabilityBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MenuAvailability> get serializer =>
      _$MenuAvailabilitySerializer();
}

class _$MenuAvailabilitySerializer
    implements PrimitiveSerializer<MenuAvailability> {
  @override
  final Iterable<Type> types = const [MenuAvailability, _$MenuAvailability];

  @override
  final String wireName = r'MenuAvailability';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MenuAvailability object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'menu_item_id';
    yield serializers.serialize(
      object.menuItemId,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'sold_out';
    yield serializers.serialize(
      object.soldOut,
      specifiedType: const FullType(bool),
    );
    yield r'business_date';
    yield serializers.serialize(
      object.businessDate,
      specifiedType: const FullType(Date),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MenuAvailability object, {
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
    required MenuAvailabilityBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'menu_item_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.menuItemId = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'sold_out':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.soldOut = valueDes;
          break;
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.businessDate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MenuAvailability deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MenuAvailabilityBuilder();
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
