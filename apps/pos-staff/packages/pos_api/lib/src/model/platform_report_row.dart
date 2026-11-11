//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_report_row.g.dart';

/// PlatformReportRow
///
/// Properties:
/// * [businessDate]
/// * [platform]
/// * [orders]
/// * [gross]
/// * [commission]
/// * [net]
/// * [unsettled] - Net of the orders not settled yet.
/// * [commissionEstimated] - Commission of unsettled orders, at the branch rate.
/// * [commissionActual] - Commission of settled orders, as the platform kept it.
@BuiltValue()
abstract class PlatformReportRow
    implements Built<PlatformReportRow, PlatformReportRowBuilder> {
  @BuiltValueField(wireName: r'business_date')
  Date get businessDate;

  @BuiltValueField(wireName: r'platform')
  PlatformReportRowPlatformEnum get platform;
  // enum platformEnum {  grabfood,  shopeefood,  };

  @BuiltValueField(wireName: r'orders')
  int get orders;

  @BuiltValueField(wireName: r'gross')
  String get gross;

  @BuiltValueField(wireName: r'commission')
  String get commission;

  @BuiltValueField(wireName: r'net')
  String get net;

  /// Net of the orders not settled yet.
  @BuiltValueField(wireName: r'unsettled')
  String get unsettled;

  /// Commission of unsettled orders, at the branch rate.
  @BuiltValueField(wireName: r'commission_estimated')
  String get commissionEstimated;

  /// Commission of settled orders, as the platform kept it.
  @BuiltValueField(wireName: r'commission_actual')
  String get commissionActual;

  PlatformReportRow._();

  factory PlatformReportRow([void updates(PlatformReportRowBuilder b)]) =
      _$PlatformReportRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformReportRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformReportRow> get serializer =>
      _$PlatformReportRowSerializer();
}

class _$PlatformReportRowSerializer
    implements PrimitiveSerializer<PlatformReportRow> {
  @override
  final Iterable<Type> types = const [PlatformReportRow, _$PlatformReportRow];

  @override
  final String wireName = r'PlatformReportRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformReportRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'business_date';
    yield serializers.serialize(
      object.businessDate,
      specifiedType: const FullType(Date),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(PlatformReportRowPlatformEnum),
    );
    yield r'orders';
    yield serializers.serialize(
      object.orders,
      specifiedType: const FullType(int),
    );
    yield r'gross';
    yield serializers.serialize(
      object.gross,
      specifiedType: const FullType(String),
    );
    yield r'commission';
    yield serializers.serialize(
      object.commission,
      specifiedType: const FullType(String),
    );
    yield r'net';
    yield serializers.serialize(
      object.net,
      specifiedType: const FullType(String),
    );
    yield r'unsettled';
    yield serializers.serialize(
      object.unsettled,
      specifiedType: const FullType(String),
    );
    yield r'commission_estimated';
    yield serializers.serialize(
      object.commissionEstimated,
      specifiedType: const FullType(String),
    );
    yield r'commission_actual';
    yield serializers.serialize(
      object.commissionActual,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformReportRow object, {
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
    required PlatformReportRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'business_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.businessDate = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformReportRowPlatformEnum),
          ) as PlatformReportRowPlatformEnum;
          result.platform = valueDes;
          break;
        case r'orders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.orders = valueDes;
          break;
        case r'gross':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gross = valueDes;
          break;
        case r'commission':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commission = valueDes;
          break;
        case r'net':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.net = valueDes;
          break;
        case r'unsettled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unsettled = valueDes;
          break;
        case r'commission_estimated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commissionEstimated = valueDes;
          break;
        case r'commission_actual':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commissionActual = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformReportRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformReportRowBuilder();
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

class PlatformReportRowPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'grabfood')
  static const PlatformReportRowPlatformEnum grabfood =
      _$platformReportRowPlatformEnum_grabfood;
  @BuiltValueEnumConst(wireName: r'shopeefood')
  static const PlatformReportRowPlatformEnum shopeefood =
      _$platformReportRowPlatformEnum_shopeefood;

  static Serializer<PlatformReportRowPlatformEnum> get serializer =>
      _$platformReportRowPlatformEnumSerializer;

  const PlatformReportRowPlatformEnum._(String name) : super(name);

  static BuiltSet<PlatformReportRowPlatformEnum> get values =>
      _$platformReportRowPlatformEnumValues;
  static PlatformReportRowPlatformEnum valueOf(String name) =>
      _$platformReportRowPlatformEnumValueOf(name);
}
