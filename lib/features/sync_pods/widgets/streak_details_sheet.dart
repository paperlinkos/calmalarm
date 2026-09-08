import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/sync_pod_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';

class StreakDetailsSheet extends StatefulWidget {
  final SyncPodState podState;

  const StreakDetailsSheet({
    super.key,
    required this.podState,
  });

  static void show(BuildContext context, SyncPodState podState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreakDetailsSheet(podState: podState),
    );
  }

  @override
  State<StreakDetailsSheet> createState() => _StreakDetailsSheetState();
}

class _StreakDetailsSheetState extends State<StreakDetailsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg(context);
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    const nextMilestone = 14;
    final progress = (widget.podState.sharedStreak / nextMilestone).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: border),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Animated Flame Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.terracotta.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.terracotta.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                LucideIcons.flame,
                size: 38,
                color: AppColors.terracotta,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title & Subtitle
          Text(
            '${widget.podState.sharedStreak} DAY STREAK',
            style: GoogleFonts.outfit(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shared Pod Morning Wakefulness',
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          // Milestone Progress Bar Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Milestone: 14 Days',
                      style: GoogleFonts.outfit(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.outfit(
                        color: AppColors.terracotta,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.terracotta),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '2 days remaining to unlock the Golden Sprout badge for your entire pod!',
                  style: GoogleFonts.inter(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pod Member Streak Roster
          Row(
            children: [
              Text(
                'MEMBER STREAKS',
                style: GoogleFonts.outfit(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...widget.podState.members.map((member) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.flame,
                    size: 16,
                    color: member.isAwake ? AppColors.terracotta : textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      member.name,
                      style: GoogleFonts.outfit(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${member.streakDays} Days',
                      style: GoogleFonts.outfit(
                        color: AppColors.terracotta,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Share Streak Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                AppToast.show(
                  context,
                  message: 'Shared ${widget.podState.sharedStreak}-Day Streak badge to status!',
                  type: ToastType.success,
                  icon: LucideIcons.share2,
                );
              },
              icon: const Icon(LucideIcons.share2, size: 16),
              label: const Text('SHARE STREAK BADGE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
