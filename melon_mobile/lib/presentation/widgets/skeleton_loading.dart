import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;

  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Skeleton(height: 80, width: double.infinity, borderRadius: 20),
          const SizedBox(height: 24),
          const Skeleton(height: 180, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: const Skeleton(height: 100, borderRadius: 20)),
              const SizedBox(width: 16),
              Expanded(child: const Skeleton(height: 100, borderRadius: 20)),
            ],
          ),
          const SizedBox(height: 24),
          const Skeleton(height: 200, width: double.infinity, borderRadius: 20),
          const SizedBox(height: 24),
          const Skeleton(height: 100, width: double.infinity, borderRadius: 20),
        ],
      ),
    );
  }
}

class AnalyticsSkeleton extends StatelessWidget {
  const AnalyticsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Skeleton(height: 30, width: 150),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: List.generate(4, (_) => const Skeleton(borderRadius: 20)),
          ),
          const SizedBox(height: 32),
          const Skeleton(height: 30, width: 180),
          const SizedBox(height: 16),
          const Skeleton(height: 250, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 32),
          const Skeleton(height: 30, width: 140),
          const SizedBox(height: 16),
          const Skeleton(height: 150, width: double.infinity, borderRadius: 20),
        ],
      ),
    );
  }
}

class WalletSkeleton extends StatelessWidget {
  const WalletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Skeleton(height: 120, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (_) => const Skeleton(height: 48, width: 48, borderRadius: 24)),
          ),
          const SizedBox(height: 40),
          const Skeleton(height: 200, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: const Skeleton(height: 30)),
              const Spacer(),
              const Skeleton(height: 30, width: 80),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(3, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Skeleton(height: 70, width: double.infinity, borderRadius: 16),
            )),
          ),
        ],
      ),
    );
  }
}

class HistorySkeleton extends StatelessWidget {
  const HistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Skeleton(height: 120, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 32),
          const Skeleton(height: 50, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 24),
          Column(
            children: List.generate(4, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Skeleton(height: 80, width: double.infinity, borderRadius: 20),
            )),
          ),
        ],
      ),
    );
  }
}

class StrategySkeleton extends StatelessWidget {
  const StrategySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Skeleton(height: 180, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 32),
          const Skeleton(height: 100, width: double.infinity, borderRadius: 20),
          const SizedBox(height: 24),
          const Skeleton(height: 250, width: double.infinity, borderRadius: 20),
        ],
      ),
    );
  }
}

class ChallengesSkeleton extends StatelessWidget {
  const ChallengesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Skeleton(height: 150, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 32),
          const Skeleton(height: 50, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 24),
          Column(
            children: List.generate(3, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Skeleton(height: 100, width: double.infinity, borderRadius: 20),
            )),
          ),
        ],
      ),
    );
  }
}

class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(6, (_) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Skeleton(height: 50, width: 50, borderRadius: 25),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(height: 15, width: 150),
                  SizedBox(height: 8),
                  Skeleton(height: 12, width: double.infinity),
                  SizedBox(height: 4),
                  Skeleton(height: 12, width: 200),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
