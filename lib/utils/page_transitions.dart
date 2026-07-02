import 'package:flutter/material.dart';

/// A depth-aware page transition. The incoming page slides in from the right
/// with a fade and a subtle scale-up, while the page being left behind gently
/// recedes — sliding back, scaling down and dimming — giving a layered,
/// "premium" sense of depth (similar to iOS / Material shared-axis motion).
class PremiumPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  PremiumPageRoute({
    required this.child,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final primary = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final secondary = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // Incoming page (driven by `animation`).
            final slideIn = Tween<Offset>(
              begin: const Offset(0.22, 0),
              end: Offset.zero,
            ).animate(primary);
            final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
              ),
            );
            final scaleIn =
                Tween<double>(begin: 0.97, end: 1.0).animate(primary);

            // Outgoing page (driven by `secondaryAnimation`) recedes back.
            final slideOut = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.12, 0),
            ).animate(secondary);
            final scaleOut =
                Tween<double>(begin: 1.0, end: 0.93).animate(secondary);
            final dimOut =
                Tween<double>(begin: 1.0, end: 0.80).animate(secondary);

            return SlideTransition(
              position: slideOut,
              child: ScaleTransition(
                scale: scaleOut,
                child: FadeTransition(
                  opacity: dimOut,
                  child: SlideTransition(
                    position: slideIn,
                    child: FadeTransition(
                      opacity: fadeIn,
                      child: ScaleTransition(
                        scale: scaleIn,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
}

/// A Material "fade-through" transition — the old page fades and scales out
/// while the new page fades and scales in from ~92%. Ideal for switching
/// between unrelated destinations (e.g. bottom-nav tabs) where a directional
/// slide would feel arbitrary.
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadeThroughPageRoute({
    required this.child,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
              ),
            );
            final scaleIn = Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
              ),
            );

            return FadeTransition(
              opacity: fadeOut,
              child: FadeTransition(
                opacity: fadeIn,
                child: ScaleTransition(scale: scaleIn, child: child),
              ),
            );
          },
        );
}

extension PremiumNavigator on NavigatorState {
  Future<T?> pushPremium<T>(Widget child) {
    return push(PremiumPageRoute<T>(child: child));
  }

  Future<T?> pushReplacementPremium<T>(Widget child) {
    return pushReplacement(PremiumPageRoute<T>(child: child));
  }

  Future<T?> pushFadeThrough<T>(Widget child) {
    return push(FadeThroughPageRoute<T>(child: child));
  }
}

extension PremiumContext on BuildContext {
  Future<T?> pushPremium<T>(Widget child) {
    return Navigator.of(this).push(PremiumPageRoute<T>(child: child));
  }

  Future<T?> pushReplacementPremium<T>(Widget child) {
    return Navigator.of(this)
        .pushReplacement(PremiumPageRoute<T>(child: child));
  }

  Future<T?> pushFadeThrough<T>(Widget child) {
    return Navigator.of(this).push(FadeThroughPageRoute<T>(child: child));
  }
}
