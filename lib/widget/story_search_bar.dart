import 'package:flutter/material.dart';
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/services/story_service.dart';
import 'package:lumiconte/widget/b2_image.dart';

class StorySearchBar extends StatefulWidget {
  const StorySearchBar({
    super.key,
    required this.onStorySelected,
    this.hintText = "Rechercher une histoire...",
    this.maxResults = 8,
  });

  final ValueChanged<StoryModel> onStorySelected;
  final String hintText;
  final int maxResults;

  @override
  State<StorySearchBar> createState() => _StorySearchBarState();
}

class _StorySearchBarState extends State<StorySearchBar>
    with SingleTickerProviderStateMixin {
  final StoryService _storyService = StoryService();
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animationController;
  OverlayEntry? _overlayEntry;

  List<StoryModel> _stories = [];
  List<StoryModel> _results = [];
  bool _loading = true;
  String _lastSearch = '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadStories();
    _controller.addListener(_onTextChanged);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
        _animationController.forward();
      } else {
        debugPrint('FOCUUS');

        _hideOverlay();
        _animationController.reverse();
      }
    });
  }

  Future<void> _loadStories() async {
    try {
      final stories = await _storyService.getAllStories();
      if (mounted) {
        setState(() {
          _stories = stories;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des histoires: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onTextChanged() {
    setState(() {
      final search = _controller.text.trim().toLowerCase();
      _lastSearch = search;

      if (search.isEmpty) {
        _results = [];
        _overlayEntry?.markNeedsBuild();
        return;
      }

      _results = _stories.where((story) {
        return story.name.toLowerCase().contains(search) ||
            story.categoryIds.any(
              (category) => category.toLowerCase().contains(search),
            );
      }).toList();

      // Tri intelligent : priorité aux correspondances au début du nom
      _results.sort((a, b) {
        final aStarts = a.name.toLowerCase().startsWith(search);
        final bStarts = b.name.toLowerCase().startsWith(search);

        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;

        // Ensuite, trier par longueur du nom (plus court d'abord)
        return a.name.length.compareTo(b.name.length);
      });

      // Limiter les résultats
      if (_results.length > widget.maxResults) {
        _results = _results.sublist(0, widget.maxResults);
      }

      if (_focusNode.hasFocus) {
        _showOverlay();
      }

      _overlayEntry?.markNeedsBuild();
    });
  }

  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectStory(StoryModel story) {
    _controller.text = story.name;
    _controller.selection = TextSelection.collapsed(
      offset: story.name.length,
    );

    _hideOverlay();
    _focusNode.unfocus();

    widget.onStorySelected(story);
  }

  void _clearSearch() {
    debugPrint('CLEAAAAAAAR');
    _controller.clear();
    setState(() {
      _results = [];
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withValues(
                alpha: 0.1,
              ),
              blurRadius: 16,
              offset: const Offset(0, 0),
              blurStyle: BlurStyle.normal,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_animationController.value * 0.02),
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: (_) {
                  if (_results.isNotEmpty) {
                    _selectStory(_results.first);
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: _loading
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.primary,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Icon(
                            Icons.search_rounded,
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                  // plus de suffixIcon ici
                  filled: true,
                  fillColor: colors.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 16,
                    right: 56, // laisse la place au bouton X
                    top: 12,
                    bottom: 12,
                  ),
                ),
              ),

              // bouton X externe
              if (_controller.text.isNotEmpty)
                Positioned(
                  right: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _clearSearch();
                    },
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.7,
                            end: 1.0,
                          ).animate(_animationController),
                          child: Icon(
                            Icons.close_rounded,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;

        if (_results.isEmpty) {
          return Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(),
                ),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 8),
                child: Material(
                  color: Colors.transparent,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    alignment: Alignment.topCenter,
                    child: FadeTransition(
                      opacity: _animationController,
                      child: null,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Container(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 8),
              child: Material(
                color: Colors.transparent,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  alignment: Alignment.topCenter,
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Container(
                      width: size.width,
                      constraints: const BoxConstraints(
                        maxHeight: 450,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0),
                            blurRadius: 32,
                            offset: const Offset(0, 0),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color:
                                const Color.fromARGB(255, 0, 0, 0).withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 0),
                            blurStyle: BlurStyle.normal,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final story = _results[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: _StoryResultTile(
                              story: story,
                              colors: colors,
                              onTap: () => _selectStory(story),
                              animationController: _animationController,
                              index: index,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StoryResultTile extends StatefulWidget {
  final StoryModel story;
  final ColorScheme colors;
  final VoidCallback onTap;
  final AnimationController animationController;
  final int index;

  const _StoryResultTile({
    required this.story,
    required this.colors,
    required this.onTap,
    required this.animationController,
    required this.index,
  });

  @override
  State<_StoryResultTile> createState() => _StoryResultTileState();
}

class _StoryResultTileState extends State<_StoryResultTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: widget.animationController,
          curve: Interval(
            (widget.index * 0.08).clamp(0.0, 1.0),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (isHovering) {
          if (isHovering) {
            _hoverController.forward();
          } else {
            _hoverController.reverse();
          }
        },
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: Color.lerp(
                  widget.colors.surfaceContainerLow,
                  widget.colors.primary.withValues(alpha: 0.1),
                  _hoverController.value,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Color.lerp(
                    widget.colors.outlineVariant.withValues(alpha: 0.1),
                    widget.colors.primary.withValues(alpha: 0.3),
                    _hoverController.value,
                  )!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.08 + (_hoverController.value * 0.04),
                    ),
                    blurRadius: 16 + (_hoverController.value * 8),
                    offset: Offset(0, 4 + (_hoverController.value * 2)),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Image avec Hero animation
                  Hero(
                    tag: "story-search-${widget.story.id}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: B2Image(
                        objectKey: widget.story.image,
                        width: 56,
                        height: 78,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 56,
                          height: 78,
                          decoration: BoxDecoration(
                            color: widget.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: widget.colors.onSurfaceVariant,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Contenu texte
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.story.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: widget.colors.onSurface,
                          ),
                        ),
                        if (widget.story.categoryIds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: widget.story.categoryIds
                                  .take(2)
                                  .map(
                                    (category) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            widget.colors.primary
                                                .withValues(alpha: 0.12),
                                            widget.colors.secondary
                                                .withValues(alpha: 0.12),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: widget.colors.primary
                                              .withValues(alpha: 0.15),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: widget.colors.primary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icône flèche
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0)
                        .animate(_hoverController),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: widget.colors.primary.withValues(
                        alpha: 0.5 + _hoverController.value * 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
