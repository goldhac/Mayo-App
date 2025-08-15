import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Collection of reusable shimmer loading widgets
class ShimmerWidgets {
  /// Base shimmer effect with customizable colors
  static Widget shimmerEffect({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: child,
    );
  }

  /// Circular avatar shimmer
  static Widget avatar({double size = 50}) {
    return shimmerEffect(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Text line shimmer
  static Widget textLine({
    double width = 100,
    double height = 16,
    BorderRadius? borderRadius,
  }) {
    return shimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Card shimmer
  static Widget card({
    double? width,
    double height = 100,
    BorderRadius? borderRadius,
  }) {
    return shimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Button shimmer
  static Widget button({
    double? width,
    double height = 48,
    BorderRadius? borderRadius,
  }) {
    return shimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Image placeholder shimmer
  static Widget image({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return shimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Pre-built shimmer layouts for common UI patterns
class ShimmerLayouts {
  /// Home screen content shimmer
  static Widget homeContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidgets.textLine(width: 150, height: 24),
                  const SizedBox(height: 8),
                  ShimmerWidgets.textLine(width: 200, height: 16),
                ],
              ),
              ShimmerWidgets.avatar(size: 40),
            ],
          ),
          const SizedBox(height: 32),
          
          // Mood tracking section
          ShimmerWidgets.textLine(width: 120, height: 18),
          const SizedBox(height: 16),
          ShimmerWidgets.card(height: 120),
          const SizedBox(height: 32),
          
          // New session card
          ShimmerWidgets.textLine(width: 100, height: 18),
          const SizedBox(height: 16),
          ShimmerWidgets.card(height: 150),
          const SizedBox(height: 24),
          
          // Session history
          ShimmerWidgets.textLine(width: 140, height: 18),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ShimmerWidgets.card(height: 80),
          )),
        ],
      ),
    );
  }

  /// Profile section shimmer
  static Widget profileSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile header
          ShimmerWidgets.avatar(size: 80),
          const SizedBox(height: 16),
          ShimmerWidgets.textLine(width: 120, height: 20),
          const SizedBox(height: 8),
          ShimmerWidgets.textLine(width: 80, height: 16),
          const SizedBox(height: 32),
          
          // Settings sections
          ...List.generate(4, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShimmerWidgets.card(height: 60),
          )),
        ],
      ),
    );
  }

  /// Chat message shimmer
  static Widget chatMessage({bool isMe = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            ShimmerWidgets.avatar(size: 40),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                ShimmerWidgets.card(
                  width: 200,
                  height: 60,
                  borderRadius: BorderRadius.circular(16),
                ),
                const SizedBox(height: 4),
                ShimmerWidgets.textLine(width: 60, height: 12),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 12),
            ShimmerWidgets.avatar(size: 40),
          ],
        ],
      ),
    );
  }

  /// Notification item shimmer
  static Widget notificationItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ShimmerWidgets.avatar(size: 50),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidgets.textLine(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                ShimmerWidgets.textLine(width: 150, height: 14),
                const SizedBox(height: 4),
                ShimmerWidgets.textLine(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Session history item shimmer
  static Widget sessionHistoryItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ShimmerWidgets.card(
        height: 80,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Linked partner widget shimmer
  static Widget linkedPartner() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          ShimmerWidgets.textLine(width: 250, height: 16),
          const SizedBox(height: 8),
          ShimmerWidgets.textLine(width: 200, height: 16),
          const SizedBox(height: 32),
          
          // Partner card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                ShimmerWidgets.avatar(size: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidgets.textLine(width: 120, height: 18),
                      const SizedBox(height: 8),
                      ShimmerWidgets.textLine(width: 80, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Button
          ShimmerWidgets.button(width: double.infinity),
        ],
      ),
    );
  }

  /// Mood tracker shimmer
  static Widget moodTracker() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header
          ShimmerWidgets.textLine(width: 200, height: 20),
          const SizedBox(height: 8),
          ShimmerWidgets.textLine(width: 300, height: 16),
          const SizedBox(height: 32),
          
          // Mood buttons
          Row(
            children: [
              Expanded(child: ShimmerWidgets.button()),
              const SizedBox(width: 12),
              Expanded(child: ShimmerWidgets.button()),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 150,
              child: ShimmerWidgets.button(),
            ),
          ),
          const SizedBox(height: 32),
          
          // Chart
          ShimmerWidgets.card(height: 200),
          const SizedBox(height: 32),
          
          // History section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidgets.textLine(width: 80, height: 18),
              ShimmerWidgets.textLine(width: 100, height: 16),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search bar
          ShimmerWidgets.textLine(width: double.infinity, height: 48),
          const SizedBox(height: 16),
          
          // History items
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ShimmerWidgets.card(height: 80),
          )),
        ],
      ),
    );
  }

  /// Simple circular loading shimmer
  static Widget circularLoader({
    double size = 40,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShimmerWidgets.shimmerEffect(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}