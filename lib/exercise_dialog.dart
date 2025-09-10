import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fitness_posters/workout_provider.dart';
import 'package:fitness_posters/posters_config.dart';

void showExerciseDialog(
  BuildContext context,
  Exercise exercise,
  String imageUrl,
  WorkoutProvider workoutProvider,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(imageUrl, width: 400),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String terms = exercise.image.substring(
                    0,
                    exercise.image.length - 5,
                  );
                  terms = terms.replaceAll('_', '+');
                  terms =
                      "https://www.youtube.com/results?search_query=$terms+exercise+short+video";
                  final searchUrl = Uri.parse(terms);
                  if (await canLaunchUrl(searchUrl)) {
                    await launchUrl(searchUrl);
                  }
                },
                child: const Text('Video'),
              ),
              ElevatedButton(
                onPressed: () {
                  _showAddToWorkoutDialog(context, workoutProvider, exercise);
                },
                child: const Text('Add to Workout'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

void _showAddToWorkoutDialog(
  BuildContext context,
  WorkoutProvider workoutProvider,
  Exercise exercise,
) {
  showDialog(
    context: context,
    builder: (context) {
      if (workoutProvider.workouts.isEmpty) {
        return AlertDialog(
          title: const Text('No Workouts'),
          content: const Text(
              'You don\'t have any workouts yet. Create one to add exercises.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create Workout'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the current dialog
                _showCreateWorkoutDialog(context, workoutProvider, exercise);
              },
            ),
          ],
        );
      }
      return AlertDialog(
        title: const Text('Add to Workout'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: workoutProvider.workouts.length,
            itemBuilder: (context, index) {
              final workout = workoutProvider.workouts[index];
              return ListTile(
                title: Text(workout['name'] as String),
                onTap: () {
                  workoutProvider.addExerciseToWorkout(
                    workout['id'] as String,
                    exercise.image,
                    exercise.muscleGroup,
                  );
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      );
    },
  );
}

void _showCreateWorkoutDialog(BuildContext context,
    WorkoutProvider workoutProvider, Exercise exercise) {
  final nameController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('New Workout'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Workout Name',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Create & Add'),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                return;
              }
              final newWorkoutId =
                  workoutProvider.addWorkout(nameController.text.trim());
              workoutProvider.addExerciseToWorkout(
                newWorkoutId,
                exercise.image,
                exercise.muscleGroup,
              );
              Navigator.of(context).pop(); // pop create dialog
              Navigator.of(context).pop(); // pop exercise dialog
            },
          ),
        ],
      );
    },
  );
}
