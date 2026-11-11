// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pairing_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PairingPayload {

 int get v; String get kind; String get url; String get code;
/// Create a copy of PairingPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingPayloadCopyWith<PairingPayload> get copyWith => _$PairingPayloadCopyWithImpl<PairingPayload>(this as PairingPayload, _$identity);

  /// Serializes this PairingPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingPayload&&(identical(other.v, v) || other.v == v)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.url, url) || other.url == url)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,v,kind,url,code);

@override
String toString() {
  return 'PairingPayload(v: $v, kind: $kind, url: $url, code: $code)';
}


}

/// @nodoc
abstract mixin class $PairingPayloadCopyWith<$Res>  {
  factory $PairingPayloadCopyWith(PairingPayload value, $Res Function(PairingPayload) _then) = _$PairingPayloadCopyWithImpl;
@useResult
$Res call({
 int v, String kind, String url, String code
});




}
/// @nodoc
class _$PairingPayloadCopyWithImpl<$Res>
    implements $PairingPayloadCopyWith<$Res> {
  _$PairingPayloadCopyWithImpl(this._self, this._then);

  final PairingPayload _self;
  final $Res Function(PairingPayload) _then;

/// Create a copy of PairingPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? v = null,Object? kind = null,Object? url = null,Object? code = null,}) {
  return _then(_self.copyWith(
v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingPayload].
extension PairingPayloadPatterns on PairingPayload {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairingPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairingPayload() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairingPayload value)  $default,){
final _that = this;
switch (_that) {
case _PairingPayload():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairingPayload value)?  $default,){
final _that = this;
switch (_that) {
case _PairingPayload() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int v,  String kind,  String url,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairingPayload() when $default != null:
return $default(_that.v,_that.kind,_that.url,_that.code);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int v,  String kind,  String url,  String code)  $default,) {final _that = this;
switch (_that) {
case _PairingPayload():
return $default(_that.v,_that.kind,_that.url,_that.code);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int v,  String kind,  String url,  String code)?  $default,) {final _that = this;
switch (_that) {
case _PairingPayload() when $default != null:
return $default(_that.v,_that.kind,_that.url,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PairingPayload implements PairingPayload {
  const _PairingPayload({required this.v, required this.kind, required this.url, required this.code});
  factory _PairingPayload.fromJson(Map<String, dynamic> json) => _$PairingPayloadFromJson(json);

@override final  int v;
@override final  String kind;
@override final  String url;
@override final  String code;

/// Create a copy of PairingPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairingPayloadCopyWith<_PairingPayload> get copyWith => __$PairingPayloadCopyWithImpl<_PairingPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PairingPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairingPayload&&(identical(other.v, v) || other.v == v)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.url, url) || other.url == url)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,v,kind,url,code);

@override
String toString() {
  return 'PairingPayload(v: $v, kind: $kind, url: $url, code: $code)';
}


}

/// @nodoc
abstract mixin class _$PairingPayloadCopyWith<$Res> implements $PairingPayloadCopyWith<$Res> {
  factory _$PairingPayloadCopyWith(_PairingPayload value, $Res Function(_PairingPayload) _then) = __$PairingPayloadCopyWithImpl;
@override @useResult
$Res call({
 int v, String kind, String url, String code
});




}
/// @nodoc
class __$PairingPayloadCopyWithImpl<$Res>
    implements _$PairingPayloadCopyWith<$Res> {
  __$PairingPayloadCopyWithImpl(this._self, this._then);

  final _PairingPayload _self;
  final $Res Function(_PairingPayload) _then;

/// Create a copy of PairingPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? v = null,Object? kind = null,Object? url = null,Object? code = null,}) {
  return _then(_PairingPayload(
v: null == v ? _self.v : v // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
