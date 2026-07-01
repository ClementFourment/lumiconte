import 'package:flutter/material.dart';
import 'profile_creation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bonjour Anna !",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      "assets/images/boy.png",
                    ),
                  )
                ],
              ),

              const SizedBox(height: 25),

              // Search
              TextField(
                decoration: InputDecoration(
                    hintText: "Rechercher une histoire...",
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    )),
              ),

              const SizedBox(height: 30),

              Text(
                "Reprendre la lecture",
                style: titleStyle,
              ),

              const SizedBox(height: 15),

              // Continue card
              Container(
                height: 160,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xffeee8ff),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        "assets/images/boy.png",
                        width: 100,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Le petit prince\net la planète oubliée",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 25),
                          LinearProgressIndicator(
                            value: 0.56,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Histoires populaires

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Histoires populaires",
                    style: titleStyle,
                  ),
                  Text(
                    "Voir tout",
                    style: TextStyle(color: Colors.deepPurple),
                  )
                ],
              ),

              SizedBox(height: 15),

              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    storyCard("assets/images/boy.png", "Le courage\n de Lila"),
                    storyCard("assets/images/boy.png", "La forêt\n lumineuse"),
                    storyCard("assets/images/boy.png", "Dragon"),
                  ],
                ),
              ),

              SizedBox(height: 30),

              Text(
                "Catégories",
                style: titleStyle,
              ),

              SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  category("🌿", "Aventure"),
                  category("🐻", "Animaux"),
                  category("😊", "Émotions"),
                  category("🌙", "Sommeil"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget storyCard(String image, String title) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget category(String icon, String text) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            icon,
          ),
          Text(text)
        ],
      ),
    );
  }

  TextStyle get titleStyle => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );
}
