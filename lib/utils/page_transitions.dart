import 'package:flutter/material.dart';

class PremiumPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final bool isReverse;

  PremiumPageRoute({
    required this.child,
    this.isReverse = false,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const beginOffset = Offset(0.18, 0.0);
            const endOffset = Offset.zero;

            final curve = Curves.easeOutExpo;
            final reverseCurve = Curves.easeInExpo;

            final tween = Tween<Offset>(
              begin: isReverse ? endOffset : beginOffset,
              end: isReverse ? beginOffset : endOffset,
            );

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
              reverseCurve: reverseCurve,
            );

            final slideAnimation = tween.animate(curvedAnimation);

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
              reverseCurve: const Interval(0.3, 1.0, curve: Curves.easeIn),
            ));

            final scaleAnimation = Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
              reverseCurve: const Interval(0.2, 1.0, curve: Curves.easeInCubic),
            ));

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Transform.scale(
                  scale: scaleAnimation.value,
                  child: child,
                ),
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
}

extension PremiumContext on BuildContext {
  Future<T?> pushPremium<T>(Widget child) {
    return Navigator.of(this).push(PremiumPageRoute<T>(child: child));
  }

  Future<T?> pushReplacementPremium<T>(Widget child) {
    return Navigator.of(this).pushReplacement(PremiumPageRoute<T>(child: child));
  }
}
