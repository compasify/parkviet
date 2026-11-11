//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/workspace.dart';
import 'package:pos_api/src/model/append_items_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'append_items_result.g.dart';

/// AppendItemsResult
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class AppendItemsResult
    implements Built<AppendItemsResult, AppendItemsResultBuilder> {
  @BuiltValueField(wireName: r'data')
  Workspace get data;

  @BuiltValueField(wireName: r'meta')
  AppendItemsMeta get meta;

  AppendItemsResult._();

  factory AppendItemsResult([void updates(AppendItemsResultBuilder b)]) =
      _$AppendItemsResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppendItemsResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppendItemsResult> get serializer =>
      _$AppendItemsResultSerializer();
}

class _$AppendItemsResultSerializer
    implements PrimitiveSerializer<AppendItemsResult> {
  @override
  final Iterable<Type> types = const [AppendItemsResult, _$AppendItemsResult];

  @override
  final String wireName = r'AppendItemsResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppendItemsResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Workspace),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(AppendItemsMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AppendItemsResult object, {
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
    required AppendItemsResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Workspace),
          ) as Workspace;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AppendItemsMeta),
          ) as AppendItemsMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppendItemsResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppendItemsResultBuilder();
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
