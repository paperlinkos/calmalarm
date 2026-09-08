import 'botanical_character.dart';

class PodMember {
  final String id;
  final String name;
  final String avatarUrl;
  final String timezoneOffset;
  final String localPhase; // e.g. "7:15 AM (Dawn)" or "11:15 PM (Night)"
  final bool isAwake;
  final int streakDays;
  final BotanicalCharacter character;

  const PodMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.timezoneOffset,
    required this.localPhase,
    required this.isAwake,
    required this.streakDays,
    required this.character,
  });

  PodMember copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? timezoneOffset,
    String? localPhase,
    bool? isAwake,
    int? streakDays,
    BotanicalCharacter? character,
  }) {
    return PodMember(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      localPhase: localPhase ?? this.localPhase,
      isAwake: isAwake ?? this.isAwake,
      streakDays: streakDays ?? this.streakDays,
      character: character ?? this.character,
    );
  }
}
