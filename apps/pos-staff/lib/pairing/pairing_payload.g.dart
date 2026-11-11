// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PairingPayload _$PairingPayloadFromJson(Map<String, dynamic> json) =>
    _PairingPayload(
      v: (json['v'] as num).toInt(),
      kind: json['kind'] as String,
      url: json['url'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$PairingPayloadToJson(_PairingPayload instance) =>
    <String, dynamic>{
      'v': instance.v,
      'kind': instance.kind,
      'url': instance.url,
      'code': instance.code,
    };
