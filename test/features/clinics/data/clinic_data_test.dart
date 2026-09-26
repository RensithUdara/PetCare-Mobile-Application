import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/network/dio_client.dart';
import 'package:petcare/features/clinics/data/datasources/overpass_data_source.dart';
import 'package:petcare/features/clinics/data/models/clinic_models.dart';
import 'package:petcare/features/clinics/domain/entities/clinic.dart';

void main() {
  test('parseOverpassResponse reads nodes and ways, skips unnamed', () {
    final results = parseOverpassResponse({
      'elements': [
        {
          'type': 'node',
          'id': 1,
          'lat': 6.91,
          'lon': 79.85,
          'tags': {
            'amenity': 'veterinary',
            'name': 'Happy Paws',
            'addr:housenumber': '12',
            'addr:street': 'Galle Road',
            'addr:city': 'Colombo',
            'contact:phone': '+94 11 234 5678',
            'opening_hours': 'Mo-Fr 08:00-18:00',
          },
        },
        {
          'type': 'way',
          'id': 2,
          'center': {'lat': 6.92, 'lon': 79.86},
          'tags': {'amenity': 'veterinary', 'name': 'Pet Care Centre', 'website': 'petcare.lk'},
        },
        {'type': 'node', 'id': 3, 'lat': 6.9, 'lon': 79.8, 'tags': {'amenity': 'veterinary'}},
        {'type': 'way', 'id': 4, 'tags': {'name': 'No coordinates'}},
      ],
    });

    expect(results.map((c) => c.externalId), ['osm:node/1', 'osm:way/2']);
    final first = results.first;
    expect(first.address, '12 Galle Road, Colombo');
    expect(first.phone, '+94 11 234 5678');
    expect(first.openingHours, 'Mo-Fr 08:00-18:00');
    expect(results.last.location, const GeoPoint(6.92, 79.86));
    expect(results.last.website, 'petcare.lk');
  });

  test('parseOverpassResponse tolerates junk', () {
    expect(parseOverpassResponse({}), isEmpty);
    expect(parseOverpassResponse({'elements': 'nope'}), isEmpty);
  });

  test('ClinicModel stores location as lat/lng and round-trips', () {
    const clinic = Clinic(
      id: 'c1',
      ownerId: 'u1',
      name: 'Happy Paws',
      location: GeoPoint(6.91, 79.85),
      isFavorite: true,
    );
    final json = ClinicModel.fromEntity(clinic).toJson();
    expect(json['latitude'], 6.91);
    expect(json.containsKey('id'), isFalse);
    expect(ClinicModel.fromJson({...json, 'id': 'c1'}).toEntity(), clinic);

    final noLocation = ClinicModel.fromJson({'id': 'c2', 'ownerId': 'u1', 'name': 'X'}).toEntity();
    expect(noLocation.location, isNull);
  });

  test('VeterinarianModel round-trips', () {
    const vet = Veterinarian(id: 'v1', ownerId: 'u1', name: 'Dr. Silva', clinicId: 'c1');
    final json = VeterinarianModel.fromEntity(vet).toJson();
    expect(VeterinarianModel.fromJson({...json, 'id': 'v1'}).toEntity(), vet);
  });

  test('failureFromDio maps network errors to friendly messages', () {
    final req = RequestOptions(path: '/');
    expect(
      failureFromDio(DioException(requestOptions: req, type: DioExceptionType.connectionError)).message,
      contains('No internet'),
    );
    expect(
      failureFromDio(DioException(
        requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: req, statusCode: 429),
      )).message,
      contains('Too many requests'),
    );
  });
}
