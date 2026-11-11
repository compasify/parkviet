//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/table_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_settings_result.g.dart';

/// TableSettingsResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class TableSettingsResult
    implements Built<TableSettingsResult, TableSettingsResultBuilder> {
  @BuiltValueField(wireName: r'data')
  TableSettings get data;

  TableSettingsResult._();

  factory TableSettingsResult([void updates(TableSettingsResultBuilder b)]) =
      _$TableSettingsResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableSettingsResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableSettingsResult> get serializer =>
      _$TableSettingsResultSerializer();
}

class _$TableSettingsResultSerializer
    implements PrimitiveSerializer<TableSettingsResult> {
  @override
  final Iterable<Type> types = const [
    TableSettingsResult,
    _$TableSettingsResult
  ];

  @override
  final String wireName = r'TableSettingsResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableSettingsResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TableSettings),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TableSettingsResult object, {
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
    required TableSettingsResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TableSettings),
          ) as TableSettings;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableSettingsResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableSettingsResultBuilder();
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
