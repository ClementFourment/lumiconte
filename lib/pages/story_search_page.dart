import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/reading_progress_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/pages/story/story_page.dart';
import 'package:lumiconte/services/reading_progress_service.dart';
import 'package:lumiconte/theme/app_theme.dart';
import 'package:lumiconte/utils/story_search.dart';
import 'package:lumiconte/widget/mascot.dart';
import 'package:lumiconte/widget/night_sky_background.dart';
import 'package:lumiconte/widget/story_cover_card.dart';
import 'package:lumiconte/widget/story_queue_widgets.dart';

/// Ouvre l'écran de recherche en fondu.
void openStorySearch(
  BuildContext context, {
  required ProfileModel profile,
  required List<StoryModel> stories,
  required List<CategoryModel> categories,
  List<ReadingProgressModel> readingProgress = const [],
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => StorySearchPage(
        profile: profile,
        stories: stories,
        categories: categories,
        initialReadingProgress: readingProgress,
      ),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

/// Faux champ de recherche affiché sur l'accueil : il ouvre [StorySearchPage].
class StorySearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const StorySearchButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: AppTheme.getCardColor(context),
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppTheme.accentColor),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).searchHint,
                style: TextStyle(
                  fontSize: 16,
                  color: onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StorySearchPage extends StatefulWidget {
  final ProfileModel profile;
  final List<StoryModel> stories;
  final List<CategoryModel> categories;
  final List<ReadingProgressModel> initialReadingProgress;

  const StorySearchPage({
    super.key,
    required this.profile,
    required this.stories,
    required this.categories,
    this.initialReadingProgress = const [],
  });

  @override
  State<StorySearchPage> createState() => _StorySearchPageState();
}

class _StorySearchPageState extends State<StorySearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late final Stream<List<ReadingProgressModel>> _progressStream =
      ReadingProgressService().getUserReadingProgress(widget.profile.id);

  late final Map<String, String> _categoryNames = {
    for (final category in widget.categories) category.id: category.displayName,
  };

  /// Thèmes proposés : seulement ceux qui contiennent au moins une histoire.
  late final List<CategoryModel> _suggestedCategories = widget.categories
      .where((c) => widget.stories.any((s) => s.categoryIds.contains(c.id)))
      .toList();

  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<StoryModel> _search(String query) {
    final scored = <(StoryModel, int)>[];
    for (final story in widget.stories) {
      // On cherche dans les noms de catégories, pas dans leurs identifiants
      final categories =
          story.categoryIds.map((id) => _categoryNames[id] ?? id).toList();
      final score = storySearchScore(query, story.displayName, categories);
      if (score != null) scored.add((story, score));
    }

    // Plus pertinent d'abord, puis titre le plus court
    scored.sort((a, b) {
      final byScore = b.$2.compareTo(a.$2);
      if (byScore != 0) return byScore;
      return a.$1.displayName.length.compareTo(b.$1.displayName.length);
    });
    return scored.map((e) => e.$1).toList();
  }

  /// Suggestions : d'abord les histoires adaptées à l'âge, complétées par les
  /// autres pour ne pas afficher une grille presque vide.
  List<StoryModel> get _suggestedStories {
    final age = widget.profile.age;
    bool fitsAge(StoryModel s) =>
        age >= (s.age_min ?? 0) && age <= (s.age_max ?? 99);

    return [
      ...widget.stories.where(fitsAge),
      ...widget.stories.where((s) => !fitsAge(s)),
    ].take(12).toList();
  }

  Future<void> _openStory(StoryModel story) async {
    _searchFocus.unfocus();
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) =>
            StoryPage(story: story, profile: widget.profile),
        transitionsBuilder: (_, animation, __, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    // Au retour, Flutter redonne le focus au champ : on garde le clavier fermé
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: SafeArea(
          top: false,
          child: StoryQueueBar(profile: widget.profile),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchField(context),
              Expanded(
                child: StreamBuilder<List<ReadingProgressModel>>(
                  stream: _progressStream,
                  initialData: widget.initialReadingProgress,
                  builder: (context, snapshot) {
                    final progressByStory = {
                      for (final p in snapshot.data ?? <ReadingProgressModel>[])
                        p.storyId: p.progress,
                    };
                    return _buildBody(context, progressByStory);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context).back,
            icon: const Icon(Icons.arrow_back_rounded),
            color: onSurface,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _searchFocus,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 17, color: onSurface),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchFieldHint,
                hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.5)),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.accentColor,
                ),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: AppLocalizations.of(context).clear,
                        icon: const Icon(Icons.close_rounded),
                        color: onSurface.withValues(alpha: 0.7),
                        onPressed: _controller.clear,
                      ),
                filled: true,
                fillColor: AppTheme.getCardColor(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: AppTheme.accentColor.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, Map<String, double> progressByStory) {
    final query = _controller.text.trim();

    // 1. Recherche en cours
    if (query.isNotEmpty) {
      final results = _search(query);
      if (results.isEmpty) {
        return _buildScrollView([
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Mascot(
                message: AppLocalizations.of(context).searchNotFound,
              ),
            ),
          ),
          _sectionTitle(context, AppLocalizations.of(context).youMightLike),
          _buildGrid(_suggestedStories.take(6).toList(), progressByStory),
        ]);
      }
      return _buildScrollView([
        _sectionTitle(
          context,
          AppLocalizations.of(context).searchResultsCount(results.length),
        ),
        _buildGrid(results, progressByStory),
      ]);
    }

    // 2. Pas encore de recherche : idées par thème
    final selected = _selectedCategoryId;
    final shownStories = selected == null
        ? _suggestedStories
        : widget.stories
            .where((s) => s.categoryIds.contains(selected))
            .toList();

    return _buildScrollView([
      _sectionTitle(context, AppLocalizations.of(context).anyIdeas),
      SliverToBoxAdapter(child: _buildCategoryChips(context)),
      _sectionTitle(
        context,
        selected == null
            ? AppLocalizations.of(context).forYou
            : _categoryNames[selected] ?? AppLocalizations.of(context).stories,
      ),
      _buildGrid(shownStories, progressByStory),
    ]);
  }

  Widget _buildScrollView(List<Widget> slivers) {
    return CustomScrollView(
      // Faire défiler ferme le clavier pour voir tous les résultats
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Une seule ligne qui défile : les thèmes ne doivent pas repousser les
    // histoires sous le clavier
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _suggestedCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _suggestedCategories[index];
          final isSelected = category.id == _selectedCategoryId;
          return ChoiceChip(
            label: Text(category.displayName),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => setState(() {
              _selectedCategoryId = isSelected ? null : category.id;
            }),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : onSurface,
            ),
            backgroundColor: AppTheme.getCardColor(context),
            selectedColor: AppTheme.accentColor,
            side: BorderSide.none,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          );
        },
      ),
    );
  }

  Widget _buildGrid(
    List<StoryModel> stories,
    Map<String, double> progressByStory,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.66,
        ),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return StoryCoverCard(
            story: story,
            progress: progressByStory[story.id] ?? 0,
            onTap: () => _openStory(story),
          );
        },
      ),
    );
  }
}
