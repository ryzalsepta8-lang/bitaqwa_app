import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PrayerService {
  static Future<List<dynamic>> fetchJadwalSholat(
    String city,
    String month,
    String year,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = "prayer_aladhan_$city-$year-$month";

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      return json.decode(cachedData) as List<dynamic>;
    }

    final formattedMonth = month.padLeft(2, '0');
    // Aladhan API mendukung CORS (Access-Control-Allow-Origin: *)
    // method=11: Majlis Ugama Islam Singapura / Kemenag friendly
    final url =
        'https://api.aladhan.com/v1/calendarByAddress/$year/$formattedMonth?address=${Uri.encodeComponent(city)}&method=11';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] is List) {
          final items = data['data'] as List<dynamic>;

          final normalizedItems = items.map((e) {
            final timings = e['timings'] as Map<String, dynamic>;
            final gregorian = e['date']['gregorian'] as Map<String, dynamic>;

            // Tanggal format: DD-MM-YYYY -> YYYY-MM-DD
            final dateStr = gregorian['date'] as String;
            final dateParts = dateStr.split('-');
            final formattedDate =
                "${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}";

            // Aladhan timings string format: "04:06 (WIB)" atau "04:06"
            String cleanTime(dynamic t) {
              if (t == null) return "00:00";
              final str = t.toString().trim();
              return str.split(' ').first;
            }

            final shubuh = cleanTime(timings['Fajr']);
            final terbit = cleanTime(timings['Sunrise']);
            final imsyak = timings['Imsak'] != null
                ? cleanTime(timings['Imsak'])
                : _adjustTime(shubuh, -10);
            final dhuha = _adjustTime(terbit, 20);

            return {
              'tanggal': formattedDate,
              'imsyak': imsyak,
              'shubuh': shubuh,
              'terbit': terbit,
              'dhuha': dhuha,
              'dzuhur': cleanTime(timings['Dhuhr']),
              'ashr': cleanTime(timings['Asr']),
              'magrib': cleanTime(timings['Maghrib']),
              'isya': cleanTime(timings['Isha']),
            };
          }).toList();

          await prefs.setString(cacheKey, json.encode(normalizedItems));
          return normalizedItems;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetch Prayer Times: $e");
    }

    throw Exception('Gagal memuat jadwal sholat untuk $city');
  }



  static String _adjustTime(String hhmm, int minutes) {
    try {
      final format = DateFormat("HH:mm");
      final time = format.parse(hhmm);
      final adjusted = time.add(Duration(minutes: minutes));
      return format.format(adjusted);
    } catch (_) {
      return hhmm;
    }
  }

  static Future<List<String>> fetchCitySuggestions() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://raw.githubusercontent.com/lakuapik/jadwalsholatorg/master/kota.json',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static Future<String> getClosestCity(String userCityName) async {
    // MuslimSalat allows direct city names, no need for the old GitHub list lookup
    return userCityName;
  }

  static Map<String, dynamic>? calculateNextPrayer(List<dynamic>? jadwal) {
    if (jadwal == null || jadwal.isEmpty) return null;

    final now = DateTime.now();
    final hhmmFormat = DateFormat('HH:mm');
    final todayDate = DateFormat('yyyy-MM-dd').format(now);

    final todaySchedule = jadwal
        .where((e) => e['tanggal'] == todayDate)
        .firstOrNull;
    if (todaySchedule == null) {
      // If today is not in current month list, fallback to first item
      return null;
    }

    DateTime parseTime(String hhmm) {
      final t = hhmmFormat.parse(hhmm);
      return DateTime(now.year, now.month, now.day, t.hour, t.minute);
    }

    final prayers = {
      "Subuh": parseTime(todaySchedule['shubuh']),
      "Dzuhur": parseTime(todaySchedule['dzuhur']),
      "Ashar": parseTime(todaySchedule['ashr']),
      "Maghrib": parseTime(todaySchedule['magrib']),
      "Isya": parseTime(todaySchedule['isya']),
    };

    String nextName = "Subuh";
    Duration? closest;

    prayers.forEach((name, time) {
      final diff = time.difference(now);
      if (diff > Duration.zero && (closest == null || diff < closest!)) {
        closest = diff;
        nextName = name;
      }
    });

    // If all prayers today are passed, next is Subuh tomorrow (simplification)
    final nextTimeText = closest != null
        ? hhmmFormat.format(prayers[nextName]!)
        : "N/A";

    return {
      "nextName": nextName,
      "nextTime": nextTimeText,
      "remaining": closest,
      "todaySchedule": todaySchedule,
    };
  }
}
