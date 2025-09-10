import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_posters/workout_provider.dart';
import 'package:fitness_posters/posters_config.dart';
import 'package:fitness_posters/exercise_dialog.dart';

class ExerciseCategoryView extends StatelessWidget {
  final ExerciseCategory exerciseCategory;
  final num crossAxisCount;

  const ExerciseCategoryView({
    super.key,
    required this.exerciseCategory,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final subcategories = exerciseCategory.exercises;

    return ListView.builder(
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcategoryName = subcategories.keys.elementAt(index);
        final exercises = subcategories[subcategoryName]!;
        final categoryColor = exerciseCategory.color;

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      subcategoryName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount.round(),
                ),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final imageUrl = '$imagePath/${exercise.image}';
                  final isFavorite = workoutProvider.favorites.contains(
                    exercise.image,
                  );
                  return InkWell(
                    onTap: () {
                      showExerciseDialog(
                        context,
                        exercise,
                        imageUrl,
                        workoutProvider,
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(imageUrl, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                workoutProvider.toggleFavorite(
                                  exercise.image,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}