import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedRange = 'This Week';

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg(context);
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wake & Sleep Analytics',
          style: GoogleFonts.outfit(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, size: 18),
            color: textPrimary,
            onPressed: () {
              AppToast.show(
                context,
                message: 'Analytics report exported!',
                type: ToastType.success,
                icon: LucideIcons.share2,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Range Segmented Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Row(
                children: ['This Week', 'This Month', 'All Time'].map((range) {
                  final isSelected = _selectedRange == range;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRange = range),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.terracotta : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          range,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Top Key Metrics 2x2 Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.35,
              children: [
                _buildMetricCard(
                  context: context,
                  title: 'WAKE CONSISTENCY',
                  value: '94%',
                  subtitle: '🏅 Top 5% Pod Consistency',
                  icon: LucideIcons.target,
                  iconColor: AppColors.sageGreen,
                ),
                _buildMetricCard(
                  context: context,
                  title: 'AVG WAKE TIME',
                  value: '6:45 AM',
                  subtitle: '⚡ 15 min earlier',
                  icon: LucideIcons.sun,
                  iconColor: AppColors.terracotta,
                ),
                _buildMetricCard(
                  context: context,
                  title: 'AVG SLEEP REST',
                  value: '7.8 hrs',
                  subtitle: '🌙 Optimal Sleep Window',
                  icon: LucideIcons.moon,
                  iconColor: const Color(0xFF6C63FF),
                ),
                _buildMetricCard(
                  context: context,
                  title: 'ZERO-SNOOZE HERO',
                  value: '8 Days',
                  subtitle: '🔥 Streak Alive',
                  icon: LucideIcons.flame,
                  iconColor: AppColors.warningFire,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section: Weekly Wake Consistency Chart
            Text(
              'WEEKLY WAKE ALIGNMENT (MON - SUN)',
              style: GoogleFonts.outfit(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target Wake: 7:00 AM',
                        style: GoogleFonts.outfit(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.sageGreen)),
                          const SizedBox(width: 4),
                          Text('On-Time', style: GoogleFonts.inter(color: textSecondary, fontSize: 10)),
                          const SizedBox(width: 10),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.terracotta)),
                          const SizedBox(width: 4),
                          Text('Snoozed', style: GoogleFonts.inter(color: textSecondary, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Custom Bar Chart Render
                  SizedBox(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar(day: 'Mon', heightFactor: 0.95, isOnTime: true, context: context),
                        _buildBar(day: 'Tue', heightFactor: 1.0, isOnTime: true, context: context),
                        _buildBar(day: 'Wed', heightFactor: 0.75, isOnTime: false, context: context),
                        _buildBar(day: 'Thu', heightFactor: 0.9, isOnTime: true, context: context),
                        _buildBar(day: 'Fri', heightFactor: 0.98, isOnTime: true, context: context),
                        _buildBar(day: 'Sat', heightFactor: 0.65, isOnTime: false, context: context),
                        _buildBar(day: 'Sun', heightFactor: 0.92, isOnTime: true, context: context),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Pod Synergy & Accountability
            Text(
              'POD ACCOUNTABILITY & SYNERGY',
              style: GoogleFonts.outfit(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  _buildSynergyRow(
                    icon: LucideIcons.users,
                    iconColor: const Color(0xFF24338A),
                    label: 'Pod Sync Efficiency',
                    value: '91% Shared Window',
                    context: context,
                  ),
                  Divider(color: border, height: 24),
                  _buildSynergyRow(
                    icon: LucideIcons.trophy,
                    iconColor: const Color(0xFFFFB74D),
                    label: 'Top Early Riser',
                    value: 'Yuki (Avg 6:15 AM)',
                    context: context,
                  ),
                  Divider(color: border, height: 24),
                  _buildSynergyRow(
                    icon: LucideIcons.droplets,
                    iconColor: AppColors.gardenWater,
                    label: 'Nudge Hero Award',
                    value: 'You (Alex) • 4 Water Pings',
                    context: context,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final surface = AppColors.surface(context);
    final border = AppColors.border(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required String day,
    required double heightFactor,
    required bool isOnTime,
    required BuildContext context,
  }) {
    final textSecondary = AppColors.textSecondary(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 18,
          height: 80 * heightFactor,
          decoration: BoxDecoration(
            color: isOnTime ? AppColors.sageGreen : AppColors.terracotta,
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: GoogleFonts.outfit(
            color: textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSynergyRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
