//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'append_items_meta.g.dart';

/// AppendItemsMeta
///
/// Properties:
/// * [saleLineIds]
@BuiltValue()
abstract class AppendItemsMeta
    implements Built<AppendItemsMeta, AppendItemsMetaBuilder> {
  @BuiltValueField(wireName: r'sale_line_ids')
  BuiltList<String> get saleLineIds;

  AppendItemsMeta._();

  factory AppendItemsMeta([void updates(AppendItemsMetaBuilder b)]) =
      _$AppendItemsMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppendItemsMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppendItemsMeta> get serializer =>
      _$AppendItemsMetaSerializer();
}

class _$AppendItemsMetaSerializer
    implements PrimitiveSerializer<AppendItemsMeta> {
  @override
  final Iterable<Type> types = const [AppendItemsMeta, _$AppendItemsMeta];

  @override
  final String wireName = r'AppendItemsMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppendItemsMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sale_line_ids';
    yield serializers.serialize(
      object.saleLineIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AppendItemsMeta object, {
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
    required AppendItemsMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sale_line_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.saleLineIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppendItemsMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppendItemsMetaBuilder();
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
