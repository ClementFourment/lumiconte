import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

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
  final Timestamp? lastProfileChangedAt;

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

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      subscribed: data['subscribed'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      authProvider: _parseAuthProvider(data['authProvider'] ?? 'unknown'),
      activeProfileId: data['activeProfileId'],
      lastProfileChangedAt: data['lastProfileChangedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'subscribed': subscribed,
      'notificationsEnabled':
          notificationsEnabled, // 👈 Sauvegardé dans Firestore
      'createdAt': createdAt,
      'authProvider': authProvider.toString().split('.').last,
      'activeProfileId': activeProfileId,
      'lastProfileChangedAt': lastProfileChangedAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? subscribed,
    bool? notificationsEnabled,
    DateTime? createdAt,
    UserAuthProvider? authProvider,
    String? activeProfileId,
    Timestamp? lastProfileChangedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      subscribed: subscribed ?? this.subscribed,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      authProvider: authProvider ?? this.authProvider,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      lastProfileChangedAt: lastProfileChangedAt ?? this.lastProfileChangedAt,
    );
  }

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, notificationsEnabled: $notificationsEnabled, authProvider: $authProvider)';
  }

  static UserAuthProvider _parseAuthProvider(String provider) {
    switch (provider) {
      case 'google':
        return UserAuthProvider.google;
      case 'apple':
        return UserAuthProvider.apple;
      case 'email':
        return UserAuthProvider.email;
      case 'anonymous':
        return UserAuthProvider.anonymous;
      default:
        return UserAuthProvider.google;
    }
  }
}

enum UserAuthProvider {
  google,
  apple,
  email,
  anonymous,
}
