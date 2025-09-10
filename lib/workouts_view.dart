import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_posters/workout_provider.dart';
import 'package:fitness_posters/posters_config.dart' as config;
import 'package:url_launcher/url_launcher.dart';

class WorkoutsView extends StatefulWidget {
  final num crossAxisCount;
  const WorkoutsView({super.key, required this.crossAxisCount});

  @override
  State<WorkoutsView> createState() => _WorkoutsViewState();
}

class _WorkoutsViewState extends State<WorkoutsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          if (workoutProvider.workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No workouts created',
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
                    'Create your first custom workout',
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: workoutProvider.workouts.length,
              itemBuilder: (context, index) {
                final workout = workoutProvider.workouts[index];
                return WorkoutItem(
                  key: ValueKey(workout['id']),
                  workout: workout,
                  crossAxisCount: widget.crossAxisCount,
                  scrollController: _scrollController,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateWorkoutDialog(
            context,
            Provider.of<WorkoutProvider>(context, listen: false),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateWorkoutDialog(
    BuildContext context,
    WorkoutProvider workoutProvider,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Workout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Workout Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  workoutProvider.addWorkout(controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class WorkoutItem extends StatefulWidget {
  final Map<String, dynamic> workout;
  final num crossAxisCount;
  final ScrollController scrollController;

  const WorkoutItem({
    super.key,
    required this.workout,
    required this.crossAxisCount,
    required this.scrollController,
  });

  @override
  State<WorkoutItem> createState() => _WorkoutItemState();
}

class _WorkoutItemState extends State<WorkoutItem> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late List<Map<String, dynamic>> _exercises;
  int? _draggingIndex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.workout['name'] as String,
    );
    _exercises = List<Map<String, dynamic>>.from(
      widget.workout['exercises'] as List,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        _nameController.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    final updatedWorkout = {
                      'id': widget.workout['id'],
                      'name': _nameController.text,
                      'exercises': _exercises,
                    };
                    workoutProvider.updateWorkout(updatedWorkout);
                  }
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Workout'),
                        content: Text(
                          'Are you sure you want to delete "${widget.workout['name']}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      workoutProvider.deleteWorkout(
                        widget.workout['id'] as String,
                      );
                    }
                  },
                ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount.round(),
            childAspectRatio: 8 / 9,
          ),
          itemCount: _exercises.length,
          itemBuilder: (context, index) {
            final exerciseData = _exercises[index];
            final exerciseImage = exerciseData['image'];
            final weight = exerciseData['weight'] ?? '0';
            final reps = exerciseData['reps'] ?? '0';
            final sets = exerciseData['sets'] ?? '0';

            final exercise = config.exerciseCategories
                .expand((category) => category.exercises.values)
                .expand((exercises) => exercises)
                .firstWhere(
                  (ex) => ex.image == exerciseImage,
                  orElse: () => config.Exercise('', '', '', ''),
                );

            final isDragging = _draggingIndex == index;

            if (exercise.image.isEmpty) {
              final errorCard = const Card(
                child: Center(child: Text('Exercise not found')),
              );
              if (_isEditing) {
                return Opacity(
                  opacity: isDragging ? 0.0 : 1.0,
                  child: Stack(
                    children: [
                      errorCard,
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Draggable<Map<String, dynamic>>(
                          data: exerciseData,
                          onDragStarted: () {
                            setState(() {
                              _draggingIndex = index;
                            });
                          },
                          onDragEnd: (details) {
                            setState(() {
                              _draggingIndex = null;
                            });
                          },
                          onDraggableCanceled: (velocity, offset) {
                            setState(() {
                              _draggingIndex = null;
                            });
                          },
                          onDragUpdate: (details) {
                            final screenHeight = MediaQuery.of(
                              context,
                            ).size.height;
                            final dy = details.globalPosition.dy;
                            const scrollThreshold = 100.0;
                            const scrollSpeed = 10.0;

                            if (dy < scrollThreshold) {
                              widget.scrollController.jumpTo(
                                widget.scrollController.offset - scrollSpeed,
                              );
                            } else if (dy > screenHeight - scrollThreshold) {
                              widget.scrollController.jumpTo(
                                widget.scrollController.offset + scrollSpeed,
                              );
                            }
                          },
                          feedback: SizedBox(
                            width: 100,
                            height: 100,
                            child: errorCard,
                          ),
                          child: const Icon(
                            Icons.drag_handle,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return errorCard;
            }

            final imageUrl = '${config.imagePath}/${exercise.image}';
            final isFavorite = workoutProvider.favorites.contains(
              exercise.image,
            );

            final exerciseCard = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
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
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              workoutProvider.toggleFavorite(exercise.image);
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Weight: $weight  Reps: $reps   Sets: $sets',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );

            if (_isEditing) {
              return Opacity(
                opacity: isDragging ? 0.0 : 1.0,
                child: DragTarget<Map<String, dynamic>>(
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    return Stack(
                      children: [
                        exerciseCard,
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isHovering ? 4 : 0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Draggable<Map<String, dynamic>>(
                            data: exerciseData,
                            onDragStarted: () {
                              setState(() {
                                _draggingIndex = index;
                              });
                            },
                            onDragEnd: (details) {
                              setState(() {
                                _draggingIndex = null;
                              });
                            },
                            onDraggableCanceled: (velocity, offset) {
                              setState(() {
                                _draggingIndex = null;
                              });
                            },
                            onDragUpdate: (details) {
                              final screenHeight = MediaQuery.of(
                                context,
                              ).size.height;
                              final dy = details.globalPosition.dy;
                              const scrollThreshold = 100.0;
                              const scrollSpeed = 10.0;

                              if (dy < scrollThreshold) {
                                widget.scrollController.jumpTo(
                                  widget.scrollController.offset - scrollSpeed,
                                );
                              } else if (dy > screenHeight - scrollThreshold) {
                                widget.scrollController.jumpTo(
                                  widget.scrollController.offset + scrollSpeed,
                                );
                              }
                            },
                            feedback: SizedBox(
                              width: 150,
                              height: 150,
                              child: exerciseCard,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.drag_handle,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  onWillAcceptWithDetails: (details) =>
                      details.data != exerciseData,
                  onAcceptWithDetails: (details) {
                    final data = details.data;
                    setState(() {
                      final oldIndex = _exercises.indexOf(data);
                      final newIndex = index;
                      if (oldIndex != -1) {
                        _exercises.removeAt(oldIndex);
                        _exercises.insert(
                          newIndex > oldIndex ? newIndex - 1 : newIndex,
                          data,
                        );
                      }
                    });
                  },
                ),
              );
            }
            return InkWell(
              onTap: () {
                _showEditExerciseDialog(
                  context,
                  workoutProvider,
                  widget.workout['id'] as String,
                  exerciseData,
                  exercise,
                  index,
                );
              },
              child: exerciseCard,
            );
          },
        ),
        if (_isEditing)
          DragTarget<Map<String, dynamic>>(
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return Container(
                height: 100,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: isHovering
                      ? Colors.red.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isHovering ? Colors.red : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: isHovering ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Drag here to delete',
                        style: TextStyle(
                          color: isHovering ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            onAcceptWithDetails: (details) {
              setState(() {
                _exercises.remove(details.data);
              });
            },
          ),
      ],
    );
  }

  void _showEditExerciseDialog(
    BuildContext context,
    WorkoutProvider workoutProvider,
    String workoutId,
    Map<String, dynamic> exerciseData,
    config.Exercise exercise,
    int exerciseIndex,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return EditExerciseDialog(
          workoutProvider: workoutProvider,
          workoutId: workoutId,
          exerciseData: exerciseData,
          exercise: exercise,
          exerciseIndex: exerciseIndex,
          onExerciseDeleted: (deletedExerciseData) {
            setState(() {
              _exercises.remove(deletedExerciseData);
            });
          },
        );
      },
    );
  }
}

class EditExerciseDialog extends StatefulWidget {
  final WorkoutProvider workoutProvider;
  final String workoutId;
  final Map<String, dynamic> exerciseData;
  final config.Exercise exercise;
  final int exerciseIndex;
  final Function(Map<String, dynamic>) onExerciseDeleted;

  const EditExerciseDialog({
    super.key,
    required this.workoutProvider,
    required this.workoutId,
    required this.exerciseData,
    required this.exercise,
    required this.exerciseIndex,
    required this.onExerciseDeleted,
  });

  @override
  State<EditExerciseDialog> createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<EditExerciseDialog> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _setsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.exerciseData['weight']?.toString() ?? '0',
    );
    _repsController = TextEditingController(
      text: widget.exerciseData['reps']?.toString() ?? '0',
    );
    _setsController = TextEditingController(
      text: widget.exerciseData['sets']?.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = '${config.imagePath}/${widget.exercise.image}';
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              widget.exercise.muscleGroup,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text(
                    'Are you sure you want to delete this exercise?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                if (!context.mounted) return;
                widget.workoutProvider.removeExerciseFromWorkout(
                  widget.workoutId,
                  widget.exerciseIndex,
                );
                widget.onExerciseDeleted(widget.exerciseData);
                Navigator.of(context).pop(); // Close the edit dialog
              }
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(imageUrl, width: 400),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _setsController,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ElevatedButton(
          onPressed: () async {
            String terms = widget.exercise.image.substring(
              0,
              widget.exercise.image.length - 5,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.workoutProvider.updateExerciseDetails(
                  widget.workoutId,
                  widget.exerciseIndex,
                  _weightController.text,
                  _repsController.text,
                  _setsController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}