import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/botanical_character.dart';
import '../../../core/widgets/app_toast.dart';
import '../../botanical_garden/widgets/doodle_flower_painter.dart';

class NightstandScreen extends StatefulWidget {
  const NightstandScreen({super.key});

  @override
  State<NightstandScreen> createState() => _NightstandScreenState();
}

class _NightstandScreenState extends State<NightstandScreen> {
  double _brightness = 0.6; // 0.1 to 1.0
  bool _nightlightActive = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hourStr = now.hour.toString().padLeft(2, '0');
    final minStr = now.minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: _nightlightActive
          ? const Color(0xFF2C1608) // Warm Amber Nightlight Glow
          : const Color(0xFF07080A), // Deep OLED pitch black
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            _brightness = (_brightness - details.delta.dy * 0.005).clamp(0.15, 1.0);
          });
        },
        onDoubleTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _nightlightActive = !_nightlightActive;
          });
          AppToast.show(
            context,
            message: _nightlightActive ? 'Warm Amber Nightlight On' : 'Nightlight Off',
            type: _nightlightActive ? ToastType.warning : ToastType.info,
            icon: _nightlightActive ? LucideIcons.sun : LucideIcons.moon,
          );
        },
        child: SafeArea(
          child: Opacity(
            opacity: _brightness,
            child: Stack(
              children: [
                // Top control hints
                Positioned(
                  top: 16,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white54),
                        onPressed: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Swipe vertical to dim • Double-tap nightlight',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                        ),
                      ),
                    ],
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Sleepy Bud Ink Doodle
                          DoodleFlowerWidget(
                            size: 130,
                            character: const BotanicalCharacter(
                              id: 'nightstand_doodle',
                              name: 'Doodle Bud',
                              species: BotanicalSpecies.daisy,
                              bloomProgress: 0.15,
                              state: CharacterState.asleep,
                            ),
                          ),

                          const SizedBox(height: 16),

                          FittedBox(
                            child: Text(
                              '$hourStr:$minStr',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFE2DDD0).withValues(alpha: 0.85),
                                fontSize: 76,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -2.0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.alarmClock,
                                size: 14,
                                color: const Color(0xFFFFB74D).withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Next Alarm: 07:00 AM (Circadian Sunrise)',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFFB74D).withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
