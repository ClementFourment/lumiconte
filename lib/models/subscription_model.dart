import 'package:cloud_firestore/cloud_firestore.dart';

/// État de l'abonnement, tel que renvoyé par le store.
enum SubscriptionStatus {
  none, // jamais abonné
  trial, // période d'essai gratuite en cours
  active, // abonnement payé en cours
  gracePeriod, // paiement refusé, accès maintenu le temps que le store réessaie
  expired, // abonnement terminé (résilié ou paiement définitivement refusé)
}

enum SubscriptionPeriod { monthly, yearly }

enum SubscriptionStore { appStore, playStore, promotional }

/// Abonnement d'un compte, stocké dans `users/{uid}.subscription`.
///
/// ⚠️ Ces données sont écrites UNIQUEMENT côté serveur (Cloud Function qui reçoit
/// les événements du store). L'app se contente de les lire : les règles Firestore
/// doivent interdire au client de modifier ce champ.
class SubscriptionModel {
  final SubscriptionStatus status;
  final String? productId; // identifiant du produit dans le store
  final SubscriptionPeriod? period;
  final SubscriptionStore? store;
  final DateTime? startedAt; // début du tout premier abonnement (ancienneté)
  final DateTime? currentPeriodStartedAt; // début de la période en cours
  final DateTime? expiresAt; // fin de l'accès premium (fin de période ou de période de grâce)
  final bool willRenew; // false si l'utilisateur a désactivé le renouvellement
  final DateTime? cancelledAt; // date à laquelle le renouvellement a été désactivé
  final DateTime? updatedAt; // dernière mise à jour par le serveur

  const SubscriptionModel({
    this.status = SubscriptionStatus.none,
    this.productId,
    this.period,
    this.store,
    this.startedAt,
    this.currentPeriodStartedAt,
    this.expiresAt,
    this.willRenew = false,
    this.cancelledAt,
    this.updatedAt,
  });

  /// L'utilisateur a-t-il accès au contenu premium en ce moment ?
  bool get isActive {
    const accessStatuses = {
      SubscriptionStatus.trial,
      SubscriptionStatus.active,
      SubscriptionStatus.gracePeriod,
    };
    return accessStatuses.contains(status) &&
        expiresAt != null &&
        expiresAt!.isAfter(DateTime.now());
  }

  bool get isTrial => isActive && status == SubscriptionStatus.trial;

  /// Temps d'accès restant (zéro si l'abonnement n'est pas actif).
  Duration get remaining =>
      isActive ? expiresAt!.difference(DateTime.now()) : Duration.zero;

  /// Ancienneté depuis le premier abonnement (null si jamais abonné).
  Duration? get subscribedFor =>
      startedAt == null ? null : DateTime.now().difference(startedAt!);

  factory SubscriptionModel.fromMap(Map<String, dynamic>? data) {
    final map = data ?? {};
    return SubscriptionModel(
      status: _parseEnum(SubscriptionStatus.values, map['status']) ??
          SubscriptionStatus.none,
      productId: map['productId'] as String?,
      period: _parseEnum(SubscriptionPeriod.values, map['period']),
      store: _parseEnum(SubscriptionStore.values, map['store']),
      startedAt: (map['startedAt'] as Timestamp?)?.toDate(),
      currentPeriodStartedAt:
          (map['currentPeriodStartedAt'] as Timestamp?)?.toDate(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      willRenew: map['willRenew'] as bool? ?? false,
      cancelledAt: (map['cancelledAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    Timestamp? ts(DateTime? d) => d != null ? Timestamp.fromDate(d) : null;
    return {
      'status': status.name,
      'productId': productId,
      'period': period?.name,
      'store': store?.name,
      'startedAt': ts(startedAt),
      'currentPeriodStartedAt': ts(currentPeriodStartedAt),
      'expiresAt': ts(expiresAt),
      'willRenew': willRenew,
      'cancelledAt': ts(cancelledAt),
      'updatedAt': ts(updatedAt),
    };
  }

  static T? _parseEnum<T extends Enum>(List<T> values, Object? raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}
