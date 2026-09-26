// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Medication {

/// Empty for a medication that has not been saved yet.
 String get id; String get ownerId; String get petId; String get name;/// Free text, e.g. "1 tablet", "5 ml", "½ chew".
 String get dosage; MedicationFrequency get frequency;/// First dosing day (date only).
 DateTime get startDate;/// Last dosing day, inclusive; `null` for ongoing medication.
 DateTime? get endDate;/// Times of day for doses, sorted.
 List<DoseTime> get doseTimes; bool get remindersEnabled; String? get instructions; String? get veterinarian; String? get notes; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Medication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationCopyWith<Medication> get copyWith => _$MedicationCopyWithImpl<Medication>(this as Medication, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Medication&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.name, name) || other.name == name)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.doseTimes, doseTimes)&&(identical(other.remindersEnabled, remindersEnabled) || other.remindersEnabled == remindersEnabled)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.veterinarian, veterinarian) || other.veterinarian == veterinarian)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,petId,name,dosage,frequency,startDate,endDate,const DeepCollectionEquality().hash(doseTimes),remindersEnabled,instructions,veterinarian,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Medication(id: $id, ownerId: $ownerId, petId: $petId, name: $name, dosage: $dosage, frequency: $frequency, startDate: $startDate, endDate: $endDate, doseTimes: $doseTimes, remindersEnabled: $remindersEnabled, instructions: $instructions, veterinarian: $veterinarian, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MedicationCopyWith<$Res>  {
  factory $MedicationCopyWith(Medication value, $Res Function(Medication) _then) = _$MedicationCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String petId, String name, String dosage, MedicationFrequency frequency, DateTime startDate, DateTime? endDate, List<DoseTime> doseTimes, bool remindersEnabled, String? instructions, String? veterinarian, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$MedicationCopyWithImpl<$Res>
    implements $MedicationCopyWith<$Res> {
  _$MedicationCopyWithImpl(this._self, this._then);

  final Medication _self;
  final $Res Function(Medication) _then;

/// Create a copy of Medication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? petId = null,Object? name = null,Object? dosage = null,Object? frequency = null,Object? startDate = null,Object? endDate = freezed,Object? doseTimes = null,Object? remindersEnabled = null,Object? instructions = freezed,Object? veterinarian = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as MedicationFrequency,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,doseTimes: null == doseTimes ? _self.doseTimes : doseTimes // ignore: cast_nullable_to_non_nullable
as List<DoseTime>,remindersEnabled: null == remindersEnabled ? _self.remindersEnabled : remindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,veterinarian: freezed == veterinarian ? _self.veterinarian : veterinarian // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Medication].
extension MedicationPatterns on Medication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Medication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Medication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Medication value)  $default,){
final _that = this;
switch (_that) {
case _Medication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Medication value)?  $default,){
final _that = this;
switch (_that) {
case _Medication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String petId,  String name,  String dosage,  MedicationFrequency frequency,  DateTime startDate,  DateTime? endDate,  List<DoseTime> doseTimes,  bool remindersEnabled,  String? instructions,  String? veterinarian,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Medication() when $default != null:
return $default(_that.id,_that.ownerId,_that.petId,_that.name,_that.dosage,_that.frequency,_that.startDate,_that.endDate,_that.doseTimes,_that.remindersEnabled,_that.instructions,_that.veterinarian,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String petId,  String name,  String dosage,  MedicationFrequency frequency,  DateTime startDate,  DateTime? endDate,  List<DoseTime> doseTimes,  bool remindersEnabled,  String? instructions,  String? veterinarian,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Medication():
return $default(_that.id,_that.ownerId,_that.petId,_that.name,_that.dosage,_that.frequency,_that.startDate,_that.endDate,_that.doseTimes,_that.remindersEnabled,_that.instructions,_that.veterinarian,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String petId,  String name,  String dosage,  MedicationFrequency frequency,  DateTime startDate,  DateTime? endDate,  List<DoseTime> doseTimes,  bool remindersEnabled,  String? instructions,  String? veterinarian,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Medication() when $default != null:
return $default(_that.id,_that.ownerId,_that.petId,_that.name,_that.dosage,_that.frequency,_that.startDate,_that.endDate,_that.doseTimes,_that.remindersEnabled,_that.instructions,_that.veterinarian,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Medication extends Medication {
  const _Medication({this.id = '', required this.ownerId, required this.petId, required this.name, required this.dosage, this.frequency = MedicationFrequency.onceDaily, required this.startDate, this.endDate, final  List<DoseTime> doseTimes = const <DoseTime>[], this.remindersEnabled = true, this.instructions, this.veterinarian, this.notes, this.createdAt, this.updatedAt}): _doseTimes = doseTimes,super._();
  

/// Empty for a medication that has not been saved yet.
@override@JsonKey() final  String id;
@override final  String ownerId;
@override final  String petId;
@override final  String name;
/// Free text, e.g. "1 tablet", "5 ml", "½ chew".
@override final  String dosage;
@override@JsonKey() final  MedicationFrequency frequency;
/// First dosing day (date only).
@override final  DateTime startDate;
/// Last dosing day, inclusive; `null` for ongoing medication.
@override final  DateTime? endDate;
/// Times of day for doses, sorted.
 final  List<DoseTime> _doseTimes;
/// Times of day for doses, sorted.
@override@JsonKey() List<DoseTime> get doseTimes {
  if (_doseTimes is EqualUnmodifiableListView) return _doseTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_doseTimes);
}

@override@JsonKey() final  bool remindersEnabled;
@override final  String? instructions;
@override final  String? veterinarian;
@override final  String? notes;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Medication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationCopyWith<_Medication> get copyWith => __$MedicationCopyWithImpl<_Medication>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Medication&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.name, name) || other.name == name)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._doseTimes, _doseTimes)&&(identical(other.remindersEnabled, remindersEnabled) || other.remindersEnabled == remindersEnabled)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.veterinarian, veterinarian) || other.veterinarian == veterinarian)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,petId,name,dosage,frequency,startDate,endDate,const DeepCollectionEquality().hash(_doseTimes),remindersEnabled,instructions,veterinarian,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Medication(id: $id, ownerId: $ownerId, petId: $petId, name: $name, dosage: $dosage, frequency: $frequency, startDate: $startDate, endDate: $endDate, doseTimes: $doseTimes, remindersEnabled: $remindersEnabled, instructions: $instructions, veterinarian: $veterinarian, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MedicationCopyWith<$Res> implements $MedicationCopyWith<$Res> {
  factory _$MedicationCopyWith(_Medication value, $Res Function(_Medication) _then) = __$MedicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String petId, String name, String dosage, MedicationFrequency frequency, DateTime startDate, DateTime? endDate, List<DoseTime> doseTimes, bool remindersEnabled, String? instructions, String? veterinarian, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$MedicationCopyWithImpl<$Res>
    implements _$MedicationCopyWith<$Res> {
  __$MedicationCopyWithImpl(this._self, this._then);

  final _Medication _self;
  final $Res Function(_Medication) _then;

/// Create a copy of Medication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? petId = null,Object? name = null,Object? dosage = null,Object? frequency = null,Object? startDate = null,Object? endDate = freezed,Object? doseTimes = null,Object? remindersEnabled = null,Object? instructions = freezed,Object? veterinarian = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Medication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as MedicationFrequency,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,doseTimes: null == doseTimes ? _self._doseTimes : doseTimes // ignore: cast_nullable_to_non_nullable
as List<DoseTime>,remindersEnabled: null == remindersEnabled ? _self.remindersEnabled : remindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,veterinarian: freezed == veterinarian ? _self.veterinarian : veterinarian // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
