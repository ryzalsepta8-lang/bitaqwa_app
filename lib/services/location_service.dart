import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    if (kIsWeb) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    }

    var status = await Permission.location.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      status = await Permission.location.request();
      return status.isGranted;
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  static Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception("Gagal mendapatkan lokasi (timeout)"),
    );
  }

  static Future<Placemark?> getPlacemark(double lat, double lon) async {
    if (!kIsWeb) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) return placemarks.first;
      } catch (_) {}
    }

    // Fallback untuk Web (karena geocoding native tidak mendukung web) atau jika gagal
    try {
      final uri = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=id',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final city = (data['city'] as String?)?.isNotEmpty == true
            ? data['city'] as String
            : (data['locality'] as String?)?.isNotEmpty == true
                ? data['locality'] as String
                : data['principalSubdivision'] as String?;

        return Placemark(
          locality: data['locality'] as String? ?? city,
          subAdministrativeArea: city,
          administrativeArea: data['principalSubdivision'] as String?,
          country: data['countryName'] as String?,
        );
      }
    } catch (_) {}

    return null;
  }

  static String formatLocation(Placemark? place) {
    if (place == null) return "Semarang, Jawa Tengah";
    final sub = place.subAdministrativeArea;
    final loc = place.locality;

    if (sub != null && loc != null && sub != loc) {
      return "$sub, $loc";
    }
    return sub ?? loc ?? place.administrativeArea ?? "Semarang, Jawa Tengah";
  }
}
