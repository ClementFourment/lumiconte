import 'package:flutter/foundation.dart';
import 'package:lumiconte/models/story_model.dart';

/// File de lecture : quelques histoires audio écoutées à la suite, juste pour
/// cette fois. Rien n'est enregistré : la file disparaît à la fin de la
/// dernière histoire, quand on quitte la lecture ou quand l'app est fermée.
class StoryQueue extends ChangeNotifier {
  static const int maxLength = 5;

  static final StoryQueue _instance = StoryQueue._internal();

  factory StoryQueue() => _instance;

  StoryQueue._internal();

  /// File indépendante du singleton, pour les tests.
  @visibleForTesting
  StoryQueue.forTesting();

  final List<StoryModel> _stories = [];

  /// Position de l'histoire en cours d'écoute, null tant que la file n'est pas lancée.
  int? _currentIndex;

  List<StoryModel> get stories => List.unmodifiable(_stories);
  bool get isEmpty => _stories.isEmpty;
  bool get isFull => _stories.length >= maxLength;
  bool get isPlaying => _currentIndex != null;
  StoryModel? get current =>
      _currentIndex == null ? null : _stories[_currentIndex!];
  int? get currentIndex => _currentIndex;
  bool get hasPrevious => _currentIndex != null && _currentIndex! > 0;
  bool get hasNext =>
      _currentIndex != null && _currentIndex! < _stories.length - 1;

  /// Langue du profil, suivie par StoryQueuePlayer.followLanguage.
  String _language = 'fr';

  String get language => _language;

  /// Les histoires en attente sans voix dans la nouvelle langue ne seraient
  /// pas lues : elles sont retirées. L'histoire en cours d'écoute reste.
  set language(String value) {
    if (value == _language) return;
    _language = value;
    final current = this.current;
    _stories.removeWhere((s) => !identical(s, current) && !canQueue(s));
    if (current != null) _currentIndex = _stories.indexOf(current);
    notifyListeners();
  }

  /// Seules les histoires audio s'enchaînent toutes seules. Même règle que la
  /// lecture : il faut une voix lisible dans la langue du profil.
  bool canQueue(StoryModel story) => story.voiceFor(_language, null) != null;

  /// Position (à partir de 0) de l'histoire dans la file, -1 si elle n'y est pas.
  int indexOf(String storyId) => _stories.indexWhere((s) => s.id == storyId);

  bool contains(String storyId) => indexOf(storyId) >= 0;

  /// Ajoute l'histoire en fin de file. Refusé si la file est pleine, si
  /// l'histoire y est déjà ou si elle n'a pas d'audio.
  bool add(StoryModel story) {
    if (isFull || contains(story.id) || !canQueue(story)) return false;
    _stories.add(story);
    notifyListeners();
    return true;
  }

  void remove(String storyId) {
    final index = indexOf(storyId);
    // L'histoire en cours d'écoute se retire en arrêtant la file
    if (index < 0 || index == _currentIndex) return;
    _stories.removeAt(index);
    final current = _currentIndex;
    if (current != null && index < current) _currentIndex = current - 1;
    if (_stories.isEmpty) _currentIndex = null;
    notifyListeners();
  }

  void clear() {
    if (_stories.isEmpty && _currentIndex == null) return;
    _stories.clear();
    _currentIndex = null;
    notifyListeners();
  }

  /// Lance tout de suite [story]. Pendant une écoute, elle remplace la file ;
  /// sinon elle passe devant les histoires en attente.
  void playNow(StoryModel story) {
    if (isPlaying) {
      _stories.clear();
    } else {
      _stories.removeWhere((s) => s.id == story.id);
    }
    _stories.insert(0, story);
    if (_stories.length > maxLength) _stories.removeLast();
    _currentIndex = 0;
    notifyListeners();
  }

  /// Lance la file et renvoie la première histoire.
  StoryModel? start() {
    if (_stories.isEmpty) return null;
    _currentIndex = 0;
    notifyListeners();
    return _stories.first;
  }

  /// Revient à l'histoire précédente, null s'il n'y en a pas.
  StoryModel? previous() {
    if (!hasPrevious) return null;
    _currentIndex = _currentIndex! - 1;
    notifyListeners();
    return _stories[_currentIndex!];
  }

  /// Passe à l'histoire suivante. Après la dernière, la file est vidée et
  /// null est renvoyé.
  StoryModel? next() {
    if (!hasNext) {
      clear();
      return null;
    }
    _currentIndex = _currentIndex! + 1;
    notifyListeners();
    return _stories[_currentIndex!];
  }
}
