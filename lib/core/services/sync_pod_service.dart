import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/botanical_character.dart';
import '../models/pod_member.dart';

final syncPodProvider = StateNotifierProvider<SyncPodNotifier, SyncPodState>((ref) {
  return SyncPodNotifier();
});

class SyncPodState {
  final String podName;
  final String podCode;
  final int sharedStreak;
  final List<PodMember> members;

  const SyncPodState({
    required this.podName,
    required this.podCode,
    required this.sharedStreak,
    required this.members,
  });

  SyncPodState copyWith({
    String? podName,
    String? podCode,
    int? sharedStreak,
    List<PodMember>? members,
  }) {
    return SyncPodState(
      podName: podName ?? this.podName,
      podCode: podCode ?? this.podCode,
      sharedStreak: sharedStreak ?? this.sharedStreak,
      members: members ?? this.members,
    );
  }
}

class SyncPodNotifier extends StateNotifier<SyncPodState> {
  SyncPodNotifier()
      : super(
          const SyncPodState(
            podName: 'Tokyo-London Sunrise Pod',
            podCode: 'CALM-8921',
            sharedStreak: 12,
            members: [
              PodMember(
                id: 'mem_1',
                name: 'You (Alex)',
                avatarUrl: '',
                timezoneOffset: 'UTC+0 (London)',
                localPhase: '7:00 AM (Dawn)',
                isAwake: true,
                streakDays: 12,
                character: BotanicalCharacter(
                  id: 'char_1',
                  name: 'Doodle Daisy',
                  species: BotanicalSpecies.daisy,
                  state: CharacterState.bloomed,
                  bloomProgress: 1.0,
                  hasFire: false,
                ),
              ),
              PodMember(
                id: 'mem_2',
                name: 'Yuki (Tokyo)',
                avatarUrl: '',
                timezoneOffset: 'UTC+9 (Tokyo)',
                localPhase: '4:00 PM (Afternoon)',
                isAwake: true,
                streakDays: 14,
                character: BotanicalCharacter(
                  id: 'char_2',
                  name: 'Swirl Rose',
                  species: BotanicalSpecies.rose,
                  state: CharacterState.inFocus,
                  bloomProgress: 0.85,
                  hasFire: false,
                ),
              ),
              PodMember(
                id: 'mem_3',
                name: 'Elena (New York)',
                avatarUrl: '',
                timezoneOffset: 'UTC-5 (New York)',
                localPhase: '2:00 AM (Overnight)',
                isAwake: false,
                streakDays: 10,
                character: BotanicalCharacter(
                  id: 'char_3',
                  name: 'Spotted Mushroom',
                  species: BotanicalSpecies.mushroom,
                  state: CharacterState.asleep,
                  bloomProgress: 0.2,
                  hasFire: true, // Needs morning wake nudge!
                ),
              ),
            ],
          ),
        );

  void sendWateringNudge(String memberId) {
    state = state.copyWith(
      members: [
        for (final m in state.members)
          if (m.id == memberId)
            m.copyWith(
              character: m.character.copyWith(
                hasFire: false,
                hydration: 1.0,
                bloomProgress: (m.character.bloomProgress + 0.4).clamp(0.0, 1.0),
                state: CharacterState.bloomed,
              ),
            )
          else
            m
      ],
    );
  }

  void toggleMyAwakeState() {
    final myIndex = state.members.indexWhere((m) => m.id == 'mem_1');
    if (myIndex != -1) {
      final current = state.members[myIndex];
      final newAwake = !current.isAwake;
      state = state.copyWith(
        members: [
          for (final m in state.members)
            if (m.id == 'mem_1')
              m.copyWith(
                isAwake: newAwake,
                character: m.character.copyWith(
                  bloomProgress: newAwake ? 1.0 : 0.2,
                  state: newAwake ? CharacterState.bloomed : CharacterState.asleep,
                ),
              )
            else
              m
        ],
      );
    }
  }

  void cycleMySpecies() {
    final myIndex = state.members.indexWhere((m) => m.id == 'mem_1');
    if (myIndex != -1) {
      final current = state.members[myIndex];
      final nextSpecies = BotanicalSpecies.values[
          (current.character.species.index + 1) % BotanicalSpecies.values.length];
      
      String name = 'Doodle Daisy';
      if (nextSpecies == BotanicalSpecies.rose) name = 'Swirl Rose';
      if (nextSpecies == BotanicalSpecies.mushroom) name = 'Spotted Mushroom';
      if (nextSpecies == BotanicalSpecies.tree) name = 'Sprout Tree';

      state = state.copyWith(
        members: [
          for (final m in state.members)
            if (m.id == 'mem_1')
              m.copyWith(
                character: m.character.copyWith(
                  species: nextSpecies,
                  name: name,
                ),
              )
            else
              m
        ],
      );
    }
  }
}
