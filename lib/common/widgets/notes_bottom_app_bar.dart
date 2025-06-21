import 'package:flutter/material.dart';
import 'package:notes_on_short/utils/helpers/helper_functions.dart';

class NotesBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NotesBottomBar({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = const [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {
        'icon': Icons.star_outline,
        'activeIcon': Icons.star,
        'label': 'Starred'
      },
      {
        'icon': Icons.settings_outlined,
        'activeIcon': Icons.settings,
        'label': 'Settings'
      },
    ];

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(28),
      color: Colors.transparent,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: HelperFunctions.isDarkMode(context)
              ? Color(0xff1e1e1e)
              : Color(0xfff5f5f5),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = selectedIndex == index;
            final item = items[index];

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  onItemTapped(index);
                },
                splashColor: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: HelperFunctions.isDarkMode(context)
                              ? Colors.white
                              : Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        )
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? (item['activeIcon'] as IconData)
                            : (item['icon'] as IconData),
                        color: isSelected
                            ? HelperFunctions.isDarkMode(context)
                                ? Colors.black
                                : Colors.white
                            : Colors.grey,
                        size: 22,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 6 : 0,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isSelected ? null : 0,
                        child: isSelected
                            ? Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: HelperFunctions.isDarkMode(context)
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.clip,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
