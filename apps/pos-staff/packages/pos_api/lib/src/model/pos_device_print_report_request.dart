//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_print_report_request.g.dart';

/// PosDevicePrintReportRequest
///
/// Properties:
/// * [attempt]
/// * [status]
/// * [error]
@BuiltValue()
abstract class PosDevicePrintReportRequest
    implements
        Built<PosDevicePrintReportRequest, PosDevicePrintReportRequestBuilder> {
  @BuiltValueField(wireName: r'attempt')
  int get attempt;

  @BuiltValueField(wireName: r'status')
  PosDevicePrintReportRequestStatusEnum get status;
  // enum statusEnum {  printed,  failed,  };

  @BuiltValueField(wireName: r'error')
  String? get error;

  PosDevicePrintReportRequest._();

  factory PosDevicePrintReportRequest(
          [void updates(PosDevicePrintReportRequestBuilder b)]) =
      _$PosDevicePrintReportRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDevicePrintReportRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDevicePrintReportRequest> get serializer =>
      _$PosDevicePrintReportRequestSerializer();
}

class _$PosDevicePrintReportRequestSerializer
    implements PrimitiveSerializer<PosDevicePrintReportRequest> {
  @override
  final Iterable<Type> types = const [
    PosDevicePrintReportRequest,
    _$PosDevicePrintReportRequest
  ];

  @override
  final String wireName = r'PosDevicePrintReportRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDevicePrintReportRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'attempt';
    yield serializers.serialize(
      object.attempt,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PosDevicePrintReportRequestStatusEnum),
    );
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDevicePrintReportRequest object, {
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
    required PosDevicePrintReportRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'attempt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attempt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PosDevicePrintReportRequestStatusEnum),
          ) as PosDevicePrintReportRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.error = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosDevicePrintReportRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDevicePrintReportRequestBuilder();
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

class PosDevicePrintReportRequestStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'printed')
  static const PosDevicePrintReportRequestStatusEnum printed =
      _$posDevicePrintReportRequestStatusEnum_printed;
  @BuiltValueEnumConst(wireName: r'failed')
  static const PosDevicePrintReportRequestStatusEnum failed =
      _$posDevicePrintReportRequestStatusEnum_failed;

  static Serializer<PosDevicePrintReportRequestStatusEnum> get serializer =>
      _$posDevicePrintReportRequestStatusEnumSerializer;

  const PosDevicePrintReportRequestStatusEnum._(String name) : super(name);

  static BuiltSet<PosDevicePrintReportRequestStatusEnum> get values =>
      _$posDevicePrintReportRequestStatusEnumValues;
  static PosDevicePrintReportRequestStatusEnum valueOf(String name) =>
      _$posDevicePrintReportRequestStatusEnumValueOf(name);
}
