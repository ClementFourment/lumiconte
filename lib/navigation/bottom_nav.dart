import 'package:lumiconte/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importations des modèles et services
import 'package:lumiconte/models/story_model.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/services/category_service.dart';
import 'package:lumiconte/services/story_service.dart';
import 'package:lumiconte/services/profile_service.dart';
import 'package:lumiconte/services/settings_service.dart';

// Importations des pages
import 'package:lumiconte/pages/home_page.dart';
import 'package:lumiconte/pages/profile_page.dart';
import 'package:lumiconte/pages/library_page.dart';

import 'package:lumiconte/constants/avatars.dart';
import 'package:lumiconte/navigation/floating_nav_bar.dart';
import 'package:lumiconte/widget/badge_celebration.dart';
import 'package:lumiconte/widget/night_sky_background.dart';
import 'package:lumiconte/widget/story_queue_widgets.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => BottomNavState();
}

class DataFuture {
  final List<CategoryModel> categories;
  final List<StoryModel> stories;

  DataFuture({
    required this.categories,
    required this.stories,
  });
}

class BottomNavState extends State<BottomNav> {
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  final ProfileService _profileService = ProfileService();
  final CategoryService _categoryService = CategoryService();
  final StoryService _storyService = StoryService();

  late final Future<DataFuture> _dataFuture;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadStaticData();
  }

  void changeTab(int index) {
    _currentIndexNotifier.value = index;
  }

  final Set<String> _settingsCheckedProfiles = {};

  /// Crée ou migre `settings/default` une fois par profil ouvert, pour que
  /// les onglets et l'espace parents trouvent toujours les paramètres.
  void _ensureSettings(String profileId) {
    if (!_settingsCheckedProfiles.add(profileId)) return;
    SettingsService().ensureDefaultSettings(_uid!, profileId).catchError((e) {
      _settingsCheckedProfiles.remove(profileId);
      debugPrint('Paramètres du profil $profileId : $e');
    });
  }

  static bool _sameProfiles(List<ProfileModel> prev, List<ProfileModel> next) {
    if (prev.length != next.length) return false;
    for (var i = 0; i < prev.length; i++) {
      final a = prev[i];
      final b = next[i];
      if (a.id != b.id ||
          a.name != b.name ||
          a.age != b.age ||
          a.avatarPath != b.avatarPath ||
          !listEquals(a.interestIds, b.interestIds)) {
        return false;
      }
    }
    return true;
  }

  Future<DataFuture> _loadStaticData() async {
    final categories = await _categoryService.getAllCategories();
    final stories = await _storyService.getAllStories();

    return DataFuture(
      categories: categories,
      stories: stories,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return Scaffold(
        body: Center(child: Text(AppLocalizations.of(context).userNotConnected)),
      );
    }

    return FutureBuilder<DataFuture>(
      future: _dataFuture,
      builder: (context, staticSnapshot) {
        if (staticSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (staticSnapshot.hasError || !staticSnapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).dataLoadingError),
            ),
          );
        }

        final categories = staticSnapshot.data!.categories;
        final stories = staticSnapshot.data!.stories;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(_uid)
              .snapshots()
              .distinct((prev, next) =>
                  prev.data()?['activeProfileId'] ==
                  next.data()?['activeProfileId']),
          builder: (context, userSnapshot) {
            final activeProfileId =
                userSnapshot.data?.data()?['activeProfileId'] as String?;

            return StreamBuilder<List<ProfileModel>>(
              // On compare aussi les champs affichés : sinon une modification
              // du nom, de l'âge ou de l'avatar n'atteint pas les onglets.
              stream: _profileService
                  .getUserProfilesStream(_uid!)
                  .distinct(_sameProfiles),
              builder: (context, profilesSnapshot) {
                if (profilesSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final profiles = profilesSnapshot.data ?? [];

                if (profiles.isEmpty) {
                  return Scaffold(
                    body: Center(
                      child: Text(AppLocalizations.of(context).noProfileFound),
                    ),
                  );
                }

                ProfileModel activeProfile;
                if (activeProfileId != null) {
                  activeProfile = profiles.firstWhere(
                    (p) => p.id == activeProfileId,
                    orElse: () => profiles.first,
                  );
                } else {
                  activeProfile = profiles.first;
                }

                _ensureSettings(activeProfile.id);

                final pages = [
                  HomePage(
                    key: ValueKey('home_${activeProfile.id}'),
                    profile: activeProfile,
                    categories: categories,
                    stories: stories,
                  ),
                  LibraryPage(
                    key: ValueKey('library_${activeProfile.id}'),
                    profile: activeProfile,
                    categories: categories,
                    stories: stories,
                  ),
                  ProfilePage(
                    key: ValueKey('profile_${activeProfile.id}'),
                    profileId: activeProfile.id,
                    stories: stories,
                  ),
                ];

                final l10n = AppLocalizations.of(context);

                return ValueListenableBuilder<int>(
                  valueListenable: _currentIndexNotifier,
                  builder: (context, currentIndex, child) {
                    return Scaffold(
                      // La barre flotte au-dessus du contenu : les pages
                      // ajoutent MediaQuery.paddingOf(context).bottom en bas
                      extendBody: true,
                      // Ciel partagé derrière les onglets (leurs Scaffold
                      // sont transparents)
                      body: BadgeWatcher(
                        key: ValueKey('badges_${activeProfile.id}'),
                        profileId: activeProfile.id,
                        stories: stories,
                        child: NightSkyBackground(
                          child: IndexedStack(
                            index: currentIndex,
                            children: pages,
                          ),
                        ),
                      ),
                      bottomNavigationBar: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StoryQueueBar(profile: activeProfile),
                          FloatingNavBar(
                            currentIndex: currentIndex,
                            onTap: (value) =>
                                _currentIndexNotifier.value = value,
                            items: [
                              FloatingNavItem(
                                icon: Icons.home_rounded,
                                label: l10n.navHome,
                              ),
                              FloatingNavItem(
                                icon: Icons.auto_stories_rounded,
                                label: l10n.navLibrary,
                              ),
                              FloatingNavItem(
                                avatar: AssetImage(
                                  activeProfile.avatarPath ??
                                      AppAvatars.defaultAvatar,
                                ),
                                label: l10n.navTreasures,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
