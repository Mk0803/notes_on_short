import 'package:flutter/material.dart';
import 'package:notes_on_short/common/widgets/confirmation_dialog.dart';
import 'package:notes_on_short/features/notes/controllers/home_controller.dart';
import 'package:notes_on_short/features/notes/widgets/sync_button.dart'; // Import SyncButton
import 'package:provider/provider.dart';
import '../../../../common/widgets/bottom_app_bar.dart';
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
  int _selectedIndex = 0;
  late AnimationController _controller;
  late HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize HomeController
    _homeController = Provider.of<HomeController>(context, listen: false);

    // Load notes after build
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
    super.dispose();
  }

  Widget _buildHomePage() {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        return HomeView(
          notes: controller.notes,
          isLoading: controller.isLoading,
          onRefresh: controller.loadNotes,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [_buildHomePage(), SettingsPage()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes on Short'),
        actions: [
          Consumer<HomeController>(
            builder: (context, controller, _) {
              // Update the controller's animation based on isSyncing
              if (controller.isSyncing) {
                _controller.repeat();
              } else {
                _controller.stop();
              }

              return SyncButton(
                isSyncing: controller.isSyncing,
                onSyncPressed: () async {
                  final shouldSync = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return ConfirmationDialog(
                        title: "Sync Notes?",
                        message: "Once Synced, changes cannot be undone!",
                      );
                    },
                  );

                  if (shouldSync ?? false) {
                    _homeController.syncNotes();
                  }
                },
                controller: _controller,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _homeController.loadNotes,
            tooltip: 'Refresh Notes',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.5),
        child: screens[_selectedIndex],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: _addNewNote,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomAppBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
        colorScheme: Theme.of(context).colorScheme,
      ),
    );
  }



}
