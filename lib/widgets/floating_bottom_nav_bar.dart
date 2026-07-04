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

  /// Optional distinct center action button (e.g. "For Parents"). When
  /// provided, it renders raised in the middle, splitting [items] into two
  /// groups around it.
  final VoidCallback? onCenterTap;
  final IconData? centerIcon;
  final String? centerLabel;

  const FloatingBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
    this.onCenterTap,
    this.centerIcon,
    this.centerLabel,
  });

  @override
  State<FloatingBottomNavBar> createState() => _FloatingBottomNavBarState();
}

class _FloatingBottomNavBarState extends State<FloatingBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Distinct color for the center (parents) button — differs from the
  // primary tab color so it clearly stands apart from the 4 pages.
  static const Color _centerStart = Color(0xFF7C4DFF);
  static const Color _centerEnd = Color(0xFF9C6BFF);

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
    final hasCenter = widget.centerIcon != null && widget.onCenterTap != null;

    // Split items into two halves around the center button.
    final int half = (widget.items.length / 2).ceil();

    final pill = Container(
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
          children: [
            if (!hasCenter)
              for (int i = 0; i < widget.items.length; i++)
                Expanded(child: _buildNavColumn(i))
            else ...[
              for (int i = 0; i < half; i++)
                Expanded(child: _buildNavColumn(i)),
              // Reserved space for the raised center button.
              const SizedBox(width: 64),
              for (int i = half; i < widget.items.length; i++)
                Expanded(child: _buildNavColumn(i)),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: hasCenter ? 26 : 0,
        bottom: bottomPadding > 0 ? bottomPadding + 8 : 16,
      ),
      child: hasCenter
          ? Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                pill,
                Positioned(
                  top: -24,
                  child: _buildCenterButton(),
                ),
              ],
            )
          : pill,
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: widget.onCenterTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_centerStart, _centerEnd],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: _centerStart.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(widget.centerIcon, color: Colors.white, size: 26),
          ),
          if (widget.centerLabel != null) ...[
            const SizedBox(height: 3),
            // Constrain + center the label so long translations (e.g.
            // "Para kadagiti Nagannak") wrap neatly under the button instead
            // of overflowing onto the neighbouring tab icons/labels.
            SizedBox(
              width: 84,
              child: Text(
                widget.centerLabel!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: _centerStart,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavColumn(int index) {
    final item = widget.items[index];
    final isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          final scale = isSelected
              ? 1.0 + 0.12 * (1 - _bounceAnimation.value).clamp(0.0, 1.0)
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
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
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
