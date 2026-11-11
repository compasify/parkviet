// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_manual_status_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ResourceManualStatusInputManualStatusEnum
    _$resourceManualStatusInputManualStatusEnum_available =
    const ResourceManualStatusInputManualStatusEnum._('available');
const ResourceManualStatusInputManualStatusEnum
    _$resourceManualStatusInputManualStatusEnum_cleaning =
    const ResourceManualStatusInputManualStatusEnum._('cleaning');
const ResourceManualStatusInputManualStatusEnum
    _$resourceManualStatusInputManualStatusEnum_outOfService =
    const ResourceManualStatusInputManualStatusEnum._('outOfService');

ResourceManualStatusInputManualStatusEnum
    _$resourceManualStatusInputManualStatusEnumValueOf(String name) {
  switch (name) {
    case 'available':
      return _$resourceManualStatusInputManualStatusEnum_available;
    case 'cleaning':
      return _$resourceManualStatusInputManualStatusEnum_cleaning;
    case 'outOfService':
      return _$resourceManualStatusInputManualStatusEnum_outOfService;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResourceManualStatusInputManualStatusEnum>
    _$resourceManualStatusInputManualStatusEnumValues = BuiltSet<
        ResourceManualStatusInputManualStatusEnum>(const <ResourceManualStatusInputManualStatusEnum>[
  _$resourceManualStatusInputManualStatusEnum_available,
  _$resourceManualStatusInputManualStatusEnum_cleaning,
  _$resourceManualStatusInputManualStatusEnum_outOfService,
]);

Serializer<ResourceManualStatusInputManualStatusEnum>
    _$resourceManualStatusInputManualStatusEnumSerializer =
    _$ResourceManualStatusInputManualStatusEnumSerializer();

class _$ResourceManualStatusInputManualStatusEnumSerializer
    implements PrimitiveSerializer<ResourceManualStatusInputManualStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'available': 'available',
    'cleaning': 'cleaning',
    'outOfService': 'out_of_service',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'available': 'available',
    'cleaning': 'cleaning',
    'out_of_service': 'outOfService',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ResourceManualStatusInputManualStatusEnum
  ];
  @override
  final String wireName = 'ResourceManualStatusInputManualStatusEnum';

  @override
  Object serialize(Serializers serializers,
          ResourceManualStatusInputManualStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResourceManualStatusInputManualStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResourceManualStatusInputManualStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResourceManualStatusInput extends ResourceManualStatusInput {
  @override
  final ResourceManualStatusInputManualStatusEnum manualStatus;

  factory _$ResourceManualStatusInput(
          [void Function(ResourceManualStatusInputBuilder)? updates]) =>
      (ResourceManualStatusInputBuilder()..update(updates))._build();

  _$ResourceManualStatusInput._({required this.manualStatus}) : super._();
  @override
  ResourceManualStatusInput rebuild(
          void Function(ResourceManualStatusInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceManualStatusInputBuilder toBuilder() =>
      ResourceManualStatusInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceManualStatusInput &&
        manualStatus == other.manualStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, manualStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResourceManualStatusInput')
          ..add('manualStatus', manualStatus))
        .toString();
  }
}

class ResourceManualStatusInputBuilder
    implements
        Builder<ResourceManualStatusInput, ResourceManualStatusInputBuilder> {
  _$ResourceManualStatusInput? _$v;

  ResourceManualStatusInputManualStatusEnum? _manualStatus;
  ResourceManualStatusInputManualStatusEnum? get manualStatus =>
      _$this._manualStatus;
  set manualStatus(ResourceManualStatusInputManualStatusEnum? manualStatus) =>
      _$this._manualStatus = manualStatus;

  ResourceManualStatusInputBuilder() {
    ResourceManualStatusInput._defaults(this);
  }

  ResourceManualStatusInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _manualStatus = $v.manualStatus;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceManualStatusInput other) {
    _$v = other as _$ResourceManualStatusInput;
  }

  @override
  void update(void Function(ResourceManualStatusInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceManualStatusInput build() => _build();

  _$ResourceManualStatusInput _build() {
    final _$result = _$v ??
        _$ResourceManualStatusInput._(
          manualStatus: BuiltValueNullFieldError.checkNotNull(
              manualStatus, r'ResourceManualStatusInput', 'manualStatus'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
