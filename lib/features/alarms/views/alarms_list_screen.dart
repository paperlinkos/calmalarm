import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/live_alarm_ticker.dart';
import '../../../core/services/local_alarm_service.dart';
import '../../../core/services/sync_pod_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../../botanical_garden/widgets/doodle_flower_painter.dart';
import '../../dev_lab/views/dev_lab_screen.dart';
import 'alarm_edit_screen.dart';

class AlarmsListScreen extends ConsumerWidget {
  const AlarmsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(alarmTickerStreamProvider);
    final alarms = ref.watch(alarmListProvider);
    final nextAlarm = ref.watch(nextUpcomingAlarmProvider);
    final podState = ref.watch(syncPodProvider);
    final myMember = podState.members.firstWhere((m) => m.id == 'mem_1');

    return Scaffold(
      backgroundColor: AppColors.linenBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. App Header Bar with Nightstand and Settings Buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CalmAlarm',
                            style: GoogleFonts.outfit(
                              color: AppColors.linenTextSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Morning Sanctuary',
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.linenTextPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Lab / Test Bench Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DevLabScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.terracotta.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.terracotta.withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.flaskConical, size: 16, color: AppColors.terracotta),
                                const SizedBox(width: 6),
                                Text(
                                  'Lab',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.terracotta,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Add Alarm Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF24338A),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF24338A).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AlarmEditScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Doodle Character & Sanctuary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.linenSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.linenSurfaceBorder),
                  ),
                  child: Row(
                    children: [
                      DoodleFlowerWidget(
                        size: 90,
                        character: myMember.character,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(syncPodProvider.notifier).cycleMySpecies();
                          AppToast.show(
                            context,
                            message: 'Switched doodle species to ${myMember.character.species.name.toUpperCase()}!',
                            type: ToastType.info,
                            icon: LucideIcons.sparkles,
                          );
                        },
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: myMember.isAwake ? const Color(0xFF24338A) : AppColors.warmOchre,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  myMember.isAwake ? 'Bloomed Doodle' : 'Resting Bud',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.linenTextSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              myMember.character.name,
                              style: GoogleFonts.outfit(
                                color: AppColors.linenTextPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap doodle plant to change species! Linked to ${podState.podName}.',
                              style: GoogleFonts.inter(
                                color: AppColors.linenTextSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),


            // 5. Alarms Section Header with Add Alarm action
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ALARM SCHEDULES',
                      style: GoogleFonts.outfit(
                        color: AppColors.linenTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.plusCircle, color: AppColors.terracotta),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AlarmEditScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 6. Alarms List with Swipe to Delete and Tap to Edit
            if (alarms.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final alarm = alarms[index];
                      final isNext = nextAlarm?.id == alarm.id && alarm.isEnabled;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key(alarm.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: AppColors.warningFire.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(LucideIcons.trash2, color: Colors.white, size: 24),
                          ),
                          onDismissed: (direction) {
                            HapticFeedback.mediumImpact();
                            ref.read(alarmListProvider.notifier).deleteAlarm(alarm.id);
                            AppToast.show(
                              context,
                              message: 'Deleted "${alarm.label}"',
                              type: ToastType.warning,
                              icon: LucideIcons.trash2,
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlarmEditScreen(existingAlarm: alarm),
                                ),
                              );
                            },
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: alarm.isEnabled ? 1.0 : 0.58,
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.linenSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isNext
                                        ? AppColors.terracotta.withValues(alpha: 0.5)
                                        : AppColors.linenSurfaceBorder,
                                    width: isNext ? 1.5 : 1.0,
                                  ),
                                  boxShadow: isNext
                                      ? [
                                          BoxShadow(
                                            color: AppColors.terracotta.withValues(alpha: 0.09),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                alarm.formattedTime,
                                                style: GoogleFonts.outfit(
                                                  color: alarm.isEnabled
                                                      ? AppColors.linenTextPrimary
                                                      : AppColors.linenTextSecondary,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -1.0,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (alarm.syncPodId != null)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.sageGreen.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'POD',
                                                    style: GoogleFonts.outfit(
                                                      color: AppColors.sageGreen,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                alarm.label,
                                                style: GoogleFonts.inter(
                                                  color: AppColors.linenTextPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '• ${alarm.repeatSummary}',
                                                style: GoogleFonts.inter(
                                                  color: AppColors.linenTextSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              // 1. Sunrise chip
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.warmOchre.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(LucideIcons.sunrise, size: 11, color: AppColors.warmOchre),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${alarm.ambientDurationMinutes}m sunrise',
                                                      style: GoogleFonts.outfit(
                                                        color: AppColors.warmOchre,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // 2. Snooze chip
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.morningSlate.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(LucideIcons.moon, size: 11, color: AppColors.morningSlate),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${alarm.snoozeDurationMinutes}m snooze (max ${alarm.maxSnoozeCount == 0 ? "none" : alarm.maxSnoozeCount})',
                                                      style: GoogleFonts.outfit(
                                                        color: AppColors.morningSlate,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // Time to next alarm countdown at bottom of card as text (not a pill)
                                          if (alarm.isEnabled)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isNext ? LucideIcons.alarmClock : LucideIcons.timer,
                                                    size: 13,
                                                    color: isNext ? AppColors.terracotta : AppColors.linenTextSecondary,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      isNext ? 'Next: ${alarm.countdownString}' : alarm.countdownString,
                                                      style: GoogleFonts.outfit(
                                                        color: isNext ? AppColors.terracotta : AppColors.linenTextSecondary,
                                                        fontSize: 12,
                                                        fontWeight: isNext ? FontWeight.w600 : FontWeight.w500,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          else
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Row(
                                                children: [
                                                  const Icon(LucideIcons.bellOff, size: 13, color: AppColors.linenTextSecondary),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'Alarm disabled',
                                                    style: GoogleFonts.outfit(
                                                      color: AppColors.linenTextSecondary,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: alarm.isEnabled,
                                      activeTrackColor: AppColors.terracotta,
                                      onChanged: (val) {
                                        HapticFeedback.selectionClick();
                                        ref.read(alarmListProvider.notifier).toggleAlarm(alarm.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: alarms.length,
                  ),
                ),
              )
            else
              // Empty State
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(LucideIcons.moon, size: 48, color: AppColors.warmOchre),
                      const SizedBox(height: 12),
                      Text(
                        'No Alarms Set',
                        style: GoogleFonts.outfit(
                          color: AppColors.linenTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enjoy your restful slumber, or tap + to create an ambient sunrise wake.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: AppColors.linenTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom padding for floating navigation capsule
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}
