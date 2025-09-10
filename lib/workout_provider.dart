import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

class WorkoutProvider with ChangeNotifier {
  List<Map<String, dynamic>> _workouts = [];
  List<String> _favorites = [];
  String? _errorMessage;

  List<Map<String, dynamic>> get workouts => _workouts;
  List<String> get favorites => _favorites;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
  }

  String? _getAuthTokenFromCookie() {
    if (kIsWeb) {
      final cookieName =
          '__Secure-next-auth.session-token'; // Replace with your actual cookie name
      final cookies = web.document.cookie.split(';');
      for (final cookie in cookies) {
        final parts = cookie.split('=');
        if (parts.length == 2 && parts[0].trim() == cookieName) {
          return parts[1].trim();
        }
      }
    }
    return null;
  }

  WorkoutProvider() {
    loadUserData();
  }

  // Combined data structure
  Map<String, dynamic> _getUserData() {
    return {'workouts': _workouts, 'favorites': _favorites};
  }

  void _parseUserData(Map<String, dynamic> data) {
    if (data.containsKey('workouts')) {
      final workoutsData = data['workouts'] as List;
      _workouts = workoutsData.map((item) {
        final workout = item as Map<String, dynamic>;
        workout['exercises'] = (workout['exercises'] as List)
            .map((ex) => ex as Map<String, dynamic>)
            .toList();
        return workout;
      }).toList();
    }
    if (data.containsKey('favorites')) {
      _favorites = (data['favorites'] as List)
          .map((i) => i.toString().replaceAll('.jpg', '.webp'))
          .toList();
    }
  }

  // Favorites method
  void toggleFavorite(String exerciseImage) {
    if (_favorites.contains(exerciseImage)) {
      _favorites.remove(exerciseImage);
    } else {
      _favorites.add(exerciseImage);
    }
    saveUserData();
    notifyListeners();
  }

  // Workout methods
  String addWorkout(String name) {
    final newWorkout = {
      'id': DateTime.now().toIso8601String(),
      'name': name,
      'exercises': <Map<String, dynamic>>[],
    };
    _workouts.add(newWorkout);
    saveUserData();
    notifyListeners();
    return newWorkout['id'] as String;
  }

  void deleteWorkout(String id) {
    _workouts.removeWhere((workout) => workout['id'] == id);
    saveUserData();
    notifyListeners();
  }

  void addExerciseToWorkout(
    String workoutId,
    String exerciseImage,
    String muscleGroup,
  ) {
    final workout = _workouts.firstWhere((w) => w['id'] == workoutId);
    (workout['exercises'] as List<Map<String, dynamic>>).add({
      'image': exerciseImage,
      'muscleGroup': muscleGroup,
      'weight': '0',
      'reps': '10',
      'sets': '3',
    });
    saveUserData();
    notifyListeners();
  }

  void updateWorkout(Map<String, dynamic> updatedWorkout) {
    final index = _workouts.indexWhere((w) => w['id'] == updatedWorkout['id']);
    if (index != -1) {
      _workouts[index] = updatedWorkout;
      saveUserData();
      notifyListeners();
    }
  }

  void removeExerciseFromWorkout(String workoutId, int exerciseIndex) {
    final workout = _workouts.firstWhere((w) => w['id'] == workoutId);
    (workout['exercises'] as List<Map<String, dynamic>>).removeAt(
      exerciseIndex,
    );
    saveUserData();
    notifyListeners();
  }

  void updateWorkoutName(String workoutId, String newName) {
    final workout = _workouts.firstWhere((w) => w['id'] == workoutId);
    workout['name'] = newName;
    saveUserData();
    notifyListeners();
  }

  void reorderExercise(String workoutId, int oldIndex, int newIndex) {
    final workout = _workouts.firstWhere((w) => w['id'] == workoutId);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final exercises = workout['exercises'] as List<Map<String, dynamic>>;
    final exercise = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, exercise);
    saveUserData();
    notifyListeners();
  }

  void updateExerciseDetails(
    String workoutId,
    int exerciseIndex,
    String weight,
    String reps,
    String sets,
  ) {
    final workout = _workouts.firstWhere((w) => w['id'] == workoutId);
    final exercise =
        (workout['exercises'] as List<Map<String, dynamic>>)[exerciseIndex];
    exercise['weight'] = weight;
    exercise['reps'] = reps;
    exercise['sets'] = sets;
    saveUserData();
    notifyListeners();
  }

  // Unified saving/loading
  Future<void> loadUserData() async {
    //if (kReleaseMode) {
    //  await getUserDataFromApi();
    //} else {
    await _loadUserDataFromPrefs();
    //}
  }

  Future<void> saveUserData() async {
    //if (kReleaseMode) {
    //  await saveUserDataToApi();
    //} else {
    await _saveUserDataToPrefs();
    //}
  }

  Future<void> _saveUserDataToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = json.encode(_getUserData());
      await prefs.setString('userData', userDataJson);
    } catch (e) {
      _errorMessage = 'Failed to save user data to local storage.';
      notifyListeners();
    }
  }

  Future<void> _loadUserDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString('userData');
      if (userDataJson != null) {
        _parseUserData(json.decode(userDataJson));
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data from local storage.';
      notifyListeners();
    }
  }

  Future<void> saveUserDataToApi() async {
    const baseUrl = kReleaseMode
        ? 'https://fitness-vibe.vercel.app'
        : 'http://localhost:3000';

    try {
      final csrfResponse = await http.get(Uri.parse('$baseUrl/api/auth/csrf'));
      if (csrfResponse.statusCode != 200) {
        throw Exception('Failed to get CSRF token');
      }
      final csrfToken = json.decode(csrfResponse.body)['csrfToken'];

      final body = {'csrfToken': csrfToken, 'data': _getUserData()};

      final authToken = _getAuthTokenFromCookie();
      final headers = {'Content-Type': 'application/json'};
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/blob'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save data');
      }
    } catch (e) {
      _errorMessage = 'Failed to save user data. Click DISMISS to reload.';
      notifyListeners();
    }
  }

  Future<void> getUserDataFromApi() async {
    const baseUrl = kReleaseMode
        ? 'https://fitness-vibe.vercel.app'
        : 'http://localhost:3000';

    try {
      final authToken = _getAuthTokenFromCookie();
      final headers = <String, String>{};
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/blob'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          if (data['data'] != null) {
            _parseUserData(data['data']);
          }
          notifyListeners();
        }
      } else {
        throw Exception('Failed to load user data from API');
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data. Click DISMISS to reload.';
      notifyListeners();
    }
  }
}
