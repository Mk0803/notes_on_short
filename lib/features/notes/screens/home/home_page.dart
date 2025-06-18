import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:notes_on_short/common/widgets/confirmation_dialog.dart';
import 'package:notes_on_short/features/notes/controllers/home_controller.dart';
import 'package:notes_on_short/features/notes/services/notes_repository.dart';
import 'package:notes_on_short/features/notes/widgets/sync_button.dart';
import 'package:notes_on_short/utils/constants/colors.dart';
import 'package:notes_on_short/utils/helpers/helper_functions.dart';
import 'package:provider/provider.dart';
import '../../../../common/widgets/notes_bottom_app_bar.dart';
import 'home_view.dart';
import '../create_note_screen.dart';
import '../settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late HomeController _homeController;
  late NotesRepository _notesRepository;
  late ScrollController _scrollController;
  late PageController _pageController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scrollController = ScrollController();
    _pageController = PageController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeController = Provider.of<HomeController>(context, listen: false);
    _notesRepository = Provider.of<NotesRepository>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notesRepository.ensureDataLoaded().then((_) {
        if (_homeController.isLoading) {
          _homeController.loadNotes();
        }
      });
    });
  }

  void _onSearchChanged() {
    _notesRepository.searchNotes(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer2<HomeController, NotesRepository>(
      builder: (context, homeController, notesRepository, _) {
        if (_pageController.hasClients) {
          final currentPageIndex = _pageController.page?.round() ?? 0;
          final targetIndex = homeController.selectedIndex;
          final pageGap = (currentPageIndex - targetIndex).abs();

          if (pageGap >= 2) {
            _pageController.jumpToPage(targetIndex);
          } else if (currentPageIndex != targetIndex) {
            final currentPage = _pageController.page ?? 0;
            final isUserSwiping =
                (currentPage - currentPage.round()).abs() > 0.1;
            if (isUserSwiping) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                homeController.updateSelectedIndex(currentPageIndex);
              });
            } else {
              _pageController.animateToPage(
                targetIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        }

        return Scaffold(
          extendBody: true,
          backgroundColor: colorScheme.surface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: AppBar(
              title: Text(
                _getAppBarTitle(homeController.selectedIndex),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: _buildAppBarActions(homeController, notesRepository),
            ),
          ),
          body: Column(
            children: [
              if (homeController.isSearchActive)
                _buildSearchBar(notesRepository),
              if (notesRepository.hasActiveFilters)
                _buildActiveFiltersBar(notesRepository),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollEndNotification &&
                        _pageController.hasClients) {
                      final currentPageIndex =
                          _pageController.page?.round() ?? 0;
                      if (homeController.selectedIndex != currentPageIndex) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          homeController.updateSelectedIndex(currentPageIndex);
                        });
                      }
                    }
                    return false;
                  },
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: homeController.setSelectedIndex,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildHomePage(homeController, notesRepository),
                      _buildStarredPage(homeController, notesRepository),
                      SettingsPage(),
                    ],
                  ),
                ),
              )
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(homeController),
        );
      },
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Notes';
      case 1:
        return 'Starred';
      case 2:
        return 'Settings';
      default:
        return 'Notes';
    }
  }

  List<Widget> _buildAppBarActions(
      HomeController homeController, NotesRepository notesRepository) {
    if (homeController.selectedIndex == 2) return [];
    return [
      IconButton(
        onPressed: () {
          homeController.toggleSearch();
          if (!homeController.isSearchActive) {
            _searchController.clear();
            notesRepository.clearSearch();
          }
        },
        icon: homeController.isSearchActive
            ? const Icon(Icons.clear)
            : const Icon(Icons.search),
      ),
      Row(
        children: [
          SyncButton(
            isSyncing: notesRepository.isSyncing,
            onSyncPressed: _syncNotes,
            controller: _animationController,
          )
        ],
      ),
      IconButton(
        onPressed: () => _showFilterOptions(notesRepository),
        icon: const Icon(Icons.filter_list),
      ),
    ];
  }

  Widget _buildSearchBar(NotesRepository notesRepository) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
              notesRepository.clearSearch();
            },
            icon: const Icon(Icons.clear),
          )
              : null,
          filled: true,
          fillColor: HelperFunctions.isDarkMode(context)
              ? Colors.grey[800]
              : NotesColorsLight.notesWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: 'Search notes...',
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersBar(NotesRepository notesRepository) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            'Filters:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (notesRepository.colorFilter.isNotEmpty)
                  _buildFilterChip(
                    label: 'Color: ${notesRepository.colorFilter.substring(0, 1).toUpperCase() + notesRepository.colorFilter.substring(1)}',
                    onDeleted: () => notesRepository.clearColorFilter(),
                    color: _getColorFromName(notesRepository.colorFilter),
                  ),
                if (notesRepository.searchQuery.isNotEmpty)
                  _buildFilterChip(
                    label: 'Search: "${notesRepository.searchQuery}"',
                    onDeleted: () {
                      _searchController.clear();
                      notesRepository.clearSearch();
                    },
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              notesRepository.clearAllFilters();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    Color? color,
  }) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: color?.withOpacity(0.2),
      side: color != null ? BorderSide(color: color, width: 1) : null,
    );
  }

  Widget _buildHomePage(
      HomeController homeController, NotesRepository notesRepository) {
    return HomeView(
      notes: notesRepository.notes,
      isLoading: homeController.isLoading && !notesRepository.isDataLoaded,
      onRefresh: () async {
        await notesRepository.forceReloadFromDatabase();
      },
      scrollController: _scrollController,
      showEmptyState: _getEmptyStateMessage(notesRepository),
    );
  }

  Widget _buildStarredPage(
      HomeController homeController, NotesRepository notesRepository) {
    return HomeView(
      notes: notesRepository.starredNotes,
      isLoading: homeController.isLoading && !notesRepository.isDataLoaded,
      onRefresh: () async {
        await notesRepository.forceReloadFromDatabase();
      },
      scrollController: _scrollController,
      showEmptyState: _buildStarredEmptyState(),
    );
  }

  Widget _getEmptyStateMessage(NotesRepository notesRepository) {
    if (notesRepository.searchQuery.isNotEmpty || notesRepository.colorFilter.isNotEmpty) {
      return _buildSearchEmptyState();
    }
    return _buildDefaultEmptyState();
  }

  Widget _buildDefaultEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.note_alt_outlined,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'No notes yet',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the + button to create one',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'No notes found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your filters',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStarredEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.star_outline,
          size: 64,
          color: Colors.amber,
        ),
        const SizedBox(height: 16),
        const Text(
          'No starred notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Star your favorite notes to see them here',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(HomeController homeController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: NotesBottomBar(
                selectedIndex: homeController.selectedIndex,
                onItemTapped: homeController.setSelectedIndex,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FloatingActionButton(
              elevation: 0,
              shape: const CircleBorder(),
              onPressed: _addNewNote,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewNote() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
      );
    });
  }

  Future<void> _syncNotes() async {
    final shouldSync = await showDialog<bool>(
      context: context,
      builder: (context) {
        return const ConfirmationDialog(
          title: "Sync Notes?",
          message: "Once Synced, changes cannot be undone!",
        );
      },
    );
    if (shouldSync ?? false) {
      _notesRepository.syncNotes();
    }
  }

  void _showFilterOptions(NotesRepository notesRepository) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter & Sort Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Filter by Color'),
              onTap: () {
                Navigator.pop(context);
                _showColorFilterDialog(notesRepository);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Sort by Title (A-Z)'),
              onTap: () {
                notesRepository.sortNotesByTitle(ascending: true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Sort by Title (Z-A)'),
              onTap: () {
                notesRepository.sortNotesByTitle(ascending: false);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Sort by Date (Newest)'),
              onTap: () {
                notesRepository.sortNotesByDate(ascending: false);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Sort by Date (Oldest)'),
              onTap: () {
                notesRepository.sortNotesByDate(ascending: true);
                Navigator.pop(context);
              },
            ),
            if (notesRepository.hasActiveFilters)
              const Divider(),
            if (notesRepository.hasActiveFilters)
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear All Filters'),
                onTap: () {
                  _searchController.clear();
                  notesRepository.clearAllFilters();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showColorFilterDialog(NotesRepository notesRepository) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter by Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView(
                children: [
                  // Clear filter option
                  ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                      ),
                      child: const Icon(
                        Icons.clear,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                    title: const Text('All Colors'),
                    trailing: notesRepository.colorFilter.isEmpty
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      notesRepository.clearColorFilter();
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  // Color options
                  ..._getAvailableColors(notesRepository).map((colorName) {
                    final isSelected = notesRepository.colorFilter.toLowerCase() == colorName.toLowerCase();
                    final color = _getColorFromName(colorName);
                    return ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      title: Text(colorName.substring(0, 1).toUpperCase() + colorName.substring(1)),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        notesRepository.filterByColor(colorName);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableColors(NotesRepository notesRepository) {
    // Get unique colors from existing notes
    final existingColors = notesRepository.getUniqueColors();

    // Define all possible colors from your color scheme
    final allColors = [
      'default', 'white', 'coral', 'peach', 'sand', 'mint',
      'sage', 'fog', 'storm', 'dusk', 'blossom', 'clay', 'chalk'
    ];

    // Return only colors that exist in notes, but ensure we have at least the basic colors
    final availableColors = <String>[];
    for (final color in allColors) {
      if (existingColors.contains(color)) {
        availableColors.add(color);
      }
    }

    // If no colors found, return default set
    if (availableColors.isEmpty) {
      return ['default', 'white'];
    }

    return availableColors;
  }

  Color _getColorFromName(String colorName) {
    final isDark = HelperFunctions.isDarkMode(context);

    final colorData = isDark
        ? [
      {'name': 'default', 'color': NotesColorsDark.notesDefault},
      {'name': 'coral', 'color': NotesColorsDark.notesCoral},
      {'name': 'peach', 'color': NotesColorsDark.notesPeach},
      {'name': 'sand', 'color': NotesColorsDark.notesSand},
      {'name': 'mint', 'color': NotesColorsDark.notesMint},
      {'name': 'sage', 'color': NotesColorsDark.notesSage},
      {'name': 'fog', 'color': NotesColorsDark.notesFog},
      {'name': 'storm', 'color': NotesColorsDark.notesStorm},
      {'name': 'dusk', 'color': NotesColorsDark.notesDusk},
      {'name': 'blossom', 'color': NotesColorsDark.notesBlossom},
      {'name': 'clay', 'color': NotesColorsDark.notesClay},
      {'name': 'chalk', 'color': NotesColorsDark.notesChalk},
    ]
        : [
      {'name': 'default', 'color': NotesColorsLight.notesDefault},
      {'name': 'white', 'color': NotesColorsLight.notesWhite},
      {'name': 'coral', 'color': NotesColorsLight.notesCoral},
      {'name': 'peach', 'color': NotesColorsLight.notesPeach},
      {'name': 'sand', 'color': NotesColorsLight.notesSand},
      {'name': 'mint', 'color': NotesColorsLight.notesMint},
      {'name': 'sage', 'color': NotesColorsLight.notesSage},
      {'name': 'fog', 'color': NotesColorsLight.notesFog},
      {'name': 'storm', 'color': NotesColorsLight.notesStorm},
      {'name': 'dusk', 'color': NotesColorsLight.notesDusk},
      {'name': 'blossom', 'color': NotesColorsLight.notesBlossom},
      {'name': 'clay', 'color': NotesColorsLight.notesClay},
      {'name': 'chalk', 'color': NotesColorsLight.notesChalk},
    ];

    try {
      final colorMap = colorData.firstWhere(
            (element) => element['name'] == colorName.toLowerCase(),
        orElse: () => colorData.first,
      );
      return colorMap['color'] as Color;
    } catch (e) {
      // Return default color if not found
      return isDark ? NotesColorsDark.notesDefault : NotesColorsLight.notesDefault;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}