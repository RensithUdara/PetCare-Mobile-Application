// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vaccination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Vaccination {

/// Empty for a record that has not been saved yet.
 String get id; String get ownerId; String get petId; String get vaccineName; VaccineCategory get category; DateTime get dateAdministered;/// `null` for one-off vaccines that need no booster.
 DateTime? get nextDueDate; String? get veterinarian; String? get clinic; String? get batchNumber; String? get notes;/// `null` disables the reminder.
 ReminderOffset? get reminder; String? get certificateUrl; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Vaccination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VaccinationCopyWith<Vaccination> get copyWith => _$VaccinationCopyWithImpl<Vaccination>(this as Vaccination, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vaccination&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.vaccineName, vaccineName) || other.vaccineName == vaccineName)&&(identical(other.category, category) || other.category == category)&&(identical(other.dateAdministered, dateAdministered) || other.dateAdministered == dateAdministered)&&(identical(other.nextDueDate, nextDueDate) || other.nextDueDate == nextDueDate)&&(identical(other.veterinarian, veterinarian) || other.veterinarian == veterinarian)&&(identical(other.clinic, clinic) || other.clinic == clinic)&&(identical(other.batchNumber, batchNumber) || other.batchNumber == batchNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.reminder, reminder) || other.reminder == reminder)&&(identical(other.certificateUrl, certificateUrl) || other.certificateUrl == certificateUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,petId,vaccineName,category,dateAdministered,nextDueDate,veterinarian,clinic,batchNumber,notes,reminder,certificateUrl,createdAt,updatedAt);

