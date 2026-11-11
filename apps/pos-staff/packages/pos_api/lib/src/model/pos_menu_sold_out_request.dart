//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_menu_sold_out_request.g.dart';

/// PosMenuSoldOutRequest
///
/// Properties:
/// * [branchId]
/// * [menuItemId]
/// * [soldOut]
@BuiltValue()
abstract class PosMenuSoldOutRequest
    implements Built<PosMenuSoldOutRequest, PosMenuSoldOutRequestBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'menu_item_id')
  String get menuItemId;

  @BuiltValueField(wireName: r'sold_out')
  bool get soldOut;

  PosMenuSoldOutRequest._();

  factory PosMenuSoldOutRequest(
      [void updates(PosMenuSoldOutRequestBuilder b)]) = _$PosMenuSoldOutRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosMenuSoldOutRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosMenuSoldOutRequest> get serializer =>
      _$PosMenuSoldOutRequestSerializer();
}

class _$PosMenuSoldOutRequestSerializer
    implements PrimitiveSerializer<PosMenuSoldOutRequest> {
  @override
  final Iterable<Type> types = const [
    PosMenuSoldOutRequest,
    _$PosMenuSoldOutRequest
  ];

  @override
  final String wireName = r'PosMenuSoldOutRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosMenuSoldOutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'menu_item_id';
    yield serializers.serialize(
      object.menuItemId,
      specifiedType: const FullType(String),
    );
    yield r'sold_out';
    yield serializers.serialize(
      object.soldOut,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosMenuSoldOutRequest object, {
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
    required PosMenuSoldOutRequestBuilder result,
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
        case r'menu_item_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.menuItemId = valueDes;
          break;
        case r'sold_out':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.soldOut = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosMenuSoldOutRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosMenuSoldOutRequestBuilder();
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
