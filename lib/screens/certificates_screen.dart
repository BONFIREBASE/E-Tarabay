import 'dart:math' show pi;
import 'dart:ui' as ui;
import '../widgets/custom_back_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../l10n/app_localizations.dart';
import '../models/certificate_model.dart';
import '../providers/user_provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Enforce portrait mode for the listing screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getLocalizedTitle(CertificateInfo cert, String langCode) {
    switch (langCode) {
      case 'fil':
        return cert.titleFil;
      case 'ilo':
        return cert.titleIlo;
      default:
        return cert.title;
    }
  }

  String _getLocalizedDesc(CertificateInfo cert, String langCode) {
    switch (langCode) {
      case 'fil':
        return cert.descriptionFil;
      case 'ilo':
        return cert.descriptionIlo;
      default:
        return cert.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final langCode = langProvider.currentLanguageCode;
    final earned = userProvider.earnedCertificates;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Animated Header
              SliverToBoxAdapter(
                child: _buildHeader(context, earned.length),
              ),

              // Certificates Grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final certId = allCertificates.keys.elementAt(index);
                      final cert = allCertificates[certId]!;
                      final isEarned = earned.contains(certId);
                      final delay = index * 100;

                      return _buildCertificateCard(
                        context,
                        cert: cert,
                        isEarned: isEarned,
                        langCode: langCode,
                        delay: delay,
                      );
                    },
                    childCount: allCertificates.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.orange,
              ],
              gravity: 0.2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              minBlastForce: 5,
              maxBlastForce: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int earnedCount) {
    final headerContent = Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            CustomBackButton(
              onPressed: () => Navigator.pop(context),
              iconColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'My Certificates',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final progressSection = Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 10),
                Text(
                  '$earnedCount / ${allCertificates.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: earnedCount / allCertificates.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerContent,
        progressSection,
      ],
    );
  }

  Widget _buildCertificateCard(
    BuildContext context, {
    required CertificateInfo cert,
    required bool isEarned,
    required String langCode,
    required int delay,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animValue = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay / 1000,
            (delay + 400) / 1000,
            curve: Curves.easeOutBack,
          ),
        ).value;

        return Transform.translate(
          offset: Offset(0, 50 * (1 - animValue)),
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: isEarned
            ? () => _showCertificateDetail(context, cert, langCode)
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              // Main card
              Container(
                decoration: BoxDecoration(
                  gradient: isEarned
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [cert.primaryColor, cert.secondaryColor],
                        )
                      : null,
                  color: isEarned ? null : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isEarned
                      ? [
                          BoxShadow(
                            color: cert.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Decorative circles
                      if (isEarned)
                        Positioned(
                          right: -30,
                          top: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                      if (isEarned)
                        Positioned(
                          left: -20,
                          bottom: -20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Badge icon
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isEarned
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.shade300,
                                border: isEarned
                                    ? Border.all(
                                        color: cert.accentColor,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: isEarned
                                    ? [
                                        BoxShadow(
                                          color:
                                              cert.accentColor.withOpacity(0.4),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isEarned
                                    ? Text(
                                        cert.emoji,
                                        style: const TextStyle(fontSize: 36),
                                      )
                                    : Icon(
                                        Icons.lock,
                                        color: Colors.grey.shade500,
                                        size: 28,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getLocalizedTitle(cert, langCode),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isEarned
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _getLocalizedDesc(cert, langCode),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isEarned
                                          ? Colors.white.withOpacity(0.85)
                                          : Colors.grey.shade500,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      if (isEarned)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cert.accentColor
                                                .withOpacity(0.9),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '+${cert.starReward}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Locked',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      if (isEarned) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .earned,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Arrow for earned
                            if (isEarned)
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCertificateDetail(
    BuildContext context,
    CertificateInfo cert,
    String langCode,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CertificateDetailScreen(
          certificate: cert,
          langCode: langCode,
        ),
      ),
    );
    
    // Explicitly restore portrait when the user pops back to the list
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

class CertificateDetailScreen extends StatefulWidget {
  final CertificateInfo certificate;
  final String langCode;

  const CertificateDetailScreen({
    super.key,
    required this.certificate,
    required this.langCode,
  });

  @override
  State<CertificateDetailScreen> createState() =>
      _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  final GlobalKey _certificateKey = GlobalKey();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    // Force landscape for certificate viewing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    // Restore portrait when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _shareCertificate() async {
    try {
      setState(() => _isCapturing = true);
      await Future.delayed(const Duration(milliseconds: 50));
      
      final boundary = _certificateKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      await Share.shareXFiles(
        [XFile.fromData(bytes, name: 'certificate.png', mimeType: 'image/png')],
        text: 'I just earned a new certificate on E-Tarabay!',
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _downloadCertificate() async {
    try {
      setState(() => _isCapturing = true);
      await Future.delayed(const Duration(milliseconds: 50));
      
      final boundary = _certificateKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(bytes, name: 'certificate_${DateTime.now().millisecondsSinceEpoch}.png');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificate saved to gallery!')),
        );
      }
    } catch (e) {
      debugPrint('Error downloading: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save certificate')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  String get title {
    switch (widget.langCode) {
      case 'fil':
        return widget.certificate.titleFil;
      case 'ilo':
        return widget.certificate.titleIlo;
      default:
        return widget.certificate.title;
    }
  }

  String get description {
    switch (widget.langCode) {
      case 'fil':
        return widget.certificate.descriptionFil;
      case 'ilo':
        return widget.certificate.descriptionIlo;
      default:
        return widget.certificate.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          Center(
            child: _buildCertificateView(context, profile),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                widget.certificate.primaryColor,
                widget.certificate.accentColor,
                Colors.amber,
                Colors.red,
                Colors.green,
              ],
              gravity: 0.15,
              emissionFrequency: 0.03,
              numberOfParticles: 40,
            ),
          ),
          // Close button (top-left)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          // Share and Download Buttons (bottom-right)
          if (!_isCapturing)
            Positioned(
              bottom: 16,
              right: 16,
              child: SafeArea(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'shareBtn',
                      onPressed: _shareCertificate,
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB8860B),
                      child: const Icon(Icons.share),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton.small(
                      heroTag: 'downloadBtn',
                      onPressed: _downloadCertificate,
                      backgroundColor: const Color(0xFFB8860B),
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.download),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCertificateView(BuildContext context, dynamic profile) {
    final name = profile?.name ?? 'Student';
    final lrn = profile?.lrn ?? '';
    final date = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutBack,
            ).value.clamp(0.0, 1.2),
            child: Opacity(
              opacity: _controller.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: 1.414, // A4 landscape ratio
          child: RepaintBoundary(
            key: _certificateKey,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5), // Ivory bond paper
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Outer gold border
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFB8860B), // Dark goldenrod
                        width: 2.5,
                      ),
                    ),
                  ),
                ),

                // Inner gold border (double-line effect)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFDAA520), // Goldenrod
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // Corner ornaments (top-left)
                Positioned(
                  left: 18,
                  top: 18,
                  child: _buildCornerOrnament(),
                ),
                // Corner ornaments (top-right)
                Positioned(
                  right: 18,
                  top: 18,
                  child: Transform.flip(
                    flipX: true,
                    child: _buildCornerOrnament(),
                  ),
                ),
                // Corner ornaments (bottom-left)
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: Transform.flip(
                    flipY: true,
                    child: _buildCornerOrnament(),
                  ),
                ),
                // Corner ornaments (bottom-right)
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Transform.flip(
                    flipX: true,
                    flipY: true,
                    child: _buildCornerOrnament(),
                  ),
                ),

                // Certificate content
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 500, // Design width for layout
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Header: "CERTIFICATE"
                            const Text(
                              'CERTIFICATE',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 14,
                                color: Color(0xFFB8860B),
                                fontFamily: 'serif',
                              ),
                            ),

                            const SizedBox(height: 1),

                            // Subheader: "OF COMPLETION"
                            const Text(
                              'OF COMPLETION',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 6,
                                color: Color(0xFF555555),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Decorative line
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 1,
                                  color: const Color(0xFFDAA520),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFDAA520),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 50,
                                  height: 1,
                                  color: const Color(0xFFDAA520),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // "This is presented to"
                            const Text(
                              'This is proudly presented to',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF666666),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Student name
                            Column(
                              children: [
                                Text(
                                  name.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 3,
                                    color: Color(0xFF2D2D2D),
                                    fontFamily: 'serif',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: 200,
                                  height: 1.5,
                                  color: const Color(0xFFB8860B),
                                ),
                              ],
                            ),

                            // LRN
                            if (lrn.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                'LRN: $lrn',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF888888),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],

                            const SizedBox(height: 8),

                            // Description
                            const Text(
                              'for successfully completing all learning modules\nand earning all achievements in',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF555555),
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Program name
                            const Text(
                              'E-TARABAY',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 5,
                                color: Color(0xFFB8860B),
                                fontFamily: 'serif',
                              ),
                            ),

                            const SizedBox(height: 2),

                            const Text(
                              'Interactive Learning Application',
                              style: TextStyle(
                                fontSize: 9,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF888888),
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Date and Signature row
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                children: [
                                  // Date
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 1,
                                          color: const Color(0xFF999999),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(date),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF555555),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Date',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Color(0xFF999999),
                                            letterSpacing: 1,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),



                                  // Signature
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 1,
                                          color: const Color(0xFF999999),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Daycare Teacher',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                            color: Color(0xFF555555),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildCornerOrnament() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _CornerOrnamentPainter(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _CornerOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDAA520)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Horizontal line
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, 0),
      paint,
    );
    // Vertical line
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, size.height),
      paint,
    );
    // Small inner diagonal
    canvas.drawLine(
      const Offset(4, 4),
      Offset(size.width * 0.6, 4),
      paint..strokeWidth = 1,
    );
    canvas.drawLine(
      const Offset(4, 4),
      Offset(4, size.height * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
