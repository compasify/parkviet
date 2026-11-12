//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_code.g.dart';

/// TableCode
///
/// Properties:
/// * [id]
/// * [resourceId]
/// * [status]
/// * [rotatedAt]
/// * [revokedAt]
@BuiltValue()
abstract class TableCode implements Built<TableCode, TableCodeBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  @BuiltValueField(wireName: r'status')
  TableCodeStatusEnum get status;
  // enum statusEnum {  active,  revoked,  };

  @BuiltValueField(wireName: r'rotated_at')
  DateTime get rotatedAt;

  @BuiltValueField(wireName: r'revoked_at')
  DateTime? get revokedAt;

  TableCode._();

  factory TableCode([void updates(TableCodeBuilder b)]) = _$TableCode;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableCodeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableCode> get serializer => _$TableCodeSerializer();
}

class _$TableCodeSerializer implements PrimitiveSerializer<TableCode> {
  @override
  final Iterable<Type> types = const [TableCode, _$TableCode];

  @override
  final String wireName = r'TableCode';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableCode object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(TableCodeStatusEnum),
    );
    yield r'rotated_at';
    yield serializers.serialize(
      object.rotatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'revoked_at';
    yield object.revokedAt == null
        ? null
        : serializers.serialize(
            object.revokedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    TableCode object, {
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
    required TableCodeBuilder result,
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
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TableCodeStatusEnum),
          ) as TableCodeStatusEnum;
          result.status = valueDes;
          break;
        case r'rotated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.rotatedAt = valueDes;
          break;
        case r'revoked_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.revokedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableCode deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableCodeBuilder();
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

class TableCodeStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const TableCodeStatusEnum active = _$tableCodeStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'revoked')
  static const TableCodeStatusEnum revoked = _$tableCodeStatusEnum_revoked;

  static Serializer<TableCodeStatusEnum> get serializer =>
      _$tableCodeStatusEnumSerializer;

  const TableCodeStatusEnum._(String name) : super(name);

  static BuiltSet<TableCodeStatusEnum> get values =>
      _$tableCodeStatusEnumValues;
  static TableCodeStatusEnum valueOf(String name) =>
      _$tableCodeStatusEnumValueOf(name);
}
