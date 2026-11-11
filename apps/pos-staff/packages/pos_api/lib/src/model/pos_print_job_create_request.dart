//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_print_job_create_request.g.dart';

/// PosPrintJobCreateRequest
///
/// Properties:
/// * [kind]
/// * [printerId]
/// * [receiptId]
/// * [workspaceId]
/// * [receiptTemplateId]
/// * [templateVersion]
/// * [paper]
@BuiltValue()
abstract class PosPrintJobCreateRequest
    implements
        Built<PosPrintJobCreateRequest, PosPrintJobCreateRequestBuilder> {
  @BuiltValueField(wireName: r'kind')
  PosPrintJobCreateRequestKindEnum get kind;
  // enum kindEnum {  receipt,  prebill,  };

  @BuiltValueField(wireName: r'printer_id')
  String get printerId;

  @BuiltValueField(wireName: r'receipt_id')
  String? get receiptId;

  @BuiltValueField(wireName: r'workspace_id')
  String? get workspaceId;

  @BuiltValueField(wireName: r'receipt_template_id')
  String? get receiptTemplateId;

  @BuiltValueField(wireName: r'template_version')
  String? get templateVersion;

  @BuiltValueField(wireName: r'paper')
  String? get paper;

  PosPrintJobCreateRequest._();

  factory PosPrintJobCreateRequest(
          [void updates(PosPrintJobCreateRequestBuilder b)]) =
      _$PosPrintJobCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosPrintJobCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosPrintJobCreateRequest> get serializer =>
      _$PosPrintJobCreateRequestSerializer();
}

class _$PosPrintJobCreateRequestSerializer
    implements PrimitiveSerializer<PosPrintJobCreateRequest> {
  @override
  final Iterable<Type> types = const [
    PosPrintJobCreateRequest,
    _$PosPrintJobCreateRequest
  ];

  @override
  final String wireName = r'PosPrintJobCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosPrintJobCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(PosPrintJobCreateRequestKindEnum),
    );
    yield r'printer_id';
    yield serializers.serialize(
      object.printerId,
      specifiedType: const FullType(String),
    );
    if (object.receiptId != null) {
      yield r'receipt_id';
      yield serializers.serialize(
        object.receiptId,
        specifiedType: const FullType(String),
      );
    }
    if (object.workspaceId != null) {
      yield r'workspace_id';
      yield serializers.serialize(
        object.workspaceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.receiptTemplateId != null) {
      yield r'receipt_template_id';
      yield serializers.serialize(
        object.receiptTemplateId,
        specifiedType: const FullType(String),
      );
    }
    if (object.templateVersion != null) {
      yield r'template_version';
      yield serializers.serialize(
        object.templateVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.paper != null) {
      yield r'paper';
      yield serializers.serialize(
        object.paper,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosPrintJobCreateRequest object, {
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
    required PosPrintJobCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PosPrintJobCreateRequestKindEnum),
          ) as PosPrintJobCreateRequestKindEnum;
          result.kind = valueDes;
          break;
        case r'printer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.printerId = valueDes;
          break;
        case r'receipt_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.receiptId = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.workspaceId = valueDes;
          break;
        case r'receipt_template_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.receiptTemplateId = valueDes;
          break;
        case r'template_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.templateVersion = valueDes;
          break;
        case r'paper':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.paper = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosPrintJobCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosPrintJobCreateRequestBuilder();
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

class PosPrintJobCreateRequestKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'receipt')
  static const PosPrintJobCreateRequestKindEnum receipt =
      _$posPrintJobCreateRequestKindEnum_receipt;
  @BuiltValueEnumConst(wireName: r'prebill')
  static const PosPrintJobCreateRequestKindEnum prebill =
      _$posPrintJobCreateRequestKindEnum_prebill;

  static Serializer<PosPrintJobCreateRequestKindEnum> get serializer =>
      _$posPrintJobCreateRequestKindEnumSerializer;

  const PosPrintJobCreateRequestKindEnum._(String name) : super(name);

  static BuiltSet<PosPrintJobCreateRequestKindEnum> get values =>
      _$posPrintJobCreateRequestKindEnumValues;
  static PosPrintJobCreateRequestKindEnum valueOf(String name) =>
      _$posPrintJobCreateRequestKindEnumValueOf(name);
}
