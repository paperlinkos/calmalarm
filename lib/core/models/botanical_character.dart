enum BotanicalSpecies { daisy, rose, mushroom, tree, lotus, bonsai }
enum CharacterState { asleep, waking, bloomed, inFocus, needsWater }
enum CharacterArtStyle { handDrawnInk, watercolor }

class BotanicalCharacter {
  final String id;
  final String name;
  final BotanicalSpecies species;
  final CharacterState state;
  final CharacterArtStyle artStyle;
  final double bloomProgress; // 0.0 (Asleep) to 1.0 (Full Bloom)
  final bool hasFire; // Playful accountability penalty
  final double hydration; // 0.0 to 1.0

  const BotanicalCharacter({
    required this.id,
    required this.name,
    required this.species,
    this.state = CharacterState.asleep,
    this.artStyle = CharacterArtStyle.handDrawnInk,
    this.bloomProgress = 0.0,
    this.hasFire = false,
    this.hydration = 0.8,
  });

  BotanicalCharacter copyWith({
    String? id,
    String? name,
    BotanicalSpecies? species,
    CharacterState? state,
    CharacterArtStyle? artStyle,
    double? bloomProgress,
    bool? hasFire,
    double? hydration,
  }) {
    return BotanicalCharacter(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      state: state ?? this.state,
      artStyle: artStyle ?? this.artStyle,
      bloomProgress: bloomProgress ?? this.bloomProgress,
      hasFire: hasFire ?? this.hasFire,
      hydration: hydration ?? this.hydration,
    );
  }
}
