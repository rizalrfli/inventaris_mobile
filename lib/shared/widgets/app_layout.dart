import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppLayout({super.key, required this.navigationShell});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool _showSplash = false;

  void _onItemTapped(int index) async {
    if (index == widget.navigationShell.currentIndex) return;

    setState(() {
      _showSplash = true;
    });

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );

    // Menampilkan splash screen selama 600 ms
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          body: widget.navigationShell,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: colorScheme.surface,
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(LucideIcons.layoutDashboard),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: Icon(LucideIcons.barChart2),
                  label: 'Tracking',
                ),
                NavigationDestination(
                  icon: Icon(LucideIcons.bot),
                  label: 'AI Asisten',
                ),
              ],
            ),
          ),
          floatingActionButton: widget.navigationShell.currentIndex == 0
              ? FloatingActionButton(
                  onPressed: () => context.push('/add-transaction'),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  child: const Icon(LucideIcons.plus),
                )
              : null,
        ),
        if (_showSplash)
          Positioned.fill(
            child: Container(
              color: colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.wallet, size: 80, color: colorScheme.primary),
                    const SizedBox(height: 24),
                    CircularProgressIndicator(color: colorScheme.primary),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
