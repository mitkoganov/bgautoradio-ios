enum RadioCategory {
  national,
  news,
  pop,
  rock,
  dance,
  folk,
  folkPop,
  jazz,
  classical,
  regional,
  talk,
  retro,
  hiphop,
  urban,
  online,
  other;

  static RadioCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'national': return RadioCategory.national;
      case 'news': return RadioCategory.news;
      case 'pop': return RadioCategory.pop;
      case 'rock': return RadioCategory.rock;
      case 'dance': return RadioCategory.dance;
      case 'folk': return RadioCategory.folk;
      case 'folk_pop': return RadioCategory.folkPop;
      case 'jazz': return RadioCategory.jazz;
      case 'classical': return RadioCategory.classical;
      case 'regional': return RadioCategory.regional;
      case 'talk': return RadioCategory.talk;
      case 'retro': return RadioCategory.retro;
      case 'hiphop': return RadioCategory.hiphop;
      case 'urban': return RadioCategory.urban;
      case 'online': return RadioCategory.online;
      default: return RadioCategory.other;
    }
  }

  String get displayName {
    switch (this) {
      case RadioCategory.national: return 'Национални';
      case RadioCategory.news: return 'Новини';
      case RadioCategory.pop: return 'Поп';
      case RadioCategory.rock: return 'Рок';
      case RadioCategory.dance: return 'Денс';
      case RadioCategory.folk: return 'Фолк';
      case RadioCategory.folkPop: return 'Фолк Поп';
      case RadioCategory.jazz: return 'Джаз';
      case RadioCategory.classical: return 'Класическа';
      case RadioCategory.regional: return 'Регионални';
      case RadioCategory.talk: return 'Говорно';
      case RadioCategory.retro: return 'Ретро';
      case RadioCategory.hiphop: return 'Хип-Хоп';
      case RadioCategory.urban: return 'Урбан';
      case RadioCategory.online: return 'Онлайн';
      case RadioCategory.other: return 'Друго';
    }
  }

  String get emoji {
    switch (this) {
      case RadioCategory.national: return '🇧🇬';
      case RadioCategory.news: return '📰';
      case RadioCategory.pop: return '🎵';
      case RadioCategory.rock: return '🎸';
      case RadioCategory.dance: return '💃';
      case RadioCategory.folk: return '🎻';
      case RadioCategory.folkPop: return '🎶';
      case RadioCategory.jazz: return '🎷';
      case RadioCategory.classical: return '🎼';
      case RadioCategory.regional: return '📍';
      case RadioCategory.talk: return '🎙️';
      case RadioCategory.retro: return '📻';
      case RadioCategory.hiphop: return '🎤';
      case RadioCategory.urban: return '🏙️';
      case RadioCategory.online: return '🌐';
      case RadioCategory.other: return '🎵';
    }
  }
}
