//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/platform_order_line_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_order_input.g.dart';

/// PlatformOrderInput
///
/// Properties:
/// * [editorId]
/// * [registerId]
/// * [branchId] - For a register-less branch.
/// * [platform]
/// * [platformOrderRef]
/// * [pickupCode]
/// * [note]
/// * [lines]
@BuiltValue()
abstract class PlatformOrderInput
    implements Built<PlatformOrderInput, PlatformOrderInputBuilder> {
  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  @BuiltValueField(wireName: r'register_id')
  String? get registerId;

  /// For a register-less branch.
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'platform')
  PlatformOrderInputPlatformEnum get platform;
  // enum platformEnum {  grabfood,  shopeefood,  };

  @BuiltValueField(wireName: r'platform_order_ref')
  String get platformOrderRef;

  @BuiltValueField(wireName: r'pickup_code')
  String? get pickupCode;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'lines')
  BuiltList<PlatformOrderLineInput> get lines;

  PlatformOrderInput._();

  factory PlatformOrderInput([void updates(PlatformOrderInputBuilder b)]) =
      _$PlatformOrderInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformOrderInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformOrderInput> get serializer =>
      _$PlatformOrderInputSerializer();
}

class _$PlatformOrderInputSerializer
    implements PrimitiveSerializer<PlatformOrderInput> {
  @override
  final Iterable<Type> types = const [PlatformOrderInput, _$PlatformOrderInput];

  @override
  final String wireName = r'PlatformOrderInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformOrderInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
    if (object.registerId != null) {
      yield r'register_id';
      yield serializers.serialize(
        object.registerId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(PlatformOrderInputPlatformEnum),
    );
    yield r'platform_order_ref';
    yield serializers.serialize(
      object.platformOrderRef,
      specifiedType: const FullType(String),
    );
    if (object.pickupCode != null) {
      yield r'pickup_code';
      yield serializers.serialize(
        object.pickupCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType:
          const FullType(BuiltList, [FullType(PlatformOrderLineInput)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformOrderInput object, {
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
    required PlatformOrderInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorId = valueDes;
          break;
        case r'register_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.registerId = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformOrderInputPlatformEnum),
          ) as PlatformOrderInputPlatformEnum;
          result.platform = valueDes;
          break;
        case r'platform_order_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.platformOrderRef = valueDes;
          break;
        case r'pickup_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pickupCode = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(PlatformOrderLineInput)]),
          ) as BuiltList<PlatformOrderLineInput>;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformOrderInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformOrderInputBuilder();
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

class PlatformOrderInputPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'grabfood')
  static const PlatformOrderInputPlatformEnum grabfood =
      _$platformOrderInputPlatformEnum_grabfood;
  @BuiltValueEnumConst(wireName: r'shopeefood')
  static const PlatformOrderInputPlatformEnum shopeefood =
      _$platformOrderInputPlatformEnum_shopeefood;

  static Serializer<PlatformOrderInputPlatformEnum> get serializer =>
      _$platformOrderInputPlatformEnumSerializer;

  const PlatformOrderInputPlatformEnum._(String name) : super(name);

  static BuiltSet<PlatformOrderInputPlatformEnum> get values =>
      _$platformOrderInputPlatformEnumValues;
  static PlatformOrderInputPlatformEnum valueOf(String name) =>
      _$platformOrderInputPlatformEnumValueOf(name);
}
