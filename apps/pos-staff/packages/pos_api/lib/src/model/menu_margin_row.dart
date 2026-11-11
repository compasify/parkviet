//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'menu_margin_row.g.dart';

/// MenuMarginRow
///
/// Properties:
/// * [menuItem]
/// * [sku]
/// * [quantity]
/// * [revenue]
/// * [cost]
/// * [margin]
/// * [marginRate] - Percent of revenue, one decimal
/// * [costed] - Whether any recipe consumption was recorded for the size
@BuiltValue()
abstract class MenuMarginRow
    implements Built<MenuMarginRow, MenuMarginRowBuilder> {
  @BuiltValueField(wireName: r'menu_item')
  String get menuItem;

  @BuiltValueField(wireName: r'sku')
  String? get sku;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  @BuiltValueField(wireName: r'revenue')
  String get revenue;

  @BuiltValueField(wireName: r'cost')
  String get cost;

  @BuiltValueField(wireName: r'margin')
  String get margin;

  /// Percent of revenue, one decimal
  @BuiltValueField(wireName: r'margin_rate')
  String? get marginRate;

  /// Whether any recipe consumption was recorded for the size
  @BuiltValueField(wireName: r'costed')
  bool get costed;

  MenuMarginRow._();

  factory MenuMarginRow([void updates(MenuMarginRowBuilder b)]) =
      _$MenuMarginRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MenuMarginRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MenuMarginRow> get serializer =>
      _$MenuMarginRowSerializer();
}

class _$MenuMarginRowSerializer implements PrimitiveSerializer<MenuMarginRow> {
  @override
  final Iterable<Type> types = const [MenuMarginRow, _$MenuMarginRow];

  @override
  final String wireName = r'MenuMarginRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MenuMarginRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'menu_item';
    yield serializers.serialize(
      object.menuItem,
      specifiedType: const FullType(String),
    );
    yield r'sku';
    yield object.sku == null
        ? null
        : serializers.serialize(
            object.sku,
            specifiedType: const FullType.nullable(String),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    yield r'revenue';
    yield serializers.serialize(
      object.revenue,
      specifiedType: const FullType(String),
    );
    yield r'cost';
    yield serializers.serialize(
      object.cost,
      specifiedType: const FullType(String),
    );
    yield r'margin';
    yield serializers.serialize(
      object.margin,
      specifiedType: const FullType(String),
    );
    yield r'margin_rate';
    yield object.marginRate == null
        ? null
        : serializers.serialize(
            object.marginRate,
            specifiedType: const FullType.nullable(String),
          );
    yield r'costed';
    yield serializers.serialize(
      object.costed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MenuMarginRow object, {
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
    required MenuMarginRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'menu_item':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.menuItem = valueDes;
          break;
        case r'sku':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sku = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'revenue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.revenue = valueDes;
          break;
        case r'cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cost = valueDes;
          break;
        case r'margin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.margin = valueDes;
          break;
        case r'margin_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.marginRate = valueDes;
          break;
        case r'costed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.costed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MenuMarginRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MenuMarginRowBuilder();
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
