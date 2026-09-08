import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/alarm.dart';
import '../../../core/models/botanical_character.dart';
import '../../../core/services/sync_pod_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../../botanical_garden/widgets/doodle_flower_painter.dart';

class AlarmRingingScreen extends ConsumerStatefulWidget {
  final Alarm alarm;

  const AlarmRingingScreen({super.key, required this.alarm});

  @override
  ConsumerState<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends ConsumerState<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _sliderPosition = 0.0;
  bool _isDismissed = false;
  late int _snoozesLeft;

  @override
  void initState() {
    super.initState();
    _snoozesLeft = widget.alarm.remainingSnoozes;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleSnooze() {
    if (_snoozesLeft <= 0) return;

    setState(() {
      _snoozesLeft--;
    });

    if (widget.alarm.snoozePenaltyEnabled) {
      AppToast.show(
        context,
        message: 'Snoozed for ${widget.alarm.snoozeDurationMinutes}m (Playful ember on pod plot)',
        type: ToastType.warning,
        icon: LucideIcons.flame,
      );
    } else {
      AppToast.show(
        context,
        message: 'Snoozed for ${widget.alarm.snoozeDurationMinutes} mins ($_snoozesLeft left)',
        type: ToastType.info,
        icon: LucideIcons.moon,
      );
    }

    Navigator.pop(context);
  }

  void _handleDismiss() {
    setState(() {
      _isDismissed = true;
    });

    // Mark user awake in pod
    ref.read(syncPodProvider.notifier).toggleMyAwakeState();

    AppToast.show(
      context,
      message: 'Good Morning! You are awake & your pod is notified!',
      type: ToastType.success,
      icon: LucideIcons.sun,
    );

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hourStr = widget.alarm.time.hourOfPeriod == 0 ? '12' : widget.alarm.time.hourOfPeriod.toString();
    final minStr = widget.alarm.time.minute.toString().padLeft(2, '0');
    final period = widget.alarm.time.period == DayPeriod.am ? 'AM' : 'PM';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF2B1810), // Warm Dark Ember
              Color(0xFF8A3B2B), // Dawn Terracotta
              Color(0xFFE05A36), // Sunrise Amber
              Color(0xFFF5F2EB), // Daylight Linen
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.sun, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'CIRCADIAN SUNRISE ALARM',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Digital Clock & Label
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$hourStr:$minStr',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 74,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          period,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFB74D),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.alarm.label,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sound: ${widget.alarm.soundscape} • Vibe: ${widget.alarm.vibrationPattern}',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Blooming Doodle Character Reaction
                DoodleFlowerWidget(
                  size: 190,
                  character: const BotanicalCharacter(
                    id: 'ringing_char',
                    name: 'Morning Sprout',
                    species: BotanicalSpecies.daisy,
                    bloomProgress: 1.0,
                    state: CharacterState.bloomed,
                  ),
                ),

                const SizedBox(height: 36),

                // Snooze & Slide to Dismiss Controls
                Column(
                  children: [
                    // Snooze Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _snoozesLeft > 0 ? _handleSnooze : null,
                        icon: const Icon(LucideIcons.alarmClockOff, size: 18),
                        label: Text(
                          _snoozesLeft > 0
                              ? 'SNOOZE (+${widget.alarm.snoozeDurationMinutes} MIN) • ${_snoozesLeft == 99 ? 'Unlimited' : '$_snoozesLeft left'}'
                              : 'NO SNOOZES REMAINING',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Slide to Dismiss Interactive Slider
                    _buildSlideToDismiss(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlideToDismiss() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSlide = constraints.maxWidth - 64;

        return Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF16191D),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _isDismissed
                  ? AppColors.sageGreen.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track Label & Single Arrow
              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final alpha = 0.5 + 0.5 * _pulseController.value;
                    final dragProgress = (_sliderPosition / (maxSlide == 0 ? 1 : maxSlide)).clamp(0.0, 1.0);
                    final textOpacity = ((1.0 - dragProgress) * alpha).clamp(0.0, 1.0);

                    if (_isDismissed) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.sageGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Good Morning! Awake',
                            style: GoogleFonts.outfit(
                              color: AppColors.sageGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      );
                    }

                    return Opacity(
                      opacity: textOpacity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Slide to dismiss',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.arrowRight,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Knob with Single Chevron Arrow
              Positioned(
                left: _sliderPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isDismissed) return;
                    setState(() {
                      _sliderPosition = (_sliderPosition + details.delta.dx).clamp(0.0, maxSlide);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isDismissed) return;
                    if (_sliderPosition > maxSlide * 0.7) {
                      HapticFeedback.heavyImpact();
                      _handleDismiss();
                    } else {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _sliderPosition = 0.0;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _isDismissed ? AppColors.sageGreen : AppColors.terracotta,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isDismissed ? AppColors.sageGreen : AppColors.terracotta)
                              .withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isDismissed ? LucideIcons.check : LucideIcons.chevronRight,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
