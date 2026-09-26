import '../../../pets/domain/entities/pet.dart';
import '../entities/vaccination.dart';

/// Well-known vaccines offered as quick suggestions in the form.
class CommonVaccine {
  const CommonVaccine(this.name, this.category, {this.boosterMonths});

  final String name;
  final VaccineCategory category;

  /// Typical interval until the next dose, if any.
  final int? boosterMonths;
}

const _common = <PetSpecies, List<CommonVaccine>>{
  PetSpecies.dog: [
    CommonVaccine('Rabies', VaccineCategory.core, boosterMonths: 12),
    CommonVaccine('DHPP', VaccineCategory.core, boosterMonths: 12),
    CommonVaccine('Leptospirosis', VaccineCategory.nonCore, boosterMonths: 12),
    CommonVaccine('Bordetella', VaccineCategory.nonCore, boosterMonths: 12),
    CommonVaccine('Canine Influenza', VaccineCategory.nonCore, boosterMonths: 12),
  ],
  PetSpecies.cat: [
    CommonVaccine('Rabies', VaccineCategory.core, boosterMonths: 12),
    CommonVaccine('FVRCP', VaccineCategory.core, boosterMonths: 12),
    CommonVaccine('FeLV', VaccineCategory.nonCore, boosterMonths: 12),
  ],
  PetSpecies.rabbit: [
    CommonVaccine('RHDV2', VaccineCategory.core, boosterMonths: 12),
    CommonVaccine('Myxomatosis', VaccineCategory.core, boosterMonths: 12),
  ],
  PetSpecies.bird: [
    CommonVaccine('Polyomavirus', VaccineCategory.nonCore, boosterMonths: 12),
  ],
};

List<CommonVaccine> commonVaccinesFor(PetSpecies species) => _common[species] ?? const [];

/// Adds [months] to [date], clamping to the last day of the target month
/// (e.g. 31 Jan + 1 month → 28/29 Feb).
DateTime addMonths(DateTime date, int months) {
  final totalMonths = date.month - 1 + months;
  final year = date.year + totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, date.day > lastDay ? lastDay : date.day);
}
