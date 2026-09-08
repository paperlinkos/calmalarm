import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/alarm.dart';
import '../../../core/models/botanical_character.dart';
import '../../../core/services/live_alarm_ticker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../../ambient_wake/views/alarm_ringing_screen.dart';
import '../../ambient_wake/views/nightstand_screen.dart';
import '../../botanical_garden/widgets/doodle_flower_painter.dart';

class DevLabScreen extends ConsumerStatefulWidget {
  const DevLabScreen({super.key});

  @override
  ConsumerState<DevLabScreen> createState() => _DevLabScreenState();
}

class _DevLabScreenState extends ConsumerState<DevLabScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0; // 0: Sunrise, 1: Ringing, 2: Doodle, 3: Nightstand, 4: Garden

  // Sunrise Scrubber State
  double _sunriseProgress = 0.45;
  bool _isAutoPlayingSunrise = false;
  late AnimationController _sunriseAnimController;

  // Ringing Test State
  int _testSnoozesLeft = 3;
  bool _testSmartSnooze = true;
  String _testSoundscape = 'Morning Birds';

  // Doodle Studio State
  BotanicalSpecies _doodleSpecies = BotanicalSpecies.daisy;
  double _doodleBloom = 0.85;
  bool _doodleHasFire = false;
  CharacterState _doodleState = CharacterState.bloomed;

  // Streak & Growth State (from future ideas.md)
  int _testStreakDays = 7;
  bool _streakWilted = false;
  int _podWaterSavesLeft = 1;
  final List<bool> _weekHeatmap = [true, true, true, true, true, false, true];

  @override
  void initState() {
    super.initState();
    _sunriseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        if (_isAutoPlayingSunrise) {
          setState(() {
            _sunriseProgress = _sunriseAnimController.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _sunriseAnimController.dispose();
    super.dispose();
  }

  Color _getSunriseColor(double progress) {
    if (progress < 0.25) {
      return Color.lerp(
        const Color(0xFF101322),
        const Color(0xFF1E2749),
        progress / 0.25,
      )!;
    } else if (progress < 0.55) {
      return Color.lerp(
        const Color(0xFF1E2749),
        const Color(0xFF7A5C61),
        (progress - 0.25) / 0.30,
      )!;
    } else if (progress < 0.85) {
      return Color.lerp(
        const Color(0xFF7A5C61),
        const Color(0xFFE29B63),
        (progress - 0.55) / 0.30,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFE29B63),
        const Color(0xFFFAF6EE),
        (progress - 0.85) / 0.15,
      )!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.linenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.linenBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.linenTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CalmAlarm Lab',
          style: GoogleFonts.outfit(
            color: AppColors.linenTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.flaskConical, size: 14, color: AppColors.terracotta),
                const SizedBox(width: 4),
                Text(
                  'TEST BENCH',
                  style: GoogleFonts.outfit(
                    color: AppColors.terracotta,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation Tab Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTabPill(0, LucideIcons.sun, 'Sunrise Light'),
                const SizedBox(width: 8),
                _buildTabPill(1, LucideIcons.alarmClock, 'Ringing View'),
                const SizedBox(width: 8),
                _buildTabPill(2, LucideIcons.flower2, 'Doodle Studio'),
                const SizedBox(width: 8),
                _buildTabPill(3, LucideIcons.moon, 'Nightstand'),
                const SizedBox(width: 8),
                _buildTabPill(4, LucideIcons.trees, 'Isometric Garden'),
                const SizedBox(width: 8),
                _buildTabPill(5, LucideIcons.flame, 'Streaks & Growth'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.linenSurfaceBorder),

          // Active Module View
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildSunriseModule(),
                _buildRingingModule(),
                _buildDoodleModule(),
                _buildNightstandModule(),
                _buildIsometricGardenModule(),
                _buildStreakModule(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF24338A) : AppColors.linenSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF24338A) : AppColors.linenSurfaceBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF24338A).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.linenTextSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : AppColors.linenTextPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODULE 1: AMBIENT SUNRISE ILLUMINATION
  // ==========================================
  Widget _buildSunriseModule() {
    final currentColor = _getSunriseColor(_sunriseProgress);
    final isBright = _sunriseProgress > 0.6;
    final textColor = isBright ? const Color(0xFF24338A) : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ambient Sunrise Wake-up Simulator',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.linenTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Experience how your screen washes your dark room in warm daylight without harsh alarms.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.linenTextSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Live Color Window
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.linenSurfaceBorder, width: 2),
              boxShadow: [
                BoxShadow(
                  color: currentColor.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _sunriseProgress < 0.3
                          ? LucideIcons.moon
                          : _sunriseProgress < 0.7
                              ? LucideIcons.sunrise
                              : LucideIcons.sun,
                      size: 40,
                      color: textColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_sunriseProgress * 100).toInt()}% Illumination',
                      style: GoogleFonts.outfit(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _sunriseProgress < 0.25
                          ? 'Deep Midnight (#101322)'
                          : _sunriseProgress < 0.55
                              ? 'Twilight Indigo & Dusty Rose'
                              : _sunriseProgress < 0.85
                                  ? 'Golden Amber Circadian Glow'
                                  : 'Warm Linen Daylight',
                      style: GoogleFonts.inter(
                        color: textColor.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Scrubber Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manual Scrubber', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              Text('${(_sunriseProgress * 100).toInt()}%', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.terracotta)),
            ],
          ),
          Slider(
            value: _sunriseProgress,
            activeColor: AppColors.terracotta,
            inactiveColor: AppColors.linenSurfaceBorder,
            onChanged: (val) {
              if (_isAutoPlayingSunrise) {
                _sunriseAnimController.stop();
                _isAutoPlayingSunrise = false;
              }
              setState(() => _sunriseProgress = val);
            },
          ),
          const SizedBox(height: 12),

          // Playback buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (_isAutoPlayingSunrise) {
                        _sunriseAnimController.stop();
                        _isAutoPlayingSunrise = false;
                      } else {
                        _isAutoPlayingSunrise = true;
                        _sunriseAnimController.forward(from: 0.0);
                      }
                    });
                  },
                  icon: Icon(_isAutoPlayingSunrise ? LucideIcons.pause : LucideIcons.play, size: 16),
                  label: Text(_isAutoPlayingSunrise ? 'Pause Auto Sim' : 'Play 8s Dawn Simulation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24338A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _sunriseAnimController.reset();
                  setState(() {
                    _isAutoPlayingSunrise = false;
                    _sunriseProgress = 0.0;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.linenTextPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  side: const BorderSide(color: AppColors.linenSurfaceBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODULE 2: ALARM RINGING & SMART SNOOZE
  // ==========================================
  Widget _buildRingingModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alarm Ringing & Snooze Simulation',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Instantly trigger the live waking experience with customizable snooze conditions.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.linenTextSecondary),
          ),
          const SizedBox(height: 20),

          // Config Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.linenSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.linenSurfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SNOOZE CONFIGURATION', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.linenTextSecondary, letterSpacing: 1)),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Snoozes Remaining',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.linenTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [0, 1, 3].map((count) {
                        final isSel = _testSnoozesLeft == count;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _testSnoozesLeft = count);
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right: count == 3 ? 0 : 8,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF24338A) : AppColors.linenBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel ? const Color(0xFF24338A) : AppColors.linenSurfaceBorder,
                                ),
                              ),
                              child: Text(
                                count == 0 ? '0 (Final)' : '$count left',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSel ? Colors.white : AppColors.linenTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Smart Decreasing Snooze', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('10m → 7m → 5m → 2m → 1m limit', style: TextStyle(fontSize: 12)),
                  value: _testSmartSnooze,
                  activeTrackColor: AppColors.terracotta,
                  onChanged: (val) => setState(() => _testSmartSnooze = val),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Soundscape', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    DropdownButton<String>(
                      value: ['Morning Birds', 'Morning Dew', 'Soft Rain', 'Zen Bowls', 'Forest Stream', 'Mountain Stream'].contains(_testSoundscape)
                          ? _testSoundscape
                          : 'Morning Birds',
                      underline: const SizedBox(),
                      items: ['Morning Birds', 'Morning Dew', 'Soft Rain', 'Zen Bowls', 'Forest Stream', 'Mountain Stream']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _testSoundscape = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Launch Fullscreen Action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                final testAlarm = Alarm(
                  id: 'dev_test_${DateTime.now().millisecondsSinceEpoch}',
                  time: TimeOfDay.now(),
                  label: 'Lab Test Alarm',
                  snoozeDurationMinutes: 9,
                  maxSnoozeCount: _testSnoozesLeft,
                  isSmartSnooze: _testSmartSnooze,
                  soundscape: _testSoundscape,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlarmRingingScreen(alarm: testAlarm),
                  ),
                );
              },
              icon: const Icon(LucideIcons.bellRing, size: 18),
              label: const Text('Launch Fullscreen Ringing View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Background Ticker Test Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(liveAlarmTickerProvider).scheduleTestAlarmInSeconds(5);
                    AppToast.show(
                      context,
                      message: 'Real background alarm queued! Rings in 5 seconds!',
                      type: ToastType.warning,
                      icon: LucideIcons.alarmClock,
                    );
                  },
                  icon: const Icon(LucideIcons.timer, size: 16),
                  label: const Text('Ring in 5s', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.linenTextPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.linenSurfaceBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(liveAlarmTickerProvider).scheduleTestAlarmInSeconds(15);
                    AppToast.show(
                      context,
                      message: 'Real background alarm queued! Rings in 15 seconds!',
                      type: ToastType.warning,
                      icon: LucideIcons.alarmClock,
                    );
                  },
                  icon: const Icon(LucideIcons.clock, size: 16),
                  label: const Text('Ring in 15s', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.linenTextPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.linenSurfaceBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODULE 3: DOODLE CHARACTER STUDIO
  // ==========================================
  Widget _buildDoodleModule() {
    final character = BotanicalCharacter(
      id: 'studio_char',
      name: 'Studio Character',
      species: _doodleSpecies,
      state: _doodleState,
      bloomProgress: _doodleBloom,
      hasFire: _doodleHasFire,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Doodle Character Studio', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Test the hand-drawn ink vector simulation, wiggles, bloom levels, and penalty fires.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.linenTextSecondary)),
          const SizedBox(height: 16),

          // Canvas Preview
          Container(
            width: double.infinity,
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.linenSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.linenSurfaceBorder),
            ),
            child: Center(
              child: DoodleFlowerWidget(
                size: 150,
                character: character,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Species Picker
          Text('SPECIES SELECTION', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.linenTextSecondary, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            children: BotanicalSpecies.values.take(4).map((sp) {
              final isSel = _doodleSpecies == sp;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _doodleSpecies = sp);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF24338A) : AppColors.linenBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSel ? const Color(0xFF24338A) : AppColors.linenSurfaceBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      sp.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSel ? Colors.white : AppColors.linenTextPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Bloom Scrubber
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bloom Progress', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${(_doodleBloom * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF24338A))),
            ],
          ),
          Slider(
            value: _doodleBloom,
            activeColor: const Color(0xFF24338A),
            inactiveColor: AppColors.linenSurfaceBorder,
            onChanged: (val) => setState(() => _doodleBloom = val),
          ),
          const SizedBox(height: 8),

          // Penalty Fire Switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Penalty Fire (Over-snoozed)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Draws animated burning flame around the bud', style: TextStyle(fontSize: 12)),
            value: _doodleHasFire,
            activeTrackColor: AppColors.terracotta,
            onChanged: (val) => setState(() => _doodleHasFire = val),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODULE 4: NIGHTSTAND & OLED DIMMER
  // ==========================================
  Widget _buildNightstandModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bedside Nightstand Playground', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Test docked nightstand mode with pitch-black OLED background and vertical swipe dimming.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.linenTextSecondary)),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0E14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF202533)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.sparkles, size: 14, color: AppColors.warmOchre),
                    const SizedBox(width: 8),
                    Text(
                      'Gestures in Nightstand Mode:',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildNightstandGestureTip('Swipe Up/Down', 'Smoothly dims brightness down to 1% to save eyes in pitch black.'),
                const SizedBox(height: 8),
                _buildNightstandGestureTip('Double Tap', 'Toggles warm amber nightlight for bathroom trips.'),
                const SizedBox(height: 8),
                _buildNightstandGestureTip('Anti-Burn-In', 'Subtly drifts clock coordinates by 2px every 60s for OLED panels.'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NightstandScreen()),
                );
              },
              icon: const Icon(LucideIcons.moon, size: 18),
              label: const Text('Launch Nightstand Mode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2030),
                foregroundColor: AppColors.warmOchre,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightstandGestureTip(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.warmOchre, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(child: Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11))),
      ],
    );
  }

  // ==========================================
  // MODULE 5: ISOMETRIC POD GARDEN SANDBOX
  // ==========================================
  Widget _buildIsometricGardenModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Isometric Pod Garden Sandbox', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Interactive prototype for "future ideas.md": 2.5D isometric plots, member-planted color-coded flora, and plant detail inspection.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.linenTextSecondary),
          ),
          const SizedBox(height: 16),

          // Interactive Isometric Garden Canvas
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEFE9DC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.linenSurfaceBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Grid background
                  CustomPaint(
                    size: const Size(double.infinity, 320),
                    painter: _IsometricGridPainter(),
                  ),

                  // Pod Member Plant 1: You (Cobalt Daisy)
                  Positioned(
                    left: 60,
                    top: 110,
                    child: _buildIsometricPlantNode(
                      name: 'You',
                      status: 'Awake (7:00 AM)',
                      species: BotanicalSpecies.daisy,
                      streak: 7,
                      color: const Color(0xFF24338A),
                    ),
                  ),

                  // Pod Member Plant 2: Elena (Lavender Rose)
                  Positioned(
                    left: 170,
                    top: 50,
                    child: _buildIsometricPlantNode(
                      name: 'Elena',
                      status: 'Awake (6:45 AM)',
                      species: BotanicalSpecies.rose,
                      streak: 14,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),

                  // Pod Member Plant 3: Marcus (Sage Mushroom)
                  Positioned(
                    left: 180,
                    top: 170,
                    child: _buildIsometricPlantNode(
                      name: 'Marcus',
                      status: 'Sleeping (Alarms in 22m)',
                      species: BotanicalSpecies.mushroom,
                      streak: 3,
                      color: const Color(0xFF10B981),
                    ),
                  ),

                  // Instruction Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Tap any plant to inspect!', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text('ISOMETRIC GARDEN VISION (from future ideas.md)', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.linenTextSecondary, letterSpacing: 1)),
          const SizedBox(height: 8),
          _buildFeatureBullet('Interactive 2.5D Canvas', 'Pinch-to-zoom and pan across a peaceful garden populated by pod mates.'),
          _buildFeatureBullet('Member Color Coding', 'Each friend gets a distinctive hand-drawn ink colorway for their personal flower.'),
          _buildFeatureBullet('Deep Plant Inspection', 'Tapping displays wake streaks, hydration level, and allows watering or sending morning sunbeams.'),
        ],
      ),
    );
  }

  Widget _buildIsometricPlantNode({
    required String name,
    required String status,
    required BotanicalSpecies species,
    required int streak,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showPlantDetailModal(name: name, status: status, species: species, streak: streak, color: color);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: DoodleFlowerWidget(
              size: 48,
              character: BotanicalCharacter(
                id: name,
                name: name,
                species: species,
                bloomProgress: status.startsWith('Awake') ? 1.0 : 0.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlantDetailModal({
    required String name,
    required String status,
    required BotanicalSpecies species,
    required int streak,
    required Color color,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.linenBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.linenSurfaceBorder, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Row(
                children: [
                  DoodleFlowerWidget(
                    size: 60,
                    character: BotanicalCharacter(id: name, name: name, species: species, bloomProgress: 1.0),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$name\'s ${species.name.toUpperCase()}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(status, style: GoogleFonts.inter(fontSize: 12, color: AppColors.linenTextSecondary)),
                        Text('$streak-day consistent wake streak', style: GoogleFonts.inter(fontSize: 12, color: AppColors.terracotta, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                        AppToast.show(
                          context,
                          message: 'Watered $name\'s plant!',
                          type: ToastType.success,
                          icon: LucideIcons.droplets,
                        );
                      },
                      icon: const Icon(LucideIcons.droplets, size: 16),
                      label: const Text('Water Plant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24338A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                        AppToast.show(
                          context,
                          message: 'Sent morning sunbeam to $name!',
                          type: ToastType.info,
                          icon: LucideIcons.sunMedium,
                        );
                      },
                      icon: const Icon(LucideIcons.sunMedium, size: 16),
                      label: const Text('Send Sunbeam'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.linenTextPrimary,
                        side: const BorderSide(color: AppColors.linenSurfaceBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // MODULE 6: STREAKS & HABIT GROWTH (from future ideas.md)
  // ==========================================
  Widget _buildStreakModule() {
    final String stageName;
    final String stageDesc;
    final double plantScale;
    final double bloomProgress;
    final Color tierColor;

    if (_testStreakDays <= 2) {
      stageName = 'Seedling Sprout (Stage 1)';
      stageDesc = 'Just planted! Gentle hydration keeps the seed nourished.';
      plantScale = 0.65;
      bloomProgress = 0.3;
      tierColor = AppColors.sageGreen;
    } else if (_testStreakDays <= 6) {
      stageName = 'Growing Stem & Bud (Stage 2)';
      stageDesc = 'Habit forming! Leaves reaching upward toward dawn.';
      plantScale = 0.85;
      bloomProgress = 0.6;
      tierColor = AppColors.warmOchre;
    } else if (_testStreakDays <= 13) {
      stageName = 'Full Bloomed Flora (Stage 3)';
      stageDesc = '1-week consistency! Petals radiant and open.';
      plantScale = 1.05;
      bloomProgress = 1.0;
      tierColor = const Color(0xFF24338A);
    } else if (_testStreakDays <= 29) {
      stageName = 'Radiant Pod Guardian (Stage 4)';
      stageDesc = '2-week mastery! Accompanied by friendly bumblebee companion.';
      plantScale = 1.25;
      bloomProgress = 1.0;
      tierColor = const Color(0xFF8B5CF6);
    } else {
      stageName = 'Legendary Botanical Elder (Stage 5)';
      stageDesc = '30+ Days Wake Mastery! Golden aura and ancient crown.';
      plantScale = 1.45;
      bloomProgress = 1.0;
      tierColor = AppColors.terracotta;
    }

    final character = BotanicalCharacter(
      id: 'streak_char',
      name: 'Streak Flower',
      species: _doodleSpecies,
      bloomProgress: _streakWilted ? 0.2 : bloomProgress,
      hasFire: _streakWilted,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak & Botanical Evolution',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Preview how wake consistency from "future ideas.md" scales, blooms, and evolves your garden plant.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.linenTextSecondary),
          ),
          const SizedBox(height: 16),

          // Live Plant Showcase Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.linenSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.linenSurfaceBorder),
            ),
            child: Column(
              children: [
                // Top Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tierColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.flame, size: 13, color: tierColor),
                          const SizedBox(width: 4),
                          Text(
                            '$_testStreakDays-DAY STREAK',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: tierColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.shieldCheck, size: 12, color: AppColors.sageGreen),
                          const SizedBox(width: 4),
                          Text(
                            '$_podWaterSavesLeft Pod Save Available',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.sageGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Doodle Character Render with dynamic scale
                SizedBox(
                  height: 180,
                  child: Center(
                    child: Transform.scale(
                      scale: plantScale.clamp(0.6, 1.4),
                      child: DoodleFlowerWidget(
                        size: 130,
                        character: character,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Stage Title & Subtitle
                Text(
                  _streakWilted ? 'Wilted Embers (Missed Wake)' : stageName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _streakWilted ? AppColors.terracotta : AppColors.linenTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _streakWilted
                      ? 'Plant needs watering from a pod friend to revive the streak!'
                      : stageDesc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.linenTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Streak Scrubber Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Simulate Streak Days', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              Text('$_testStreakDays Days', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFF24338A))),
            ],
          ),
          Slider(
            value: _testStreakDays.toDouble(),
            min: 1,
            max: 45,
            divisions: 44,
            activeColor: const Color(0xFF24338A),
            inactiveColor: AppColors.linenSurfaceBorder,
            onChanged: (val) {
              setState(() {
                _testStreakDays = val.toInt();
                _streakWilted = false;
              });
            },
          ),

          // Quick Jump Buttons
          Row(
            children: [1, 7, 14, 30].map((days) {
              final isSel = _testStreakDays == days;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _testStreakDays = days;
                      _streakWilted = false;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF24338A) : AppColors.linenSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSel ? const Color(0xFF24338A) : AppColors.linenSurfaceBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Day $days',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSel ? Colors.white : AppColors.linenTextPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 7-Day Consistency Dot Matrix
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.linenSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.linenSurfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('7-DAY HABIT MATRIX', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.linenTextSecondary, letterSpacing: 1)),
                    Text('Tap dots to toggle!', style: GoogleFonts.inter(fontSize: 11, color: AppColors.linenTextSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final isWoke = _weekHeatmap[i];
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _weekHeatmap[i] = !_weekHeatmap[i];
                        });
                      },
                      child: Column(
                        children: [
                          Text(days[i], style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.linenTextSecondary)),
                          const SizedBox(height: 6),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isWoke ? const Color(0xFF24338A) : AppColors.linenBackground,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isWoke ? const Color(0xFF24338A) : AppColors.linenSurfaceBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              isWoke ? LucideIcons.check : LucideIcons.moon,
                              size: 14,
                              color: isWoke ? Colors.white : AppColors.linenTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Interactive Simulation Actions
          Text('SIMULATE DAILY EVENTS', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.linenTextSecondary, letterSpacing: 1)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _testStreakDays++;
                      _streakWilted = false;
                    });
                    AppToast.show(
                      context,
                      message: 'On-time wake recorded! Streak is now $_testStreakDays days!',
                      type: ToastType.success,
                      icon: LucideIcons.sunMedium,
                    );
                  },
                  icon: const Icon(LucideIcons.sunMedium, size: 16),
                  label: const Text('Wake (+1 Day)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24338A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _streakWilted = true;
                    });
                    AppToast.show(
                      context,
                      message: 'Simulated over-snooze: plant wilted until watered!',
                      type: ToastType.warning,
                      icon: LucideIcons.alertTriangle,
                    );
                  },
                  icon: const Icon(LucideIcons.alertTriangle, size: 16),
                  label: const Text('Over-snooze'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.terracotta,
                    side: const BorderSide(color: AppColors.terracotta),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                setState(() {
                  _streakWilted = false;
                  if (_testStreakDays < 1) _testStreakDays = 1;
                });
                AppToast.show(
                  context,
                  message: 'Pod friend watered your plot! Streak rescued & plant revived!',
                  type: ToastType.success,
                  icon: LucideIcons.droplets,
                );
              },
              icon: const Icon(LucideIcons.droplets, size: 16),
              label: const Text('Pod Water Revival (Rescue Streak)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gardenWater,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.linenTextPrimary),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc, style: const TextStyle(color: AppColors.linenTextSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IsometricGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFDDD4C2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const tileWidth = 60.0;
    const tileHeight = 30.0;

    for (double y = 0; y < size.height + 60; y += tileHeight) {
      for (double x = -tileWidth; x < size.width + tileWidth; x += tileWidth) {
        final path = Path();
        path.moveTo(x, y);
        path.lineTo(x + tileWidth / 2, y + tileHeight / 2);
        path.lineTo(x, y + tileHeight);
        path.lineTo(x - tileWidth / 2, y + tileHeight / 2);
        path.close();
        canvas.drawPath(path, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
