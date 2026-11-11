//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/context_store.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/context_branch.dart';
import 'package:pos_api/src/model/context_staff.dart';
import 'package:pos_api/src/model/context_administration.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'context.g.dart';

/// Context
///
/// Properties:
/// * [capabilities] - What the signed-in person may do at the selected branch, such as `pos.device.manage`.
/// * [staff]
/// * [store]
/// * [administration]
/// * [einvoiceType] - E-invoice the store issues for completed orders; the counter offers buyer details unless it is none.
/// * [modules] - The selected branch's POS modules by key (such as `fnb.bottle_keep`), on or off.
/// * [branches] - Branches this person may see, with what their screens need.
@BuiltValue()
abstract class Context implements Built<Context, ContextBuilder> {
  /// What the signed-in person may do at the selected branch, such as `pos.device.manage`.
  @BuiltValueField(wireName: r'capabilities')
  BuiltList<String> get capabilities;

  @BuiltValueField(wireName: r'staff')
  ContextStaff get staff;

  @BuiltValueField(wireName: r'store')
  ContextStore get store;

  @BuiltValueField(wireName: r'administration')
  ContextAdministration get administration;

  /// E-invoice the store issues for completed orders; the counter offers buyer details unless it is none.
  @BuiltValueField(wireName: r'einvoice_type')
  ContextEinvoiceTypeEnum? get einvoiceType;
  // enum einvoiceTypeEnum {  none,  cash_register,  coded,  };

  /// The selected branch's POS modules by key (such as `fnb.bottle_keep`), on or off.
  @BuiltValueField(wireName: r'modules')
  BuiltMap<String, bool>? get modules;

  /// Branches this person may see, with what their screens need.
  @BuiltValueField(wireName: r'branches')
  BuiltList<ContextBranch>? get branches;

  Context._();

  factory Context([void updates(ContextBuilder b)]) = _$Context;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContextBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Context> get serializer => _$ContextSerializer();
}

class _$ContextSerializer implements PrimitiveSerializer<Context> {
  @override
  final Iterable<Type> types = const [Context, _$Context];

  @override
  final String wireName = r'Context';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Context object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'capabilities';
    yield serializers.serialize(
      object.capabilities,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'staff';
    yield serializers.serialize(
      object.staff,
      specifiedType: const FullType(ContextStaff),
    );
    yield r'store';
    yield serializers.serialize(
      object.store,
      specifiedType: const FullType(ContextStore),
    );
    yield r'administration';
    yield serializers.serialize(
      object.administration,
      specifiedType: const FullType(ContextAdministration),
    );
    if (object.einvoiceType != null) {
      yield r'einvoice_type';
      yield serializers.serialize(
        object.einvoiceType,
        specifiedType: const FullType(ContextEinvoiceTypeEnum),
      );
    }
    if (object.modules != null) {
      yield r'modules';
      yield serializers.serialize(
        object.modules,
        specifiedType:
            const FullType(BuiltMap, [FullType(String), FullType(bool)]),
      );
    }
    if (object.branches != null) {
      yield r'branches';
      yield serializers.serialize(
        object.branches,
        specifiedType: const FullType(BuiltList, [FullType(ContextBranch)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Context object, {
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
    required ContextBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'capabilities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.capabilities.replace(valueDes);
          break;
        case r'staff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ContextStaff),
          ) as ContextStaff;
          result.staff.replace(valueDes);
          break;
        case r'store':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ContextStore),
          ) as ContextStore;
          result.store.replace(valueDes);
          break;
        case r'administration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ContextAdministration),
          ) as ContextAdministration;
          result.administration.replace(valueDes);
          break;
        case r'einvoice_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ContextEinvoiceTypeEnum),
          ) as ContextEinvoiceTypeEnum?;
          if (valueDes == null) continue;
          result.einvoiceType = valueDes;
          break;
        case r'modules':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType(bool)]),
          ) as BuiltMap<String, bool>?;
          if (valueDes == null) continue;
          result.modules.replace(valueDes);
          break;
        case r'branches':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(ContextBranch)]),
          ) as BuiltList<ContextBranch>?;
          if (valueDes == null) continue;
          result.branches.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Context deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContextBuilder();
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

/// E-invoice the store issues for completed orders; the counter offers buyer details unless it is none.
class ContextEinvoiceTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'none')
  static const ContextEinvoiceTypeEnum none = _$contextEinvoiceTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'cash_register')
  static const ContextEinvoiceTypeEnum cashRegister =
      _$contextEinvoiceTypeEnum_cashRegister;
  @BuiltValueEnumConst(wireName: r'coded')
  static const ContextEinvoiceTypeEnum coded = _$contextEinvoiceTypeEnum_coded;

  static Serializer<ContextEinvoiceTypeEnum> get serializer =>
      _$contextEinvoiceTypeEnumSerializer;

  const ContextEinvoiceTypeEnum._(String name) : super(name);

  static BuiltSet<ContextEinvoiceTypeEnum> get values =>
      _$contextEinvoiceTypeEnumValues;
  static ContextEinvoiceTypeEnum valueOf(String name) =>
      _$contextEinvoiceTypeEnumValueOf(name);
}
