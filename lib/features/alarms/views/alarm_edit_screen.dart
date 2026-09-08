import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/alarm.dart';
import '../../../core/services/local_alarm_service.dart';
import '../../../core/services/sync_pod_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';

class AlarmEditScreen extends ConsumerStatefulWidget {
  final Alarm? existingAlarm;

  const AlarmEditScreen({super.key, this.existingAlarm});

  @override
  ConsumerState<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends ConsumerState<AlarmEditScreen> {
  late TimeOfDay _time;
  late TextEditingController _labelController;
  late List<int> _repeatDays;
  late int _ambientDuration;
  late String _soundscape;
  late double _volume;
  late int _fadeDuration;
  late String _vibration;
  late int _snoozeDuration;
  late int _maxSnooze;
  late bool _smartSnooze;
  late bool _snoozePenalty;
  late String _dismissChallenge;
  late bool _linkToPod;

  final List<String> _soundscapes = [
    'Morning Birds',
    'Mountain Stream',
    'Tibetan Singing Bowls',
    'Soft Rain on Leaves',
    'Muted Chimes',
    'Silent Visual Only',
  ];

  final List<String> _vibrations = [
    'Gentle Waves',
    'Heartbeat',
    'Ascending Pulses',
    'Continuous',
    'Off',
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.existingAlarm;
    _time = a?.time ?? const TimeOfDay(hour: 7, minute: 0);
    _labelController = TextEditingController(text: a?.label ?? 'Circadian Sunrise');
    _repeatDays = List.from(a?.repeatDays ?? [1, 2, 3, 4, 5]);
    _ambientDuration = a?.ambientDurationMinutes ?? 15;
    _soundscape = a?.soundscape ?? 'Morning Birds';
    _volume = a?.volumeLevel ?? 0.8;
    _fadeDuration = a?.gradualFadeDurationSeconds ?? 60;
    _vibration = a?.vibrationPattern ?? 'Gentle Waves';
    _snoozeDuration = a?.snoozeDurationMinutes ?? 9;
    _maxSnooze = a?.maxSnoozeCount ?? 3;
    _smartSnooze = a?.isSmartSnooze ?? false;
    _snoozePenalty = a?.snoozePenaltyEnabled ?? true;
    _dismissChallenge = a?.dismissChallenge ?? 'Slide to Dismiss';
    _linkToPod = a?.syncPodId != null;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Alarm _buildCurrentAlarm() {
    return Alarm(
      id: widget.existingAlarm?.id ?? 'alarm_${DateTime.now().millisecondsSinceEpoch}',
      time: _time,
      label: _labelController.text.trim().isEmpty ? 'Morning Wake' : _labelController.text.trim(),
      isEnabled: true,
      repeatDays: _repeatDays,
      ambientDurationMinutes: _ambientDuration,
      soundscape: _soundscape,
      volumeLevel: _volume,
      gradualFadeDurationSeconds: _fadeDuration,
      vibrationPattern: _vibration,
      snoozeDurationMinutes: _snoozeDuration,
      maxSnoozeCount: _maxSnooze,
      isSmartSnooze: _smartSnooze,
      snoozePenaltyEnabled: _snoozePenalty,
      dismissChallenge: _dismissChallenge,
      syncPodId: _linkToPod ? 'pod_commute_1' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final podState = ref.watch(syncPodProvider);
    final tempAlarm = _buildCurrentAlarm();

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
          widget.existingAlarm != null ? 'Edit Alarm' : 'New Sunrise Alarm',
          style: GoogleFonts.outfit(
            color: AppColors.linenTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final saved = _buildCurrentAlarm();
              if (widget.existingAlarm != null) {
                ref.read(alarmListProvider.notifier).updateAlarm(saved);
              } else {
                ref.read(alarmListProvider.notifier).addAlarm(saved);
              }
              Navigator.pop(context);
              AppToast.show(
                context,
                message: '${saved.label} set for ${saved.formattedTime} (${saved.countdownString})',
                type: ToastType.success,
                icon: LucideIcons.checkCircle2,
              );
            },
            child: Text(
              'Save',
              style: GoogleFonts.outfit(
                color: AppColors.terracotta,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Interactive Time Picker Card
            _buildTimePickerCard(tempAlarm),

            const SizedBox(height: 20),

            // 2. Alarm Label Input
            _buildSectionContainer(
              child: TextField(
                controller: _labelController,
                style: GoogleFonts.outfit(
                  color: AppColors.linenTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Alarm Label',
                  labelStyle: GoogleFonts.inter(color: AppColors.linenTextSecondary),
                  prefixIcon: const Icon(LucideIcons.tag, size: 18, color: AppColors.terracotta),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 3. Repeat Days Selector
            _buildRepeatDaysCard(),

            const SizedBox(height: 18),

            // 4. Ambient Sunrise Duration
            _buildAmbientSunriseCard(),

            const SizedBox(height: 18),

            // 5. Soundscape & Volume Ramp
            _buildSoundscapeCard(),

            const SizedBox(height: 18),

            // 6. Snooze & Anti-Oversleep Rules
            _buildSnoozeRulesCard(),

            const SizedBox(height: 18),

            // 7. Pod Sync Toggle
            _buildPodSyncCard(podState.podName),

            const SizedBox(height: 28),

            // 8. Delete Button (if editing)
            if (widget.existingAlarm != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(alarmListProvider.notifier).deleteAlarm(widget.existingAlarm!.id);
                    Navigator.pop(context);
                    AppToast.show(
                      context,
                      message: 'Alarm deleted',
                      type: ToastType.warning,
                      icon: LucideIcons.trash2,
                    );
                  },
                  icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.warningFire),
                  label: Text(
                    'Delete Alarm',
                    style: GoogleFonts.outfit(
                      color: AppColors.warningFire,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.warningFire.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerCard(Alarm alarm) {
    final hour = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final minute = _time.minute.toString().padLeft(2, '0');
    final isAm = _time.period == DayPeriod.am;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.linenSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.linenSurfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: _time);
                  if (picked != null) setState(() => _time = picked);
                },
                child: Text(
                  '$hour:$minute',
                  style: GoogleFonts.outfit(
                    color: AppColors.linenTextPrimary,
                    fontSize: 68,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2.0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  final newHour = isAm ? _time.hour + 12 : _time.hour - 12;
                  setState(() {
                    _time = TimeOfDay(hour: newHour % 24, minute: _time.minute);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isAm ? 'AM' : 'PM',
                    style: GoogleFonts.outfit(
                      color: AppColors.terracotta,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick increment buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeIncrementChip('-1h', () {
                HapticFeedback.selectionClick();
                setState(() => _time = TimeOfDay(hour: (_time.hour - 1 + 24) % 24, minute: _time.minute));
              }),
              const SizedBox(width: 8),
              _buildTimeIncrementChip('+1h', () {
                HapticFeedback.selectionClick();
                setState(() => _time = TimeOfDay(hour: (_time.hour + 1) % 24, minute: _time.minute));
              }),
              const SizedBox(width: 14),
              _buildTimeIncrementChip('-5m', () {
                HapticFeedback.selectionClick();
                setState(() => _time = TimeOfDay(hour: _time.hour, minute: (_time.minute - 5 + 60) % 60));
              }),
              const SizedBox(width: 8),
              _buildTimeIncrementChip('+5m', () {
                HapticFeedback.selectionClick();
                setState(() => _time = TimeOfDay(hour: _time.hour, minute: (_time.minute + 5) % 60));
              }),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sageGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.hourglass, size: 14, color: AppColors.sageGreen),
                const SizedBox(width: 6),
                Text(
                  alarm.countdownString,
                  style: GoogleFonts.outfit(
                    color: AppColors.sageGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeIncrementChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.linenBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.linenSurfaceBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: AppColors.linenTextPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatDaysCard() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REPEAT DAYS',
                style: GoogleFonts.outfit(
                  color: AppColors.linenTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                _repeatDays.isEmpty ? 'Once' : (_repeatDays.length == 7 ? 'Every day' : 'Custom'),
                style: GoogleFonts.inter(
                  color: AppColors.terracotta,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayNum = index + 1; // 1 = Mon, 7 = Sun
              final isSelected = _repeatDays.contains(dayNum);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _repeatDays.remove(dayNum);
                    } else {
                      _repeatDays.add(dayNum);
                    }
                    _repeatDays.sort();
                  });
                },
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.terracotta : AppColors.linenBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.terracotta : AppColors.linenSurfaceBorder,
                    ),
                  ),
                  child: Text(
                    days[index],
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : AppColors.linenTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Quick presets
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildPresetChip('Weekdays', () {
                setState(() => _repeatDays = [1, 2, 3, 4, 5]);
              }),
              _buildPresetChip('Weekends', () {
                setState(() => _repeatDays = [6, 7]);
              }),
              _buildPresetChip('Daily', () {
                setState(() => _repeatDays = [1, 2, 3, 4, 5, 6, 7]);
              }),
              _buildPresetChip('Once', () {
                setState(() => _repeatDays = []);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientSunriseCard() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.sun, size: 18, color: AppColors.warmOchre),
                  const SizedBox(width: 8),
                  Text(
                    'AMBIENT SUNRISE WAKE',
                    style: GoogleFonts.outfit(
                      color: AppColors.linenTextSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Text(
                _ambientDuration == 0 ? 'Off' : '$_ambientDuration min fade',
                style: GoogleFonts.outfit(
                  color: AppColors.warmOchre,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _ambientDuration == 0
                ? 'Screen remains dark until alarm rings.'
                : 'Screen subtly begins warming up $_ambientDuration minutes before audio, transitioning through circadian dawn light.',
            style: GoogleFonts.inter(
              color: AppColors.linenTextSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _ambientDuration.toDouble(),
            min: 0,
            max: 30,
            divisions: 6, // 0, 5, 10, 15, 20, 25, 30
            activeColor: AppColors.warmOchre,
            onChanged: (val) {
              setState(() {
                _ambientDuration = val.round();
              });
            },
          ),
          if (_ambientDuration > 0) ...[
            const SizedBox(height: 6),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2C1A1D), // Dark Amber Dawn
                    Color(0xFF8A3B2B), // Terracotta
                    Color(0xFFE05A36), // Sunrise Amber
                    Color(0xFFFFB74D), // Golden Hour
                    Color(0xFFF5F2EB), // Warm Daylight
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Amber', style: GoogleFonts.inter(fontSize: 10, color: AppColors.linenTextSecondary)),
                Text('Warm Daylight', style: GoogleFonts.inter(fontSize: 10, color: AppColors.linenTextSecondary)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSoundscapeCard() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOUND & VIBRATION',
            style: GoogleFonts.outfit(
              color: AppColors.linenTextSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          // Sound dropdown
          DropdownButtonFormField<String>(
            initialValue: _soundscape,
            decoration: InputDecoration(
              labelText: 'Soundscape',
              prefixIcon: const Icon(LucideIcons.volume2, size: 18, color: AppColors.terracotta),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: _soundscapes.map((s) {
              return DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.outfit(fontSize: 14)));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _soundscape = val);
            },
          ),
          const SizedBox(height: 14),
          // Gradual ramp-up
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gradual Volume Ramp',
                style: GoogleFonts.inter(
                  color: AppColors.linenTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DropdownButton<int>(
                value: _fadeDuration,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Instant')),
                  DropdownMenuItem(value: 30, child: Text('30 sec')),
                  DropdownMenuItem(value: 60, child: Text('1 min')),
                  DropdownMenuItem(value: 120, child: Text('2 min')),
                  DropdownMenuItem(value: 300, child: Text('5 min')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _fadeDuration = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Vibration Pattern
          DropdownButtonFormField<String>(
            initialValue: _vibration,
            decoration: InputDecoration(
              labelText: 'Vibration Pattern',
              prefixIcon: const Icon(LucideIcons.vibrate, size: 18, color: AppColors.sageGreen),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: _vibrations.map((v) {
              return DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.outfit(fontSize: 14)));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _vibration = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSnoozeRulesCard() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.alarmClockOff, size: 18, color: AppColors.terracotta),
              const SizedBox(width: 8),
              Text(
                'SNOOZE & ANTI-OVERSLEEP RULES',
                style: GoogleFonts.outfit(
                  color: AppColors.linenTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Snooze duration selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Snooze Duration',
                  style: GoogleFonts.inter(
                    color: AppColors.linenTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _snoozeDuration,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5 min')),
                  DropdownMenuItem(value: 9, child: Text('9 min (Standard)')),
                  DropdownMenuItem(value: 10, child: Text('10 min')),
                  DropdownMenuItem(value: 15, child: Text('15 min')),
                  DropdownMenuItem(value: 20, child: Text('20 min')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _snoozeDuration = val);
                },
              ),
            ],
          ),
          const Divider(),
          // Max snoozes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Max Snooze Limit',
                  style: GoogleFonts.inter(
                    color: AppColors.linenTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _maxSnooze,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('No Snooze')),
                  DropdownMenuItem(value: 1, child: Text('1 time')),
                  DropdownMenuItem(value: 2, child: Text('2 times')),
                  DropdownMenuItem(value: 3, child: Text('3 times')),
                  DropdownMenuItem(value: 99, child: Text('Unlimited')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _maxSnooze = val);
                },
              ),
            ],
          ),
          const Divider(),
          // Smart decreasing snooze
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Smart Decreasing Snooze',
              style: GoogleFonts.inter(
                color: AppColors.linenTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Shrinks snooze window with each press (e.g. 10m → 7m → 5m → 2m)',
              style: GoogleFonts.inter(color: AppColors.linenTextSecondary, fontSize: 12),
            ),
            value: _smartSnooze,
            activeTrackColor: AppColors.terracotta,
            onChanged: (val) => setState(() => _smartSnooze = val),
          ),
          const Divider(),
          // Pod fire penalty hook
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Pod Garden Penalty on Snooze',
              style: GoogleFonts.inter(
                color: AppColors.linenTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Sparks playful embers on your plot in the shared pod when you snooze',
              style: GoogleFonts.inter(color: AppColors.linenTextSecondary, fontSize: 12),
            ),
            value: _snoozePenalty,
            activeTrackColor: AppColors.terracotta,
            onChanged: (val) => setState(() => _snoozePenalty = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPodSyncCard(String podName) {
    return _buildSectionContainer(
      child: SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(
          'Link to Sync Pod',
          style: GoogleFonts.outfit(
            color: AppColors.linenTextPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          _linkToPod ? 'Synced with $podName' : 'Private alarm only',
          style: GoogleFonts.inter(
            color: _linkToPod ? AppColors.sageGreen : AppColors.linenTextSecondary,
            fontSize: 12,
            fontWeight: _linkToPod ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        secondary: const Icon(LucideIcons.users, color: AppColors.terracotta),
        value: _linkToPod,
        activeTrackColor: AppColors.terracotta,
        onChanged: (val) => setState(() => _linkToPod = val),
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.linenSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.linenSurfaceBorder),
      ),
      child: child,
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.linenBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.linenSurfaceBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: AppColors.linenTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
