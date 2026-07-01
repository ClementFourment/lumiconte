import 'package:flutter/material.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'profile_creation_page.dart';
import '../models/profile_model.dart';
import '../services/seed_database.dart';

class HomePage extends StatefulWidget {
  final ProfileModel profile;
  final List<CategoryModel> categories;
  final List<StoryModel> stories;

  const HomePage(
      {super.key,
      required this.profile,
      required this.categories,
      required this.stories});

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
              // ElevatedButton(
              //     onPressed: () => seedDatabase(),
              //     child: Text('Regénérer les données (debug)')),
              // // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bonjour ${widget.profile.name} !",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const CircleAvatar(
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
                    prefixIcon: const Icon(Icons.search),
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
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xffeee8ff),
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
                    const SizedBox(width: 15),
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
                    for (final story in widget.stories.take(10))
                      storyCard(story),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final category in widget.categories)
                    categoryWidget(category),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget storyCard(StoryModel story) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(story.image),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        alignment: Alignment.bottomCenter,
        child: Text(
          story.name,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget categoryWidget(CategoryModel category) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage(category.image),
          ),
          Text(category.name)
        ],
      ),
    );
  }

  TextStyle get titleStyle => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );
}
