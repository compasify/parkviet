// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffSession {

 String get staffId; String? get name; DateTime get expiresAt;
/// Create a copy of StaffSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffSessionCopyWith<StaffSession> get copyWith => _$StaffSessionCopyWithImpl<StaffSession>(this as StaffSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffSession&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.name, name) || other.name == name)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,staffId,name,expiresAt);

@override
String toString() {
  return 'StaffSession(staffId: $staffId, name: $name, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $StaffSessionCopyWith<$Res>  {
  factory $StaffSessionCopyWith(StaffSession value, $Res Function(StaffSession) _then) = _$StaffSessionCopyWithImpl;
@useResult
$Res call({
 String staffId, String? name, DateTime expiresAt
});




}
/// @nodoc
class _$StaffSessionCopyWithImpl<$Res>
    implements $StaffSessionCopyWith<$Res> {
  _$StaffSessionCopyWithImpl(this._self, this._then);

  final StaffSession _self;
  final $Res Function(StaffSession) _then;

/// Create a copy of StaffSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? staffId = null,Object? name = freezed,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffSession].
extension StaffSessionPatterns on StaffSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffSession value)  $default,){
final _that = this;
switch (_that) {
case _StaffSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffSession value)?  $default,){
final _that = this;
switch (_that) {
case _StaffSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String staffId,  String? name,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffSession() when $default != null:
return $default(_that.staffId,_that.name,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String staffId,  String? name,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _StaffSession():
return $default(_that.staffId,_that.name,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String staffId,  String? name,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _StaffSession() when $default != null:
return $default(_that.staffId,_that.name,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _StaffSession implements StaffSession {
  const _StaffSession({required this.staffId, this.name, required this.expiresAt});
  

@override final  String staffId;
@override final  String? name;
@override final  DateTime expiresAt;

/// Create a copy of StaffSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffSessionCopyWith<_StaffSession> get copyWith => __$StaffSessionCopyWithImpl<_StaffSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffSession&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.name, name) || other.name == name)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,staffId,name,expiresAt);

@override
String toString() {
  return 'StaffSession(staffId: $staffId, name: $name, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$StaffSessionCopyWith<$Res> implements $StaffSessionCopyWith<$Res> {
  factory _$StaffSessionCopyWith(_StaffSession value, $Res Function(_StaffSession) _then) = __$StaffSessionCopyWithImpl;
@override @useResult
$Res call({
 String staffId, String? name, DateTime expiresAt
});




}
/// @nodoc
class __$StaffSessionCopyWithImpl<$Res>
    implements _$StaffSessionCopyWith<$Res> {
  __$StaffSessionCopyWithImpl(this._self, this._then);

  final _StaffSession _self;
  final $Res Function(_StaffSession) _then;

/// Create a copy of StaffSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? staffId = null,Object? name = freezed,Object? expiresAt = null,}) {
  return _then(_StaffSession(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
