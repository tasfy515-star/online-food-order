// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/constants/app_colors.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  int _current = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Get 20% OFF',
      'subtitle': 'On your first order',
      'code': 'YUMFOOD',
      'gradient': [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
      'icon': Icons.local_offer,
    },
    {
      'title': 'Free Delivery',
      'subtitle': 'Orders above ৳300',
      'code': 'FREEDEL',
      'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
      'icon': Icons.delivery_dining,
    },
    {
      'title': 'Weekend Special',
      'subtitle': 'Extra 15% off on burgers',
      'code': 'WEEKEND15',
      'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
      'icon': Icons.fastfood,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _banners.length,
          options: CarouselOptions(
            height: 150,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            enlargeCenterPage: true,
            viewportFraction: 0.88,
            onPageChanged: (i, _) => setState(() => _current = i),
          ),
          itemBuilder: (ctx, i, _) {
            final b = _banners[i];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: List<Color>.from(b['gradient']),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          b['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b['subtitle'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Code: ${b['code']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(b['icon'], color: Colors.white.withOpacity(0.4), size: 64),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _banners.asMap().entries.map((e) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == e.key ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _current == e.key
                    ? AppColors.primary
                    : AppColors.textLight,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
