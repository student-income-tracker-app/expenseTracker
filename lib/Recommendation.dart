import 'package:flutter/material.dart';
import 'app_palette.dart';

class RecommendationPage extends StatelessWidget {
  final String message;
  final String predictionCategory;

  const RecommendationPage({
    super.key,
    required this.message,
    this.predictionCategory = '',
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'images/logo2.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recommendation',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: palette.primary),
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.cardFill,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                              fontSize: 14,
                              color: palette.primary,
                              height: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Prediction',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: palette.primary),
                    ),
                    const SizedBox(height: 18),
                    _PredictionCard(
                      category: predictionCategory,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 8,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: palette.primary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final String category;

  const _PredictionCard({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final hasCategory = category.trim().isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: palette.cardFill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          hasCategory
              ? 'The predicted highest Expense for next month is expected to be $category.'
              : 'No spending category yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.primary,
            fontSize: 20,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
