# Fitness Posters

Fitness Posters is a Flutter application that displays categorized fitness exercises with visual demonstrations. The app helps users browse exercises, save favorites, and create custom workout plans.

It is hosted at https://fitness-vibe.vercel.app

## Vibe Coded

This was Vibe Coded with Human Interaction (HI). 99% with Gemini-CLI (Gemini Pro 2.5). A PRD was one-shotted to Claude.ai to get the styling. Qwen-Code 0.0.10 updated this README.md to the current state of the app.

## Exercise Categories

The app organizes exercises into the following categories:
- **Bodyweight**: Exercises using only your body weight
- **Dumbbell**: Exercises using dumbbells
- **Yoga**: Various yoga poses organized by type (Warm-Up, Stretching, Balance, etc.)
- **Barbell**: Exercises using barbells

## Features

### Exercise Catalog
- Browse exercises organized by category and muscle group
- View exercise images in a responsive grid layout
- Adjust the number of columns in the image grid using the slider in the app bar (on larger screens)
- Tap on any exercise image to view an enlarged version

### Favorites
- Mark any exercise as a "favorite" with the heart icon
- View all favorite exercises in the dedicated "Favorites" tab
- Favorites are saved locally on your device

### Custom Workouts
- Create and manage custom workout routines in the "Workouts" tab
- Add any exercise from the catalog to your workouts
- Specify `weight`, `reps`, and `sets` for each exercise in a workout
- Edit workouts with features to:
  - Rename workouts
  - Reorder exercises
  - Modify exercise details (weight, reps, sets)
  - Remove exercises from workouts
  - Delete entire workouts

### Data Persistence
- **Development Mode**: All data (favorites and workouts) is saved locally using `shared_preferences`
- **Production Mode**: Data is saved to a remote server via an API, enabling cross-device synchronization when authentication is implemented

## Interface

The app features a responsive tab-based interface:
- **Favorites Tab** (heart icon): View your saved exercises
- **Workouts Tab**: Manage your custom workout plans
- **Category Tabs**: Browse exercises organized by type (Bodyweight, Dumbbell, Yoga, Barbell)

The interface supports multiple input methods:
- Touch gestures on mobile devices
- Keyboard navigation (arrow keys and spacebar)
- Mouse clicks

When viewing an exercise image, a dialog appears with:
- Enlarged exercise image
- Option to search for exercise videos on YouTube
- Ability to add the exercise to a custom workout

## Configuration

Exercise data is defined in `lib/posters_config.dart`:
- `imagePath`: Path to the exercise images directory (`assets/images`)
- `exercises`: A structured list of exercise categories, each containing:
  - `title`: Category name (e.g., 'Bodyweight')
  - `icon`: Material icon for the category tab
  - `color`: Theme color for the category
  - `exercises`: Map of muscle groups to exercise lists, where each exercise contains:
    - `image`: The image file name
    - `video`: YouTube video URL (currently unused, search is generated from image name)

## Technical Details

### Dependencies
- Flutter framework with Material Design
- `provider` for state management
- `shared_preferences` for local data storage
- `http` for API communication
- `url_launcher` for opening external links

### Data Models
- `ExerciseCategory`: Represents an exercise category with title, icon, color, and exercises
- `Exercise`: Represents a single exercise with image, name, muscle group, and category

### Architecture
The app follows a clean architecture pattern with:
- Configuration in `posters_config.dart`
- State management using `WorkoutProvider` with `ChangeNotifier`
- Separate views for each major feature (Favorites, Workouts, Exercise Categories)
- Responsive design that adapts to different screen sizes

### Build Information
- Version: 25.9.43
- Environment: Dart SDK ^3.9.0
- Assets: All exercise images stored in `assets/images/`