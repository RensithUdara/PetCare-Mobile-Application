// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Appointment {

/// Empty for an appointment that has not been saved yet.
 String get id; String get ownerId; String get petId;/// Local date and time of the visit.
 DateTime get dateTime; AppointmentType get type; AppointmentStatus get status; String? get clinic; String? get veterinarian; String? get reason; String? get notes;/// `null` disables the reminder.
 ReminderOffset? get reminder; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentCopyWith<Appointment> get copyWith => _$AppointmentCopyWithImpl<Appointment>(this as Appointment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Appointment&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.clinic, clinic) || other.clinic == clinic)&&(identical(other.veterinarian, veterinarian) || other.veterinarian == veterinarian)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.reminder, reminder) || other.reminder == reminder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,petId,dateTime,type,status,clinic,veterinarian,reason,notes,reminder,createdAt,updatedAt);

@override
String toString() {
  return 'Appointment(id: $id, ownerId: $ownerId, petId: $petId, dateTime: $dateTime, type: $type, status: $status, clinic: $clinic, veterinarian: $veterinarian, reason: $reason, notes: $notes, reminder: $reminder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AppointmentCopyWith<$Res>  {
  factory $AppointmentCopyWith(Appointment value, $Res Function(Appointment) _then) = _$AppointmentCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String petId, DateTime dateTime, AppointmentType type, AppointmentStatus status, String? clinic, String? veterinarian, String? reason, String? notes, ReminderOffset? reminder, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AppointmentCopyWithImpl<$Res>
    implements $AppointmentCopyWith<$Res> {
  _$AppointmentCopyWithImpl(this._self, this._then);

  final Appointment _self;
  final $Res Function(Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? petId = null,Object? dateTime = null,Object? type = null,Object? status = null,Object? clinic = freezed,Object? veterinarian = freezed,Object? reason = freezed,Object? notes = freezed,Object? reminder = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AppointmentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppointmentStatus,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as String?,veterinarian: freezed == veterinarian ? _self.veterinarian : veterinarian // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,reminder: freezed == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Appointment].
extension AppointmentPatterns on Appointment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Appointment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Appointment value)  $default,){
final _that = this;
switch (_that) {
case _Appointment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Appointment value)?  $default,){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String petId,  DateTime dateTime,  AppointmentType type,  AppointmentStatus status,  String? clinic,  String? veterinarian,  String? reason,  String? notes,  ReminderOffset? reminder,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.ownerId,_that.petId,_that.dateTime,_that.type,_that.status,_that.clinic,_that.veterinarian,_that.reason,_that.notes,_that.reminder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String petId,  DateTime dateTime,  AppointmentType type,  AppointmentStatus status,  String? clinic,  String? veterinarian,  String? reason,  String? notes,  ReminderOffset? reminder,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Appointment():
return $default(_that.id,_that.ownerId,_that.petId,_that.dateTime,_that.type,_that.status,_that.clinic,_that.veterinarian,_that.reason,_that.notes,_that.reminder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String petId,  DateTime dateTime,  AppointmentType type,  AppointmentStatus status,  String? clinic,  String? veterinarian,  String? reason,  String? notes,  ReminderOffset? reminder,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.ownerId,_that.petId,_that.dateTime,_that.type,_that.status,_that.clinic,_that.veterinarian,_that.reason,_that.notes,_that.reminder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Appointment extends Appointment {
  const _Appointment({this.id = '', required this.ownerId, required this.petId, required this.dateTime, this.type = AppointmentType.routineCheckup, this.status = AppointmentStatus.scheduled, this.clinic, this.veterinarian, this.reason, this.notes, this.reminder = ReminderOffset.oneDay, this.createdAt, this.updatedAt}): super._();
  

/// Empty for an appointment that has not been saved yet.
@override@JsonKey() final  String id;
@override final  String ownerId;
@override final  String petId;
/// Local date and time of the visit.
@override final  DateTime dateTime;
@override@JsonKey() final  AppointmentType type;
@override@JsonKey() final  AppointmentStatus status;
@override final  String? clinic;
@override final  String? veterinarian;
@override final  String? reason;
@override final  String? notes;
/// `null` disables the reminder.
@override@JsonKey() final  ReminderOffset? reminder;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentCopyWith<_Appointment> get copyWith => __$AppointmentCopyWithImpl<_Appointment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Appointment&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.clinic, clinic) || other.clinic == clinic)&&(identical(other.veterinarian, veterinarian) || other.veterinarian == veterinarian)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.reminder, reminder) || other.reminder == reminder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,petId,dateTime,type,status,clinic,veterinarian,reason,notes,reminder,createdAt,updatedAt);

@override
String toString() {
  return 'Appointment(id: $id, ownerId: $ownerId, petId: $petId, dateTime: $dateTime, type: $type, status: $status, clinic: $clinic, veterinarian: $veterinarian, reason: $reason, notes: $notes, reminder: $reminder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppointmentCopyWith<$Res> implements $AppointmentCopyWith<$Res> {
  factory _$AppointmentCopyWith(_Appointment value, $Res Function(_Appointment) _then) = __$AppointmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String petId, DateTime dateTime, AppointmentType type, AppointmentStatus status, String? clinic, String? veterinarian, String? reason, String? notes, ReminderOffset? reminder, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AppointmentCopyWithImpl<$Res>
    implements _$AppointmentCopyWith<$Res> {
  __$AppointmentCopyWithImpl(this._self, this._then);

  final _Appointment _self;
  final $Res Function(_Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? petId = null,Object? dateTime = null,Object? type = null,Object? status = null,Object? clinic = freezed,Object? veterinarian = freezed,Object? reason = freezed,Object? notes = freezed,Object? reminder = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Appointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AppointmentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppointmentStatus,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as String?,veterinarian: freezed == veterinarian ? _self.veterinarian : veterinarian // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,reminder: freezed == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
