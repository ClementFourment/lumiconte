import 'package:cloud_firestore/cloud_firestore.dart';

enum UserAuthProvider { google, apple, email, anonymous }

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool subscribed;
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
    this.subscribed = false,
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.authProvider,
    this.activeProfileId,
    this.lastProfileChangedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic>? data, String uid) {
    final map = data ?? {};
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      subscribed: map['subscribed'] as bool? ?? false,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authProvider: _parseAuthProvider(map['authProvider'] as String? ?? ''),
      activeProfileId: map['activeProfileId'] as String?,
      lastProfileChangedAt: (map['lastProfileChangedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'subscribed': subscribed,
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