import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/botanical_character.dart';
import '../../../core/services/sync_pod_service.dart';
import '../../../core/widgets/app_toast.dart';
import '../../botanical_garden/widgets/doodle_flower_painter.dart';

class WakeScreen extends ConsumerStatefulWidget {
  const WakeScreen({super.key});

  @override
  ConsumerState<WakeScreen> createState() => _WakeScreenState();
}

class _WakeScreenState extends ConsumerState<WakeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _sunriseController;
  late Animation<double> _bloomAnimation;
  bool _hasSwipedAwake = false;

  @override
  void initState() {
    super.initState();
    _sunriseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();

    _bloomAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _sunriseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sunriseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _sunriseController,
        builder: (context, child) {
          final t = _sunriseController.value;

          final bgColor = Color.lerp(
            const Color(0xFF1F1113),
            Color.lerp(
              const Color(0xFFE05A36),
              const Color(0xFFF5F2EB),
              (t - 0.5).clamp(0.0, 0.5) * 2,
            )!,
            t * 0.9,
          )!;

          final textColor = t > 0.6 ? Colors.black87 : Colors.white70;

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: bgColor,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      // Top Ambient Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(LucideIcons.x, color: textColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'CIRCADIAN SUNRISE WAKE',
                              style: GoogleFonts.outfit(
                                color: textColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Center Hand-Drawn Ink Doodle Bloom
                      Text(
                        '07:00 AM',
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Good Morning, Alex',
                        style: GoogleFonts.playfairDisplay(
                          color: textColor.withValues(alpha: 0.85),
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DoodleFlowerWidget(
                        size: 170,
                        character: BotanicalCharacter(
                          id: 'wake_doodle',
                          name: 'Doodle Daisy',
                          species: BotanicalSpecies.daisy,
                          bloomProgress: _bloomAnimation.value,
                          state: _bloomAnimation.value > 0.8
                              ? CharacterState.bloomed
                              : CharacterState.waking,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Bottom Action: Tap to Wake
                      if (!_hasSwipedAwake)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _hasSwipedAwake = true;
                            });
                            ref.read(syncPodProvider.notifier).toggleMyAwakeState();
                            AppToast.show(
                              context,
                              message: 'Morning Doodle Ping sent to Pod!',
                              type: ToastType.success,
                              icon: LucideIcons.sun,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: textColor == Colors.black87
                                  ? const Color(0xFF1A1D20)
                                  : Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.sunMedium,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "TAP TO WAKE & NOTIFY POD",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF24338A).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.checkCircle2, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                'Awake & Pod Notified!',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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
          );
        },
      ),
    );
  }
}
