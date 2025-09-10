import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String imagePath = 'assets/images';

const List<Map<String, dynamic>> exercises = [
  {
    'title': 'Yoga',
    'icon': Icons.self_improvement,
    'color': Color(0xFF8B5CF6),
    'exercises': {
      'Warm-Up': [
        {'image': 'Yoga_Cat.webp', 'video': ''},
        {'image': 'Yoga_Cow.webp', 'video': ''},
        {'image': 'Yoga_Melting_Heart.webp', 'video': ''},
        {'image': 'Yoga_Childs.webp', 'video': ''},
      ],
      'Stretching': [
        {'image': 'Yoga_Pyramid.webp', 'video': ''},
        {'image': 'Yoga_Downward_Facing_Dog.webp', 'video': ''},
        {'image': 'Yoga_Garland.webp', 'video': ''},
        {'image': 'Yoga_Seated_Forward_Bend.webp', 'video': ''},
        {'image': 'Yoga_Hero.webp', 'video': ''},
        {'image': 'Yoga_Wide_Angle_Seated_Forward_Bend.webp', 'video': ''},
      ],
      'Balance': [
        {'image': 'Yoga_Tree.webp', 'video': ''},
        {'image': 'Yoga_Lord_of_the_Dance.webp', 'video': ''},
        {'image': 'Yoga_Eagle.webp', 'video': ''},
        {'image': 'Yoga_Standing_Split.webp', 'video': ''},
        {'image': 'Yoga_Half_Moon.webp', 'video': ''},
        {'image': 'Yoga_Warrior_III.webp', 'video': ''},
        {'image': 'Yoga_Handstand.webp', 'video': ''},
        {'image': 'Yoga_Crow.webp', 'video': ''},
      ],
      'Strength': [
        {'image': 'Yoga_Warrior_I.webp', 'video': ''},
        {'image': 'Yoga_Warrior_II.webp', 'video': ''},
        {'image': 'Yoga_Upward_Plank.webp', 'video': ''},
        {'image': 'Yoga_Chair.webp', 'video': ''},
        {'image': 'Yoga_Triangle.webp', 'video': ''},
        {'image': 'Yoga_High_Lunge.webp', 'video': ''},
      ],
      'Core': [
        {'image': 'Yoga_Plank.webp', 'video': ''},
        {'image': 'Yoga_Side_Plank.webp', 'video': ''},
        {'image': 'Yoga_Boat.webp', 'video': ''},
        {'image': 'Yoga_One-Legged_Downward_Dog.webp', 'video': ''},
      ],
      'Back': [
        {'image': 'Yoga_Cobra.webp', 'video': ''},
        {'image': 'Yoga_Upward_Facing_Dog.webp', 'video': ''},
        {'image': 'Yoga_Bow.webp', 'video': ''},
        {'image': 'Yoga_Camel.webp', 'video': ''},
        {'image': 'Yoga_One-Legged_King_Pigeon.webp', 'video': ''},
        {'image': 'Yoga_Upward_Bow.webp', 'video': ''},
      ],
      'Cool Down': [
        {'image': 'Yoga_Legs_Up_the_Wall.webp', 'video': ''},
        {'image': 'Yoga_Easy.webp', 'video': ''},
        {'image': 'Yoga_Happy_Baby.webp', 'video': ''},
        {'image': 'Yoga_Reclining_Bound_Angle.webp', 'video': ''},
        {'image': 'Yoga_Reclining_Hand_to_Big_Toe.webp', 'video': ''},
        {'image': 'Yoga_Half_Pigeon.webp', 'video': ''},
        {'image': 'Yoga_Corpse.webp', 'video': ''},
      ],
    },
  },
  {
    'title': 'Barbell',
    'icon': Icons.fitness_center,
    'color': Color(0xFFEF4444),
    'exercises': {
      'Basics': [
        {'image': 'Barbell_Bench_Press.webp', 'video': ''},
        {'image': 'Barbell_Bicep_Curl.webp', 'video': ''},
        {'image': 'Barbell_Deadlift.webp', 'video': ''},
        {'image': 'Barbell_Incline_Bench_Press.webp', 'video': ''},
      ],
    },
  },
];

// Data Models
class ExerciseCategory {
  final String title;
  final IconData icon;
  final Color color;
  final Map<String, List<Exercise>> exercises;

  ExerciseCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.exercises,
  });
}

class Exercise {
  final String image;
  final String name;
  final String muscleGroup;
  final String category;

  Exercise(this.image, this.name, this.muscleGroup, this.category);
}

List<ExerciseCategory> _initExerciseCategories() {
  final categories = exercises.map((category) {
    final subcategories =
        category['exercises'] as Map<String, List<Map<String, dynamic>>>;
    final newSubcategories = subcategories.map((key, value) {
      final exerciseList = value.map((e) {
        final imageName = e['image'] as String;
        final name = imageName.replaceAll('_', ' ').replaceAll('.webp', '');
        return Exercise(imageName, name, key, category['title'].toString());
      }).toList();
      return MapEntry(key, exerciseList);
    });

    return ExerciseCategory(
      title: category['title'] as String,
      icon: category['icon'] as IconData,
      color: category['color'] as Color,
      exercises: newSubcategories,
    );
  }).toList();

  if (kDebugMode) {
    categories.add(
      ExerciseCategory(
        title: 'Testing',
        icon: Icons.bug_report,
        color: Colors.grey,
        exercises: {
          'Debugging': [
            Exercise('not_found.webp', 'Not found', 'Debugging', 'Testing'),
          ],
        },
      ),
    );
  }
  return categories;
}

final List<ExerciseCategory> exerciseCategories = _initExerciseCategories();
