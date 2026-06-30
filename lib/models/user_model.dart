class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool subscribed;
  final DateTime createdAt;
  final UserAuthProvider authProvider;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.subscribed = false,
    required this.createdAt,
    required this.authProvider,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      subscribed: data['subscribed'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      authProvider: _parseAuthProvider(data['authProvider'] ?? 'google'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'subscribed': subscribed,
      'createdAt': createdAt,
      'authProvider': authProvider.toString().split('.').last,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? subscribed,
    DateTime? createdAt,
    UserAuthProvider? authProvider,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      subscribed: subscribed ?? this.subscribed,
      createdAt: createdAt ?? this.createdAt,
      authProvider: authProvider ?? this.authProvider,
    );
  }

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, authProvider: $authProvider)';
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
