import '../../../../core/errors/failure.dart';
import '../entities/doctor_profile.dart';
import '../logic/doctor_code.dart';
import '../repositories/sharing_repository.dart';

class FindDoctorByCode {
  const FindDoctorByCode(this._repository);

  final SharingRepository _repository;

  Future<DoctorProfile> call(String input) async {
    final code = normalizeDoctorCode(input);
    if (code == null) {
      throw const Failure('Doctor codes look like DR-7K3M9Q. Check the code and try again.', code: 'invalid-code');
    }
    final doctor = await _repository.findDoctorByCode(code);
    if (doctor == null) {
      throw Failure('No approved vet found with code $code.', code: 'not-found');
    }
    return doctor;
  }
}
