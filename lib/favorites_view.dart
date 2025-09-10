import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_posters/workout_provider.dart';
import 'package:fitness_posters/posters_config.dart' as config;
import 'package:fitness_posters/exercise_dialog.dart';

class FavoritesView extends StatelessWidget {
  final num crossAxisCount;

  const FavoritesView({super.key, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return (workoutProvider.favorites.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount.round(),
              ),
              itemCount: workoutProvider.favorites.length,
              itemBuilder: (context, index) {
                final favoriteImage = workoutProvider.favorites[index];
                final exercise = config.exerciseCategories
                    .expand((category) => category.exercises.values)
                    .expand((exercises) => exercises)
                    .firstWhere(
                      (ex) => ex.image == favoriteImage,
                      orElse: () => config.Exercise('', '', '', ''),
                    );

                if (exercise.image.isEmpty) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        const Center(child: Text('Error: Favorite not found')),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () {
                              workoutProvider.toggleFavorite(favoriteImage);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final imageUrl = '${config.imagePath}/$favoriteImage';
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
                          top: 8,
                          left: 8,
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              exercise.muscleGroup,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () {
                              workoutProvider.toggleFavorite(exercise.image);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Heart exercises to save them here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
  }
}