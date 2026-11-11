//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_tax_category.g.dart';

/// TableTaxCategory
///
/// Properties:
/// * [id]
/// * [name]
/// * [taxCode]
/// * [isDefault]
@BuiltValue()
abstract class TableTaxCategory
    implements Built<TableTaxCategory, TableTaxCategoryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'tax_code')
  String? get taxCode;

  @BuiltValueField(wireName: r'is_default')
  bool get isDefault;

  TableTaxCategory._();

  factory TableTaxCategory([void updates(TableTaxCategoryBuilder b)]) =
      _$TableTaxCategory;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableTaxCategoryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableTaxCategory> get serializer =>
      _$TableTaxCategorySerializer();
}

class _$TableTaxCategorySerializer
    implements PrimitiveSerializer<TableTaxCategory> {
  @override
  final Iterable<Type> types = const [TableTaxCategory, _$TableTaxCategory];

  @override
  final String wireName = r'TableTaxCategory';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableTaxCategory object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'tax_code';
    yield object.taxCode == null
        ? null
        : serializers.serialize(
            object.taxCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'is_default';
    yield serializers.serialize(
      object.isDefault,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TableTaxCategory object, {
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
    required TableTaxCategoryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'tax_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.taxCode = valueDes;
          break;
        case r'is_default':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDefault = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableTaxCategory deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableTaxCategoryBuilder();
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
