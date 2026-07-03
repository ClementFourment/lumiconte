import 'package:flutter/material.dart';
import 'package:lumiconte/models/category_model.dart';
import 'package:lumiconte/models/story_model.dart';
import 'profile_creation_page.dart';
import 'package:lumiconte/models/profile_model.dart';
import 'package:lumiconte/services/seed_database.dart';
import 'package:lumiconte/widget/b2_image.dart';
import 'package:go_router/go_router.dart';

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
                      // storyCard(story)
                      GestureDetector(
                        onTap: () => context.push('/story', extra: story),
                        child: storyCard(story),
                      )
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
      height: 180,
      margin: const EdgeInsets.only(right: 15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade200,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          B2Image(objectKey: story.image, fit: BoxFit.cover),
          // Dégradé + titre par-dessus l'image
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: Text(
              story.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
          ClipOval(
            child: B2Image(
              objectKey: category.image,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
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
