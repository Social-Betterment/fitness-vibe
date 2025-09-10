import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fitness_posters/posters_config.dart' as config;
import 'package:provider/provider.dart';
import 'package:fitness_posters/exercise_category_view.dart';
import 'package:fitness_posters/favorites_view.dart';
import 'package:fitness_posters/workouts_view.dart';
import 'package:fitness_posters/workout_provider.dart';
import 'package:web/web.dart' as web;
import 'package:fitness_posters/loading_animation.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'Fitness Vibe',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          fontFamily: 'SF Pro Display',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          fontFamily: 'SF Pro Display',
        ),
        home: FutureBuilder(
          future: Future.delayed(const Duration(seconds: 2)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: LoadingAnimation());
            } else {
              return const HomeScreen();
            }
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _defaultGridSize = 256;
  num _crossAxisCount = 0;
  late TabController _tabController;
  bool _tabControllerInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tabControllerInitialized) {
      final workoutProvider = Provider.of<WorkoutProvider>(
        context,
        listen: false,
      );

      int initialIndex = 0;
      if (workoutProvider.favorites.isEmpty &&
          workoutProvider.workouts.isEmpty) {
        initialIndex = 2;
      }

      _tabController = TabController(
        initialIndex: initialIndex,
        length: config.exerciseCategories.length + 2,
        vsync: this,
      );
      _tabControllerInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 650;
    num crossAxisCountSuggestion = max(
      2,
      min<num>((screenWidth / _defaultGridSize).round(), 20),
    );
    num crossAxisCount = (_crossAxisCount == 0)
        ? crossAxisCountSuggestion
        : _crossAxisCount;

    final workoutProvider = Provider.of<WorkoutProvider>(context);

    if (workoutProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server Connection Error: ${workoutProvider.errorMessage!}',
            ),
            duration: const Duration(days: 365),
            action: SnackBarAction(
              label: 'DISMISS',
              onPressed: () {
                workoutProvider.clearError();
                if (kIsWeb) {
                  web.window.location.reload();
                }
              },
            ),
          ),
        );
      });
    }

    final List<Widget> allTabs = [
      const Tab(icon: Icon(Icons.favorite, size: 18)),
      const Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add_check, size: 18),
            SizedBox(width: 8),
            Text('Workouts'),
          ],
        ),
      ),
      ...config.exerciseCategories.map<Widget>(
        (category) => Tab(
          child: Row(
            children: [
              Icon(category.icon, size: 18),
              const SizedBox(width: 8),
              Text(category.title),
            ],
          ),
        ),
      ),
    ];

    final favoritesView = FavoritesView(crossAxisCount: crossAxisCount);

    final workoutsView = WorkoutsView(crossAxisCount: crossAxisCount);

    final exerciseViews = config.exerciseCategories
        .map<Widget>(
          (category) => ExerciseCategoryView(
            exerciseCategory: category,
            crossAxisCount: crossAxisCount,
          ),
        )
        .toList();

    final List<Widget> allTabViews = [
      favoritesView,
      workoutsView,
      ...exerciseViews,
    ];

    return DefaultTabController(
      length: allTabs.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Fitness Vibe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 12),
              TextButton(
                onPressed: () async {
                  final Uri url = Uri.parse(
                    'https://github.com/Social-Betterment/fitness-vibe',
                  );
                  if (!await launchUrl(url)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not launch the GitHub repository',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  isSmallScreen
                      ? 'Source Code'
                      : 'Source Code to this Vibe-Coded App',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (isSmallScreen == false) // Show slider only on large screens
              SizedBox(
                width: 140,
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_view,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    Expanded(
                      child: Slider(
                        value: crossAxisCount * 1.0,
                        min: 2,
                        max: 20,
                        divisions: 18,
                        onChanged: (value) {
                          setState(() {
                            _crossAxisCount = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(width: 16),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.6),
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 18),
                    SizedBox(width: 8),
                    Text('Favorites'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.playlist_add_check, size: 18),
                    SizedBox(width: 8),
                    Text('Workouts'),
                  ],
                ),
              ),
              ...config.exerciseCategories.map(
                (category) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, size: 18),
                      SizedBox(width: 8),
                      Text(category.title),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: allTabViews),
      ),
    );
  }
}
