//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_register_ref.g.dart';

/// KioskRegisterRef
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [name]
/// * [code]
/// * [kind]
/// * [status]
@BuiltValue()
abstract class KioskRegisterRef
    implements Built<KioskRegisterRef, KioskRegisterRefBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'kind')
  KioskRegisterRefKindEnum get kind;
  // enum kindEnum {  counter,  kiosk,  };

  @BuiltValueField(wireName: r'status')
  String get status;

  KioskRegisterRef._();

  factory KioskRegisterRef([void updates(KioskRegisterRefBuilder b)]) =
      _$KioskRegisterRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskRegisterRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskRegisterRef> get serializer =>
      _$KioskRegisterRefSerializer();
}

class _$KioskRegisterRefSerializer
    implements PrimitiveSerializer<KioskRegisterRef> {
  @override
  final Iterable<Type> types = const [KioskRegisterRef, _$KioskRegisterRef];

  @override
  final String wireName = r'KioskRegisterRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskRegisterRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(KioskRegisterRefKindEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskRegisterRef object, {
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
    required KioskRegisterRefBuilder result,
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
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KioskRegisterRefKindEnum),
          ) as KioskRegisterRefKindEnum;
          result.kind = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskRegisterRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskRegisterRefBuilder();
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

class KioskRegisterRefKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'counter')
  static const KioskRegisterRefKindEnum counter =
      _$kioskRegisterRefKindEnum_counter;
  @BuiltValueEnumConst(wireName: r'kiosk')
  static const KioskRegisterRefKindEnum kiosk =
      _$kioskRegisterRefKindEnum_kiosk;

  static Serializer<KioskRegisterRefKindEnum> get serializer =>
      _$kioskRegisterRefKindEnumSerializer;

  const KioskRegisterRefKindEnum._(String name) : super(name);

  static BuiltSet<KioskRegisterRefKindEnum> get values =>
      _$kioskRegisterRefKindEnumValues;
  static KioskRegisterRefKindEnum valueOf(String name) =>
      _$kioskRegisterRefKindEnumValueOf(name);
}
