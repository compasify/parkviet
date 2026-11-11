//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/bottle_keep_actor.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bottle_keep_event.g.dart';

/// BottleKeepEvent
///
/// Properties:
/// * [id]
/// * [kind]
/// * [levelBefore]
/// * [levelAfter]
/// * [ml]
/// * [workspaceId]
/// * [approvalId]
/// * [actor]
/// * [note]
/// * [createdAt]
@BuiltValue()
abstract class BottleKeepEvent
    implements Built<BottleKeepEvent, BottleKeepEventBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  BottleKeepEventKindEnum get kind;
  // enum kindEnum {  open,  pour,  adjust,  expire,  return,  };

  @BuiltValueField(wireName: r'level_before')
  int? get levelBefore;

  @BuiltValueField(wireName: r'level_after')
  int get levelAfter;

  @BuiltValueField(wireName: r'ml')
  int? get ml;

  @BuiltValueField(wireName: r'workspace_id')
  String? get workspaceId;

  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  @BuiltValueField(wireName: r'actor')
  BottleKeepActor get actor;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  BottleKeepEvent._();

  factory BottleKeepEvent([void updates(BottleKeepEventBuilder b)]) =
      _$BottleKeepEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BottleKeepEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BottleKeepEvent> get serializer =>
      _$BottleKeepEventSerializer();
}

class _$BottleKeepEventSerializer
    implements PrimitiveSerializer<BottleKeepEvent> {
  @override
  final Iterable<Type> types = const [BottleKeepEvent, _$BottleKeepEvent];

  @override
  final String wireName = r'BottleKeepEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BottleKeepEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(BottleKeepEventKindEnum),
    );
    if (object.levelBefore != null) {
      yield r'level_before';
      yield serializers.serialize(
        object.levelBefore,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'level_after';
    yield serializers.serialize(
      object.levelAfter,
      specifiedType: const FullType(int),
    );
    if (object.ml != null) {
      yield r'ml';
      yield serializers.serialize(
        object.ml,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.workspaceId != null) {
      yield r'workspace_id';
      yield serializers.serialize(
        object.workspaceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.approvalId != null) {
      yield r'approval_id';
      yield serializers.serialize(
        object.approvalId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'actor';
    yield serializers.serialize(
      object.actor,
      specifiedType: const FullType(BottleKeepActor),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BottleKeepEvent object, {
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
    required BottleKeepEventBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BottleKeepEventKindEnum),
          ) as BottleKeepEventKindEnum;
          result.kind = valueDes;
          break;
        case r'level_before':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.levelBefore = valueDes;
          break;
        case r'level_after':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.levelAfter = valueDes;
          break;
        case r'ml':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.ml = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.workspaceId = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        case r'actor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BottleKeepActor),
          ) as BottleKeepActor;
          result.actor.replace(valueDes);
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BottleKeepEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BottleKeepEventBuilder();
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

class BottleKeepEventKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const BottleKeepEventKindEnum open = _$bottleKeepEventKindEnum_open;
  @BuiltValueEnumConst(wireName: r'pour')
  static const BottleKeepEventKindEnum pour = _$bottleKeepEventKindEnum_pour;
  @BuiltValueEnumConst(wireName: r'adjust')
  static const BottleKeepEventKindEnum adjust =
      _$bottleKeepEventKindEnum_adjust;
  @BuiltValueEnumConst(wireName: r'expire')
  static const BottleKeepEventKindEnum expire =
      _$bottleKeepEventKindEnum_expire;
  @BuiltValueEnumConst(wireName: r'return')
  static const BottleKeepEventKindEnum return_ =
      _$bottleKeepEventKindEnum_return_;

  static Serializer<BottleKeepEventKindEnum> get serializer =>
      _$bottleKeepEventKindEnumSerializer;

  const BottleKeepEventKindEnum._(String name) : super(name);

  static BuiltSet<BottleKeepEventKindEnum> get values =>
      _$bottleKeepEventKindEnumValues;
  static BottleKeepEventKindEnum valueOf(String name) =>
      _$bottleKeepEventKindEnumValueOf(name);
}
