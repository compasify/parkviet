//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_snapshot_register.g.dart';

/// OfflineSnapshotRegister
///
/// Properties:
/// * [id]
/// * [name]
/// * [code]
@BuiltValue()
abstract class OfflineSnapshotRegister
    implements Built<OfflineSnapshotRegister, OfflineSnapshotRegisterBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'code')
  String get code;

  OfflineSnapshotRegister._();

  factory OfflineSnapshotRegister(
          [void updates(OfflineSnapshotRegisterBuilder b)]) =
      _$OfflineSnapshotRegister;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSnapshotRegisterBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSnapshotRegister> get serializer =>
      _$OfflineSnapshotRegisterSerializer();
}

class _$OfflineSnapshotRegisterSerializer
    implements PrimitiveSerializer<OfflineSnapshotRegister> {
  @override
  final Iterable<Type> types = const [
    OfflineSnapshotRegister,
    _$OfflineSnapshotRegister
  ];

  @override
  final String wireName = r'OfflineSnapshotRegister';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSnapshotRegister object, {
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
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSnapshotRegister object, {
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
    required OfflineSnapshotRegisterBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSnapshotRegister deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSnapshotRegisterBuilder();
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
