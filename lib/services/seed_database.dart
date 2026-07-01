// Script de seed à lancer UNE FOIS manuellement (pas dans main.dart),
// par ex. depuis un bouton de debug ou un test, le temps de foutre des données dans Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/interest_model.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../services/settings_service.dart';

Future<void> seedDatabase() async {
  final firestore = FirebaseFirestore.instance;
  print("Initialisation complète de la base de données...");

  // 1. Catégorie ("categories", camelCase, via CategoryModel.toMap)
  final category = CategoryModel(
    id: '',
    name: 'Aventure',
    image: 'assets/images/boy.png',
    description: 'Histoires d\'aventure',
    ageGroup: '6-8',
  );
  final categoryRef =
      await firestore.collection('categories').add(category.toMap());

  // 2. Intérêt ("interests")
  final interest = InterestModel(
    id: '',
    name: 'Espace',
    image: 'lien_icone_espace',
  );
  final interestRef =
      await firestore.collection('interests').add(interest.toMap());

  // 3. Story ("stories"), uniquement les champs que StoryModel connaît
  final story = StoryModel(
    id: '',
    name: 'Mission Lune',
    image: 'lien_image_story',
    categoryIds: [categoryRef.id],
    type: 'original',
    createdAt: DateTime.now(),
  );
  final storyRef = await firestore.collection('stories').add(story.toMap());

  // 4. User ("users/{uid}") — ici un faux uid de test
  final user = UserModel(
    uid: 'test_user_id',
    email: 'leo.parent@example.com',
    subscribed: true,
    createdAt: DateTime.now(),
    authProvider: UserAuthProvider.email,
  );
  await firestore.collection('users').doc(user.uid).set(user.toMap());

  // 5. Profil ("users/{uid}/profiles/{id}") via ProfileService
  final profileService = ProfileService();
  final profileId = await profileService.createProfile(
    user.uid,
    name: 'Léo',
    age: 8,
    interestIds: [interestRef.id],
  );

  // 6. Settings du profil, via SettingsService (id auto-généré, pas 'current' en dur)
  final settingsService = SettingsService();
  await settingsService.createSettings(
    user.uid,
    profileId,
    fontSize: 18,
    theme: 'dark',
    dyslexia: true,
    voice: 'fr-FR-A',
    autoReader: false,
  );

  // 7. Progression de lecture ("users/{uid}/profiles/{id}/readingProgress")
  await firestore
      .collection('users')
      .doc(user.uid)
      .collection('profiles')
      .doc(profileId)
      .collection('readingProgress')
      .add({
    'storyId': storyRef.id,
    'progress': 75,
    'lastRead': FieldValue.serverTimestamp(),
  });

  print('Seed: terminé, toutes les données respectent les models existants.');
}
