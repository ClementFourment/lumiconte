import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumiconte/models/subscription_model.dart';

enum UserAuthProvider { google, apple, email, anonymous }

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final SubscriptionModel subscription;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final UserAuthProvider authProvider;
  final String? activeProfileId;
  final DateTime? lastProfileChangedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.subscription = const SubscriptionModel(),
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.authProvider,
    this.activeProfileId,
    this.lastProfileChangedAt,
  });

  /// Accès premium en cours (essai, abonnement payé ou période de grâce).
  bool get isSubscribed => subscription.isActive;

  factory UserModel.fromMap(Map<String, dynamic>? data, String uid) {
    final map = data ?? {};
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      subscription: SubscriptionModel.fromMap(map['subscription'] is Map
          ? Map<String, dynamic>.from(map['subscription'] as Map)
          : null),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authProvider: _parseAuthProvider(map['authProvider'] as String? ?? ''),
      activeProfileId: map['activeProfileId'] as String?,
      lastProfileChangedAt: (map['lastProfileChangedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// `subscription` n'est volontairement PAS écrit : seul le serveur le modifie.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'authProvider': authProvider.name, // Modern Dart syntax
      'activeProfileId': activeProfileId,
      'lastProfileChangedAt': lastProfileChangedAt != null
          ? Timestamp.fromDate(lastProfileChangedAt!)
          : null,
    };
  }

  static UserAuthProvider _parseAuthProvider(String provider) {
    return UserAuthProvider.values.firstWhere(
      (e) => e.name == provider,
      orElse: () => UserAuthProvider.email,
    );
  }
}