@override
String toString() {
  return 'Vaccination(id: $id, ownerId: $ownerId, petId: $petId, vaccineName: $vaccineName, category: $category, dateAdministered: $dateAdministered, nextDueDate: $nextDueDate, veterinarian: $veterinarian, clinic: $clinic, batchNumber: $batchNumber, notes: $notes, reminder: $reminder, certificateUrl: $certificateUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $VaccinationCopyWith<$Res>  {
  factory $VaccinationCopyWith(Vaccination value, $Res Function(Vaccination) _then) = _$VaccinationCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String petId, String vaccineName, VaccineCategory category, DateTime dateAdministered, DateTime? nextDueDate, String? veterinarian, String? clinic, String? batchNumber, String? notes, ReminderOffset? reminder, String? certificateUrl, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$VaccinationCopyWithImpl<$Res>
    implements $VaccinationCopyWith<$Res> {
  _$VaccinationCopyWithImpl(this._self, this._then);

  final Vaccination _self;
  final $Res Function(Vaccination) _then;

/// Create a copy of Vaccination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? petId = null,Object? vaccineName = null,Object? category = null,Object? dateAdministered = null,Object? nextDueDate = freezed,Object? veterinarian = freezed,Object? clinic = freezed,Object? batchNumber = freezed,Object? notes = freezed,Object? reminder = freezed,Object? certificateUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,vaccineName: null == vaccineName ? _self.vaccineName : vaccineName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as VaccineCategory,dateAdministered: null == dateAdministered ? _self.dateAdministered : dateAdministered // ignore: cast_nullable_to_non_nullable
as DateTime,nextDueDate: freezed == nextDueDate ? _self.nextDueDate : nextDueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,veterinarian: freezed == veterinarian ? _self.veterinarian : veterinarian // ignore: cast_nullable_to_non_nullable
as String?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as String?,batchNumber: freezed == batchNumber ? _self.batchNumber : batchNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,reminder: freezed == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset?,certificateUrl: freezed == certificateUrl ? _self.certificateUrl : certificateUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Vaccination].
extension VaccinationPatterns on Vaccination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vaccination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vaccination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vaccination value)  $default,){
final _that = this;
switch (_that) {
case _Vaccination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vaccination value)?  $default,){
final _that = this;
switch (_that) {
case _Vaccination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String petId,  String vaccineName,  VaccineCategory category,  DateTime dateAdministered,  DateTime? nextDueDate,  String? veterinarian,  String? clinic,  String? batchNumber,  String? notes,  ReminderOffset? reminder,  String? certificateUrl,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vaccination() when $default != null:
return $default(_that.id,_that.ownerId,_that.petId,_that.vaccineName,_that.category,_that.dateAdministered,_that.nextDueDate,_that.veterinarian,_that.clinic,_that.batchNumber,_that.notes,_that.reminder,_that.certificateUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String petId,  String vaccineName,  VaccineCategory category,  DateTime dateAdministered,  DateTime? nextDueDate,  String? veterinarian,  String? clinic,  String? batchNumber,  String? notes,  ReminderOffset? reminder,  String? certificateUrl,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Vaccination():
return $default(_that.id,_that.ownerId,_that.petId,_that.vaccineName,_that.category,_that.dateAdministered,_that.nextDueDate,_that.veterinarian,_that.clinic,_that.batchNumber,_that.notes,_that.reminder,_that.certificateUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String petId,  String vaccineName,  VaccineCategory category,  DateTime dateAdministered,  DateTime? nextDueDate,  String? veterinarian,  String? clinic,  String? batchNumber,  String? notes,  ReminderOffset? reminder,  String? certificateUrl,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Vaccination() when $default != null:
return $default(_that.id,_that.ownerId,_that.petId,_that.vaccineName,_that.category,_that.dateAdministered,_that.nextDueDate,_that.veterinarian,_that.clinic,_that.batchNumber,_that.notes,_that.reminder,_that.certificateUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Vaccination extends Vaccination {
  const _Vaccination({this.id = '', required this.ownerId, required this.petId, required this.vaccineName, this.category = VaccineCategory.core, required this.dateAdministered, this.nextDueDate, this.veterinarian, this.clinic, this.batchNumber, this.notes, this.reminder = ReminderOffset.sevenDays, this.certificateUrl, this.createdAt, this.updatedAt}): super._();
  

/// Empty for a record that has not been saved yet.
@override@JsonKey() final  String id;
@override final  String ownerId;
@override final  String petId;
@override final  String vaccineName;
@override@JsonKey() final  VaccineCategory category;
@override final  DateTime dateAdministered;
/// `null` for one-off vaccines that need no booster.
@override final  DateTime? nextDueDate;
@override final  String? veterinarian;
@override final  String? clinic;
@override final  String? batchNumber;
@override final  String? notes;
/// `null` disables the reminder.
@override@JsonKey() final  ReminderOffset? reminder;
@override final  String? certificateUrl;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Vaccination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VaccinationCopyWith<_Vaccination> get copyWith => __$VaccinationCopyWithImpl<_Vaccination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vaccination&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.vaccineName, vaccineName) || other.vaccineName == vaccineName)&&(identical(other.category, category) || other.category == category)&&(identical(other.dateAdministered, dateAdministered) || other.dateAdministered == dateAdministered)&&(identical(other.nextDueDate, nextDueDate) || other.nextDueDate == nextDueDate)&&(identical(other.veterinarian, veterinarian) || other.veterinarian == veterinarian)&&(identical(other.clinic, clinic) || other.clinic == clinic)&&(identical(other.batchNumber, batchNumber) || other.batchNumber == batchNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.reminder, reminder) || other.reminder == reminder)&&(identical(other.certificateUrl, certificateUrl) || other.certificateUrl == certificateUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,petId,vaccineName,category,dateAdministered,nextDueDate,veterinarian,clinic,batchNumber,notes,reminder,certificateUrl,createdAt,updatedAt);

@override
String toString() {
  return 'Vaccination(id: $id, ownerId: $ownerId, petId: $petId, vaccineName: $vaccineName, category: $category, dateAdministered: $dateAdministered, nextDueDate: $nextDueDate, veterinarian: $veterinarian, clinic: $clinic, batchNumber: $batchNumber, notes: $notes, reminder: $reminder, certificateUrl: $certificateUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VaccinationCopyWith<$Res> implements $VaccinationCopyWith<$Res> {
  factory _$VaccinationCopyWith(_Vaccination value, $Res Function(_Vaccination) _then) = __$VaccinationCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String petId, String vaccineName, VaccineCategory category, DateTime dateAdministered, DateTime? nextDueDate, String? veterinarian, String? clinic, String? batchNumber, String? notes, ReminderOffset? reminder, String? certificateUrl, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$VaccinationCopyWithImpl<$Res>
    implements _$VaccinationCopyWith<$Res> {
  __$VaccinationCopyWithImpl(this._self, this._then);

  final _Vaccination _self;
  final $Res Function(_Vaccination) _then;

/// Create a copy of Vaccination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? petId = null,Object? vaccineName = null,Object? category = null,Object? dateAdministered = null,Object? nextDueDate = freezed,Object? veterinarian = freezed,Object? clinic = freezed,Object? batchNumber = freezed,Object? notes = freezed,Object? reminder = freezed,Object? certificateUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Vaccination(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,vaccineName: null == vaccineName ? _self.vaccineName : vaccineName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as VaccineCategory,dateAdministered: null == dateAdministered ? _self.dateAdministered : dateAdministered // ignore: cast_nullable_to_non_nullable
as DateTime,nextDueDate: freezed == nextDueDate ? _self.nextDueDate : nextDueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,veterinarian: freezed == veterinarian ? _self.veterinarian : veterinarian // ignore: cast_nullable_to_non_nullable
as String?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as String?,batchNumber: freezed == batchNumber ? _self.batchNumber : batchNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,reminder: freezed == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset?,certificateUrl: freezed == certificateUrl ? _self.certificateUrl : certificateUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
