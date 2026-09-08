import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/sync_pod_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../../botanical_garden/widgets/doodle_flower_painter.dart';

class PodDashboardScreen extends ConsumerWidget {
  const PodDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podState = ref.watch(syncPodProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.linenBackground,
        elevation: 0,
        title: Text(
          podState.podName,
          style: GoogleFonts.outfit(
            color: AppColors.linenTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sageGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.flame, size: 16, color: AppColors.terracotta),
                const SizedBox(width: 6),
                Text(
                  '${podState.sharedStreak} Day Streak',
                  style: GoogleFonts.outfit(
                    color: AppColors.terracotta,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pod Invite Code Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.linenSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.linenSurfaceBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'POD INVITE CODE',
                          style: GoogleFonts.outfit(
                            color: AppColors.linenTextSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          podState.podCode,
                          style: GoogleFonts.outfit(
                            color: AppColors.linenTextPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      AppToast.show(
                        context,
                        message: 'Pod Code copied to clipboard!',
                        type: ToastType.info,
                        icon: LucideIcons.copy,
                      );
                    },
                    icon: const Icon(LucideIcons.copy, size: 16),
                    label: const Text('Share Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section 1: The Garden of Accountability
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'POD BOTANICAL DOODLE GARDEN',
                    style: GoogleFonts.outfit(
                      color: AppColors.linenTextSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${podState.members.length} Members',
                  style: GoogleFonts.inter(
                    color: AppColors.linenTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Grid of Pod Members' Botanical Plot Cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: podState.members.length,
              itemBuilder: (context, index) {
                final member = podState.members[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.linenSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: member.character.hasFire
                          ? AppColors.warningFire.withValues(alpha: 0.6)
                          : AppColors.linenSurfaceBorder,
                      width: member.character.hasFire ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Member status top header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              member.name,
                              style: GoogleFonts.outfit(
                                color: AppColors.linenTextPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: member.isAwake
                                  ? const Color(0xFF24338A).withValues(alpha: 0.15)
                                  : AppColors.linenTextSecondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              member.isAwake ? 'AWAKE' : 'ASLEEP',
                              style: GoogleFonts.outfit(
                                color: member.isAwake
                                    ? const Color(0xFF24338A)
                                    : AppColors.linenTextSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Plant hand-drawn ink doodle render
                      DoodleFlowerWidget(
                        size: 78,
                        character: member.character,
                      ),

                      // Local Phase & Water Action
                      Column(
                        children: [
                          Text(
                            member.localPhase,
                            style: GoogleFonts.inter(
                              color: AppColors.linenTextSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (member.character.hasFire)
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(syncPodProvider.notifier)
                                      .sendWateringNudge(member.id);
                                  AppToast.show(
                                    context,
                                    message: 'Sent Watering Can Nudge to ${member.name}!',
                                    type: ToastType.success,
                                    icon: LucideIcons.droplets,
                                  );
                                },
                                icon: const Icon(LucideIcons.droplets, size: 12),
                                label: const Text('WATER & NUDGE', style: TextStyle(fontSize: 9)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gardenWater,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                ),
                              ),
                            )
                          else
                            Text(
                              '${member.character.name} • Normal',
                              style: GoogleFonts.outfit(
                                color: AppColors.sageGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Section 2: LDR Moon & Sun Bridge
            Text(
              'CROSS-TIMEZONE MOON & SUN BRIDGE',
              style: GoogleFonts.outfit(
                color: AppColors.linenTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF16181D), Color(0xFF384353)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.moon, size: 36, color: Color(0xFFFFB74D)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tokyo Overlap Window',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Shared Talk Window in 3 hrs 15 mins (Tokyo Wind-Down vs. London Morning Wake)',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
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
    );
  }
}
