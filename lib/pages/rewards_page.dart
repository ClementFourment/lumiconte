import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumiconte/main.dart';
import 'package:lumiconte/models/rewards_model.dart';


class RewardsPage extends StatelessWidget {
  final String userId;
  final String profileId;

  const RewardsPage({super.key, required this.userId, required this.profileId});

  @override
  Widget build(BuildContext context) {
    final isDark = appSettings.isDarkMode;
    const goldColor = Color(0xFFF1C40F);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Mes Récompenses', 
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E1E1E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users').doc(userId)
            .collection('profiles').doc(profileId)
            .collection('badges').snapshots(),
        builder: (context, userBadgesSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('badges').snapshots(),
            builder: (context, allBadgesSnapshot) {
              if (userBadgesSnapshot.connectionState == ConnectionState.waiting ||
                  !allBadgesSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // --- CONVERSION TYPÉE : MAPPING DE LA SOUS-COLLECTION UTILISATEUR ---
              final List<BadgeModel> userBadges = (userBadgesSnapshot.data?.docs ?? []).map((doc) {
                final data = doc.data() as Map<String, dynamic>? ?? {};
                return BadgeModel.fromMap(data, doc.id);
              }).toList();

              final Set<String> earnedBadgeIds = userBadges.map((b) => b.name.trim().toLowerCase()).toSet();

              // --- CONVERSION TYPÉE : MAPPING DE LA COLLECTION GLOBALE DE BADGES ---
              final List<BadgeModel> allBadges = (allBadgesSnapshot.data?.docs ?? []).map((doc) {
                final data = doc.data() as Map<String, dynamic>? ?? {};
                return BadgeModel.fromMap(data, doc.id);
              }).toList();

              final int totalBadges = allBadges.length;
              final int earnedCount = allBadges.where((b) => earnedBadgeIds.contains(b.id)).length;
              final double progressPercent = totalBadges > 0 ? (earnedCount / totalBadges) : 0.0;

              return Column(
                children: [
                  // --- SECTION COMPTEUR & BARRE DE PROGRESSION ---
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: !isDark ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progression des badges',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.grey.shade300 : const Color(0xFF2C3E50),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                '$earnedCount / $totalBadges',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 12,
                            backgroundColor: isDark ? Colors.grey.shade800 : const Color(0xFFF7F2FA),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- LISTE DES BADGES ---
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        crossAxisSpacing: 18, 
                        mainAxisSpacing: 18, 
                        childAspectRatio: 1.05,
                      ),
                      itemCount: totalBadges,
                      itemBuilder: (context, index) {
                        final BadgeModel badge = allBadges[index];
                        final bool isEarned = earnedBadgeIds.contains(badge.id);

                        return _buildBadgeCard(badge, isDark, goldColor, isEarned);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBadgeCard(BadgeModel badge, bool isDark, Color gold, bool isEarned) {
    final cardBgLight = isEarned ? Colors.white : const Color(0xFFF7F2FA);
    final cardBgDark = isEarned ? const Color(0xFF1E1E1E) : const Color(0xFF252525);

    return Opacity(
      opacity: isEarned ? 1.0 : 0.45, 
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? cardBgDark : cardBgLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isEarned && !isDark ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
          border: isEarned 
              ? Border.all(color: gold.withOpacity(0.5), width: 1.5) 
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEarned ? gold.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded, 
                size: 38, 
                color: isEarned ? gold : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                badge.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark 
                      ? (isEarned ? Colors.white : Colors.grey.shade500)
                      : (isEarned ? const Color(0xFF2C3E50) : Colors.grey.shade600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}