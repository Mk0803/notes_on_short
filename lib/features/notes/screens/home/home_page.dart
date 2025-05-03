import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notes_on_short/common/widgets/confirmation_dialog.dart';
import 'package:notes_on_short/features/notes/controllers/home_controller.dart';
import 'package:notes_on_short/features/notes/widgets/sync_button.dart';
import 'package:provider/provider.dart';
import 'home_view.dart';
import '../create_note_screen.dart';
import '../settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late HomeController _homeController;
  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsPage()),
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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
            'Notes',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<HomeController>(
              builder: (context, controller, _) {
                if (controller.isSyncing) {
                  _controller.repeat();
                } else {
                  _controller.stop();
                }
                return SyncButton(
                  isSyncing: controller.isSyncing,
                  onSyncPressed: _syncNotes,
                  controller: _controller,
                );
              },
            ),
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'refresh':
                    _homeController.loadNotes();
                    break;
                  case 'settings':
                    _openSettings();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Refresh Notes'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.5),
          child: _buildHomePage(),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 200),
        child: AnimatedOpacity(
          opacity: _isFabVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: _addNewNote,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}