import 'dart:io'; // Untuk HttpOverrides (izin bypass SSL)
import 'package:bitaqwa/Presentation/dashboard_page.dart';
import 'package:bitaqwa/Presentation/doa_page.dart';
import 'package:bitaqwa/Presentation/kajian_page.dart';
import 'package:bitaqwa/Presentation/sholat_page.dart';
import 'package:bitaqwa/Presentation/zakat_page.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:home_widget/home_widget.dart';
import 'widget/prayer_widget_updater.dart';

// Callback untuk background refresh (dipanggil oleh Android bila tombol Refresh di widget ditekan)
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'refresh') {
    await PrayerWidgetUpdater.refreshAndSave();
  }
}

// ================================================================
// 🔷 Fungsi utama aplikasi Flutter
// ================================================================
void main() async {
  /// 🔹 Pastikan Flutter sudah siap sebelum menjalankan async
  WidgetsFlutterBinding.ensureInitialized();

  // Registrasi background callback (hanya untuk mobile/Android/iOS, tidak didukung di Web)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  /// 🔹 Inisialisasi format tanggal bahasa Indonesia
  /// Contoh hasil: “Senin, 6 November 2025”
  await initializeDateFormatting('id_ID', null);

  /// 🔹 Override SSL supaya koneksi HTTP/HTTPS yang self-signed tetap bisa jalan
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  /// 🔹 Jalankan aplikasi utama
  runApp(const MyApp());
}

// ================================================================
// 🔷 Kelas utama aplikasi (root widget)
// ================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Diagram singkat:
  ///
  /// MaterialApp(
  ///   ├ theme → warna tema global
  ///   ├ debugShowCheckedModeBanner: false
  ///   └ routes → daftar halaman:
  ///        • '/' → DashboardPage
  ///        • '/video-kajian' → VideoPage
  ///        • '/zakat-page' → ZakatPage
  ///        • '/jadwal-sholat' → SholatPage
  /// )
  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// 🎨 Tema global: Warna utama menggunakan Deep Purple
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      /// 🚫 Hilangkan banner “debug” di pojok kanan atas
      debugShowCheckedModeBanner: false,

      /// 🗺️ Routing antar halaman (named routes)
      routes: {
        // '/' → halaman awal (dashboard utama)
        '/': (context) => DashboardPage(),

        // '/video-kajian' → halaman daftar video kajian
        '/video-kajian': (context) => KajianPage(),

        // '/zakat-page' → halaman kalkulator zakat penghasilan
        '/zakat-page': (context) => ZakatPage(),

        // '/jadwal-sholat' → halaman jadwal sholat per kota
        '/jadwal-sholat': (context) => SholatPage(),

        // '/doa-harian'-> halaman doa harian
        '/doa-harian': (context) => DoaPage(),
      },
    );
  }
}

// ================================================================
// 🔷 HttpOverrides — Bypass sertifikat SSL invalid (opsional)
// ================================================================
//
//  Fungsi ini biasanya digunakan untuk development
//  agar tidak error saat memanggil API di localhost
//  atau sumber seperti GitHub raw (tanpa sertifikat valid).
//
// ================================================================
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
