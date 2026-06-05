import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({
    required this.icon,
    required this.label,
  });
}

class FloatingBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;

  const FloatingBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<FloatingBottomNavBar> createState() => _FloatingBottomNavBarState();
}

class _FloatingBottomNavBarState extends State<FloatingBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void didUpdateWidget(covariant FloatingBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomPadding > 0 ? bottomPadding + 8 : 16,
      ),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              final item = widget.items[index];
              final isSelected = widget.selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      final scale = isSelected
                          ? 1.0 +
                              0.12 *
                                  (1 - _bounceAnimation.value)
                                      .clamp(0.0, 1.0)
                          : 1.0;

                      return Transform.scale(
                        scale: scale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIcon(item.icon, isSelected),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                                letterSpacing: isSelected ? 0.2 : 0,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: isSelected ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Icon(
          icon,
          size: 20 + value * 2,
          color: Color.lerp(
            Colors.grey.shade400,
            AppColors.primary,
            value,
          ),
        );
      },
    );
  }
}
