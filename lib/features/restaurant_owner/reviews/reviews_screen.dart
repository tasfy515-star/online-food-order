import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  // Static sample reviews
  final List<Map<String, dynamic>> _reviews = const [
    {
      'name': 'Rahim Ahmed',
      'avatar': 'R',
      'rating': 5.0,
      'comment': 'Amazing food! The kacchi biriyani was absolutely delicious. Will order again!',
      'date': '2 days ago',
      'orderItem': 'Kacchi Biriyani',
    },
    {
      'name': 'Sarah Khan',
      'avatar': 'S',
      'rating': 4.0,
      'comment': 'Great taste and fast delivery. Packaging could be improved a bit.',
      'date': '5 days ago',
      'orderItem': 'Beef Rezala',
    },
    {
      'name': 'Karim Hossain',
      'avatar': 'K',
      'rating': 5.0,
      'comment': 'Best biriyani in Dhaka! Perfectly spiced and very generous portions.',
      'date': '1 week ago',
      'orderItem': 'Kacchi Biriyani (Full)',
    },
    {
      'name': 'Mitu Roy',
      'avatar': 'M',
      'rating': 3.0,
      'comment': 'Food was good but arrived a bit late. Hope delivery improves.',
      'date': '1 week ago',
      'orderItem': 'Borhani',
    },
    {
      'name': 'Farhan Islam',
      'avatar': 'F',
      'rating': 5.0,
      'comment': 'Exceptional quality! The taste is authentic and reminds me of old Dhaka.',
      'date': '2 weeks ago',
      'orderItem': 'Plain Rice + Curry',
    },
  ];

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.fold(
        0.0, (sum, r) => sum + (r['rating'] as double));
    return sum / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Reviews')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Rating Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < _averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        )),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_reviews.length} reviews',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        final count = _reviews.where(
                                (r) => (r['rating'] as double).round() == star
                        ).length;
                        final percent = _reviews.isEmpty
                            ? 0.0
                            : count / _reviews.length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(
                                '$star',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 10),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    backgroundColor:
                                    Colors.white.withOpacity(0.3),
                                    valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Colors.amber),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reviews List
            ..._reviews.map((review) => _ReviewCard(review: review)),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final rating = review['rating'] as double;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  review['avatar'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      review['orderItem'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 14,
                    )),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review['date'],
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review['comment'],
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}