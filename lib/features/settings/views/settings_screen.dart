import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../../dev_lab/views/dev_lab_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _use24Hour = false;
  int _defaultSnooze = 9;
  int _defaultSunrise = 15;
  String _themeMode = 'Linen Day';

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
          'Settings & Sanctuary',
          style: GoogleFonts.outfit(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Android Battery Optimization Warning / Tip
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.sageGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.shieldCheck, size: 20, color: AppColors.sageGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reliable Background Alarms',
                          style: GoogleFonts.outfit(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'To ensure your alarm always fires on time even in deep Doze mode, please allow CalmAlarm to ignore battery optimization.',
                    style: GoogleFonts.inter(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      AppToast.show(
                        context,
                        message: 'Battery optimization exempted!',
                        type: ToastType.success,
                        icon: LucideIcons.shieldCheck,
                      );
                    },
                    icon: const Icon(LucideIcons.check, size: 14),
                    label: const Text('Exempt from Battery Optimization', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sageGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Time & Display Preferences
            Text(
              'DISPLAY & TIME',
              style: GoogleFonts.outfit(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingsContainer(
              context: context,
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '24-Hour Time Format',
                    style: GoogleFonts.inter(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _use24Hour ? 'Example: 19:30' : 'Example: 7:30 PM',
                    style: GoogleFonts.inter(color: textSecondary, fontSize: 12),
                  ),
                  value: _use24Hour,
                  activeTrackColor: AppColors.terracotta,
                  onChanged: (val) => setState(() => _use24Hour = val),
                ),
                Divider(color: border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'App Visual Theme',
                        style: GoogleFonts.inter(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: ref.watch(themeModeProvider).label,
                      underline: const SizedBox(),
                      dropdownColor: surface,
                      style: GoogleFonts.outfit(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      items: [
                        DropdownMenuItem(value: 'Linen Day', child: Text('Linen Day (Light)', style: TextStyle(color: textPrimary))),
                        DropdownMenuItem(value: 'Midnight OLED', child: Text('Midnight (OLED Dark)', style: TextStyle(color: textPrimary))),
                        DropdownMenuItem(value: 'System', child: Text('System Default', style: TextStyle(color: textPrimary))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(themeModeProvider.notifier).setThemeFromLabel(val);
                          AppToast.show(
                            context,
                            message: 'Theme switched to $val',
                            type: ToastType.info,
                            icon: LucideIcons.sparkles,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. Default Alarm Behavior
            Text(
              'ALARM DEFAULTS',
              style: GoogleFonts.outfit(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingsContainer(
              context: context,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Default Snooze',
                        style: GoogleFonts.inter(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _defaultSnooze,
                      underline: const SizedBox(),
                      dropdownColor: surface,
                      style: GoogleFonts.outfit(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      items: [
                        DropdownMenuItem(value: 5, child: Text('5 min', style: TextStyle(color: textPrimary))),
                        DropdownMenuItem(value: 9, child: Text('9 min', style: TextStyle(color: textPrimary))),
                        DropdownMenuItem(value: 10, child: Text('10 min', style: TextStyle(color: textPrimary))),
                        DropdownMenuItem(value: 15, child: Text('15 min', style: TextStyle(color: textPrimary))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _defaultSnooze = val);
                      },
                    ),
                  ],
                ),
                Divider(color: border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Default Sunrise Fade',
                        style: GoogleFonts.inter(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _defaultSunrise,
                      underline: const SizedBox(),
                      dropdownColor: surface,
                      style: GoogleFonts.outfit(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      items: [
                        DropdownMenuItem(value: 5, child: Text('5 min', style: TextStyle(color: textPrimary))),
                        DropdownMenuItem(value: 10, child: Text('10 min', style: TextStyle(color: textPrimary))),
                        DropdownMenuItem(value: 15, child: Text('15 min', style: TextStyle(color: textPrimary))),
                        DropdownMenuItem(value: 20, child: Text('20 min', style: TextStyle(color: textPrimary))),
                        DropdownMenuItem(value: 30, child: Text('30 min', style: TextStyle(color: textPrimary))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _defaultSunrise = val);
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. Developer & Testing Lab
            Text(
              'EXPERIMENTS & TESTING',
              style: GoogleFonts.outfit(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingsContainer(
              context: context,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.flaskConical, color: AppColors.terracotta, size: 20),
                  ),
                  title: Text('CalmAlarm Laboratory', style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700)),
                  subtitle: Text('Interactive test bench for sunrise scrubber, snooze simulation, doodle studio, & isometric garden.', style: GoogleFonts.inter(color: textSecondary, fontSize: 12)),
                  trailing: Icon(LucideIcons.chevronRight, size: 18, color: textSecondary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DevLabScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 5. Open Source & F-Droid Compliance
            Text(
              'ABOUT CALMALARM',
              style: GoogleFonts.outfit(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            _buildSettingsContainer(
              context: context,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.packageCheck, color: AppColors.terracotta),
                  title: Text('Version 1.0.0 (F-Droid FOSS)', style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700)),
                  subtitle: Text('100% Free & Open Source Software', style: GoogleFonts.inter(color: textSecondary, fontSize: 12)),
                ),
                Divider(color: border),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.shield, color: AppColors.sageGreen),
                  title: Text('Privacy First', style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700)),
                  subtitle: Text('Zero analytics, zero trackers, no proprietary Google SDKs.', style: GoogleFonts.inter(color: textSecondary, fontSize: 12)),
                ),
                Divider(color: border),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(LucideIcons.github, color: textPrimary),
                  title: Text('Source Code & License', style: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700)),
                  subtitle: Text('GNU General Public License v3.0', style: GoogleFonts.inter(color: textSecondary, fontSize: 12)),
                ),
              ],
            ),

            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({required BuildContext context, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(children: children),
    );
  }
}
