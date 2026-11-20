// =============================================================
// 🕌 DOA PAGE - 3 layar berurutan
//   1) DoaPage       : grid kategori        (Doa-doa)
//   2) DoaListPage   : daftar doa per kategori (Pagi & Malam, dst)
//   3) DoaDetailPage : isi doa (judul, arab, arti, sumber)
// Data doa diambil dari: lib/data/date_doa.dart -> getDoaList(kategori)
// =============================================================

import 'package:bitaqwa/data/data_doa.dart';
import 'package:flutter/material.dart';

const Color _kPrimary = Color(0xFFF0916F); // oranye salmon AppBar
const String _kFont = 'Poppins';

/// Model kecil untuk kategori (nama harus SAMA dengan key di date_doa.dart)
class DoaCategory {
  final String name;
  final String icon;
  const DoaCategory(this.name, this.icon);
}

const List<DoaCategory> _categories = [
  DoaCategory('Pagi & Malam', 'assets/images/ic_doa_pagi_malam.png'),
  DoaCategory('Rumah', 'assets/images/ic_doa_rumah.png'),
  DoaCategory('Makanan & Minuman', 'assets/images/ic_doa_makanan_minuman.png'),
  DoaCategory('Perjalanan', 'assets/images/ic_doa_penjalanan.png'),
  DoaCategory('Sholat', 'assets/images/ic_doa_sholat.png'),
  DoaCategory('Etika Baik', 'assets/images/ic_doa_etika_baik.png'),
];

/// AppBar seragam untuk ketiga layar
AppBar _buildAppBar(String title) {
  return AppBar(
    backgroundColor: _kPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: _kFont,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
  );
}

/// Ambil teks dari map doa dengan beberapa kemungkinan nama key
String _pick(Map<String, String> doa, List<String> keys) {
  for (final k in keys) {
    final v = doa[k];
    if (v != null && v.trim().isNotEmpty) return v;
  }
  return '';
}

/// Cari teks Arab di map doa (apa pun nama key-nya) berdasarkan huruf Arab
String _findArabic(Map<String, String> doa) {
  final re = RegExp(r'[\u0600-\u06FF]');
  for (final v in doa.values) {
    if (re.hasMatch(v)) return v;
  }
  return '';
}

/// Cari sumber/riwayat berdasarkan kata di nama key
String _findSource(Map<String, String> doa) {
  for (final e in doa.entries) {
    final k = e.key.toLowerCase();
    if (e.value.trim().isEmpty) continue;
    if (k.contains('sumber') ||
        k.contains('source') ||
        k.contains('riwayat') ||
        k.contains('hadis') ||
        k.contains('hadits') ||
        k.contains('ref')) {
      return e.value;
    }
  }
  return '';
}

// =============================================================
// LAYAR 1 : GRID KATEGORI
// =============================================================
class DoaPage extends StatelessWidget {
  const DoaPage({super.key});

  void _openCategory(BuildContext context, DoaCategory cat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DoaListPage(category: cat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: _buildAppBar('Doa-doa'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar header (ganti dengan aset ilustrasi yang kamu pakai)
            Image.asset(
              'assets/images/bg_morning.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 200),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 14,
                childAspectRatio: 0.88,
              ),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                return _CategoryTile(
                  category: cat,
                  onTap: () => _openCategory(context, cat),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final DoaCategory category;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF3E6F5)),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  category.icon,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: _kFont, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// LAYAR 2 : DAFTAR DOA DALAM KATEGORI
// =============================================================
class DoaListPage extends StatelessWidget {
  final DoaCategory category;
  const DoaListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> doaList = getDoaList(category.name);

    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FA),
      appBar: _buildAppBar(category.name),
      body: doaList.isEmpty
          ? const Center(
              child: Text(
                'Doa tidak ditemukan.',
                style: TextStyle(fontFamily: _kFont, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: doaList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final doa = doaList[i];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoaDetailPage(doa: doa),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              category.icon,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 36),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _pick(doa, ['title', 'judul']),
                              style: const TextStyle(
                                fontFamily: _kFont,
                                fontSize: 15,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =============================================================
// LAYAR 3 : DETAIL DOA
// =============================================================
class DoaDetailPage extends StatelessWidget {
  final Map<String, String> doa;
  const DoaDetailPage({super.key, required this.doa});

  @override
  Widget build(BuildContext context) {
    final title = _pick(doa, ['title', 'judul']);
    final arabic = _findArabic(doa);
    final translation = _pick(doa, ['translation', 'arti', 'terjemahan']);
    final source = _findSource(doa);

    return Scaffold(
      appBar: _buildAppBar(title),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar matahari terbenam (ganti ke bg_night.png dsb. bila perlu)
          Image.asset(
            'assets/images/bg_afternoon.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFFE5714E)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: _kFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF3A3A3A),
                      ),
                    ),
                    if (arabic.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        arabic,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 26, height: 1.8),
                      ),
                    ],
                    if (translation.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        translation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: _kFont,
                          fontSize: 15,
                          color: Color(0xFF8DB9EE),
                        ),
                      ),
                    ],
                    if (source.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        source,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: _kFont,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}