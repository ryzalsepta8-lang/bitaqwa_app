import 'package:flutter/material.dart';

class DashboardMenu extends StatelessWidget {
  const DashboardMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: _buildMenuItem(
                  context,
                  'assets/images/ic_menu_doa.png',
                  'Doa',
                  '/doa-harian',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMenuItem(
                  context,
                  'assets/images/ic_menu_zakat.png',
                  'Zakat',
                  '/zakat-page',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMenuItem(
                  context,
                  'assets/images/ic_menu_jadwal_sholat.png',
                  'Sholat',
                  '/jadwal-sholat',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMenuItem(
                  context,
                  'assets/images/ic_menu_video_kajian.png',
                  'Kajian',
                  '/video-kajian',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String iconPath,
    String title,
    String routeName,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.amber.withAlpha(51),
        onTap: () => Navigator.pushNamed(context, routeName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(iconPath, width: 32, height: 32, fit: BoxFit.contain),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PoppinsRegular',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
