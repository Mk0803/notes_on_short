import 'package:flutter/material.dart';
import 'package:notes_on_short/common/widgets/confirmation_dialog.dart';
import 'package:notes_on_short/features/notes/controllers/home_controller.dart';
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
  late AnimationController _controller;
  late HomeController _homeController;
  late ScrollController _scrollController;
  late PageController _pageController;
  final TextEditingController _searchController = TextEditingController();

  // FAB is always visible
  int _selectedIndex = 0;
  bool _isSearchSelected = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scrollController = ScrollController();
    _pageController = PageController(initialPage: _selectedIndex);

    _searchController.addListener(() {
      setState(() {}); // triggers rebuild to update suffixIcon
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeController = Provider.of<HomeController>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeController.loadNotes();
    });
  }

  Future<void> _addNewNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
    );
    if (result == true) {
      _homeController.loadNotes();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildHomePage() {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        return HomeView(
          notes: controller.notes,
          isLoading: controller.isLoading,
          onRefresh: controller.loadNotes,
          scrollController: _scrollController,
        );
      },
    );
  }

  Widget _buildStarredPage() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            size: 60,
            color: Colors.amber,
          ),
          SizedBox(height: 16),
          Text(
            'Starred Notes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your favorite notes will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    final int previousIndex = _selectedIndex;
    final int distance = (index - previousIndex).abs();

    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        _isSearchSelected = false; // Hide search bar when switching to settings
      }

      if (distance == 1) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.jumpToPage(index);
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        _isSearchSelected =
            false; // Hide search bar when landing on settings page
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchSelected = !_isSearchSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: Text(
            _selectedIndex == 0
                ? 'Notes'
                : _selectedIndex == 1
                    ? 'Starred'
                    : 'Settings',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: _selectedIndex != 2
              ? [
                  IconButton(
                    onPressed: _toggleSearch,
                    icon: _isSearchSelected
                        ? const Icon(Icons.clear)
                        : const Icon(Icons.search),
                  ),
                  Consumer<HomeController>(
                    builder: (context, controller, _) {
                      if (controller.isSyncing) {
                        _controller.repeat();
                      } else {
                        _controller.stop();
                      }
                      return Row(
                        children: [
                          SyncButton(
                            isSyncing: controller.isSyncing,
                            onSyncPressed: _syncNotes,
                            controller: _controller,
                          )
                        ],
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list),
                  ),
                ]
              : [],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (_isSearchSelected)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: _selectedIndex != 2
                    ? TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () => _searchController.clear(),
                                  icon: Icon(Icons.clear),
                                )
                              : null,
                          filled: true,
                          fillColor: HelperFunctions.isDarkMode(context)
                              ? Colors.grey[800]
                              : NotesColorsLight.notesWhite,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none // circular border
                              ),
                          hintText: 'Search notes...',
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      )
                    : null,
              ),
            Expanded(
              child: Container(
                color: colorScheme.surface,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    _buildHomePage(),
                    _buildStarredPage(),
                    SettingsPage(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bottom App Bar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: NotesBottomBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
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
      ),
    );
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
      _homeController.syncNotes();
    }
  }
}


