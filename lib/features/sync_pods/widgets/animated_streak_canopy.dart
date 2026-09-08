import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/sync_pod_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../botanical_garden/widgets/doodle_flower_painter.dart';

class AnimatedStreakCanopy extends StatefulWidget {
  final SyncPodState podState;
  final bool isExpanded;
  final VoidCallback onClose;
  final VoidCallback onTapFull;

  const AnimatedStreakCanopy({
    super.key,
    required this.podState,
    required this.isExpanded,
    required this.onClose,
    required this.onTapFull,
  });

  @override
  State<AnimatedStreakCanopy> createState() => _AnimatedStreakCanopyState();
}

class _AnimatedStreakCanopyState extends State<AnimatedStreakCanopy>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;
  final List<_EmberParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Generate initial ember particles
    for (int i = 0; i < 18; i++) {
      _particles.add(
        _EmberParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: 3 + _random.nextDouble() * 5,
          speed: 0.15 + _random.nextDouble() * 0.35,
          opacity: 0.3 + _random.nextDouble() * 0.7,
        ),
      );
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg(context);
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    final awakeCount = widget.podState.members.where((m) => m.isAwake).length;

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      child: widget.isExpanded
          ? Container(
              margin: const EdgeInsets.only(bottom: 20, top: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.terracotta.withValues(alpha: 0.22),
                    AppColors.warningFire.withValues(alpha: 0.12),
                    surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.terracotta.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.terracotta.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated Sparkle Ember Particles background
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _particleController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _EmberParticlePainter(
                            particles: _particles,
                            progress: _particleController.value,
                          ),
                        );
                      },
                    ),
                  ),

                  // Canopy Main Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Bar
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.terracotta,
                              ),
                              child: const Icon(
                                LucideIcons.flame,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'POD SUNRISE CANOPY',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.terracotta,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    '🔥 ${widget.podState.sharedStreak}-Day Shared Streak Active!',
                                    style: GoogleFonts.outfit(
                                      color: textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, size: 18),
                              color: textSecondary,
                              onPressed: widget.onClose,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Mini Animated Member Avatars Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: widget.podState.members.map((member) {
                            return Column(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: member.isAwake
                                          ? AppColors.sageGreen
                                          : AppColors.warningFire,
                                      width: 2,
                                    ),
                                  ),
                                  child: DoodleFlowerWidget(
                                    size: 40,
                                    character: member.character,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  member.name.split(' ').first,
                                  style: GoogleFonts.outfit(
                                    color: textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: member.isAwake
                                        ? AppColors.sageGreen.withValues(alpha: 0.2)
                                        : AppColors.warningFire.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    member.isAwake ? 'Awake ☀️' : 'Nudge 🔔',
                                    style: GoogleFonts.outfit(
                                      color: member.isAwake
                                          ? AppColors.sageGreen
                                          : AppColors.warningFire,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // Interactive Banner Tap for Deep Sheet
                        InkWell(
                          onTap: widget.onTapFull,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.terracotta,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.terracotta.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.sparkles, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  'EXPLORE FULL STREAK MAP & BADGES',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(LucideIcons.arrowRight, size: 14, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _EmberParticle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _EmberParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _EmberParticlePainter extends CustomPainter {
  final List<_EmberParticle> particles;
  final double progress;

  _EmberParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y - progress * p.speed) % 1.0;
      final currentX = p.x + math.sin(progress * math.pi * 2 + p.y * 10) * 0.02;

      final dx = currentX * size.width;
      final dy = currentY * size.height;

      final paint = Paint()
        ..color = AppColors.terracotta.withValues(alpha: p.opacity * 0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberParticlePainter oldDelegate) => true;
}
