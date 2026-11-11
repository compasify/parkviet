//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_menu_favorites200_response_data.g.dart';

/// PosMenuFavorites200ResponseData
///
/// Properties:
/// * [branchId]
/// * [menuItemIds]
@BuiltValue()
abstract class PosMenuFavorites200ResponseData
    implements
        Built<PosMenuFavorites200ResponseData,
            PosMenuFavorites200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'menu_item_ids')
  BuiltList<String> get menuItemIds;

  PosMenuFavorites200ResponseData._();

  factory PosMenuFavorites200ResponseData(
          [void updates(PosMenuFavorites200ResponseDataBuilder b)]) =
      _$PosMenuFavorites200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosMenuFavorites200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosMenuFavorites200ResponseData> get serializer =>
      _$PosMenuFavorites200ResponseDataSerializer();
}

class _$PosMenuFavorites200ResponseDataSerializer
    implements PrimitiveSerializer<PosMenuFavorites200ResponseData> {
  @override
  final Iterable<Type> types = const [
    PosMenuFavorites200ResponseData,
    _$PosMenuFavorites200ResponseData
  ];

  @override
  final String wireName = r'PosMenuFavorites200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosMenuFavorites200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'menu_item_ids';
    yield serializers.serialize(
      object.menuItemIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosMenuFavorites200ResponseData object, {
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
    required PosMenuFavorites200ResponseDataBuilder result,
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
        case r'menu_item_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.menuItemIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosMenuFavorites200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosMenuFavorites200ResponseDataBuilder();
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
