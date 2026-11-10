import 'package:flutter/material.dart';
import 'package:nix_design/nix_design.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nix Design Example',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  int _navIndex = 0;
  int _segmentedValue = 0;
  bool _switchValue = true;
  bool _filterSelected = true;
  String? _selectedPopupItem;
  final ScrollController _scrollController = ScrollController();

  // NixListView state
  bool _isSelectionMode = false;
  Set<int> _selectedTrackIndices = {};
  int? _playingTrackIndex;
  late List<Map<String, String>> _playlistTracks;

  @override
  void initState() {
    super.initState();
    _resetPlaylist();
  }

  void _resetPlaylist() {
    _playlistTracks = [
      {
        'title': 'Midnight City Waves',
        'artist': 'Nix Synthetics',
        'duration': '3:45',
      },
      {
        'title': 'Electric Horizon',
        'artist': 'Cyberpulse & Nova',
        'duration': '4:12',
      },
      {
        'title': 'Quantum Resonance',
        'artist': 'Subsurface Audio',
        'duration': '3:18',
      },
      {
        'title': 'Neon Silhouette',
        'artist': 'Starlight Echoes',
        'duration': '5:02',
      },
      {
        'title': 'Velvet Dreams',
        'artist': 'Atmosphere One',
        'duration': '2:55',
      },
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openSearchSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NixSearchSheet(
        onSelectComponent: (tabIndex, componentName) {
          Navigator.of(ctx).pop();
          setState(() => _navIndex = tabIndex);
          NixSnackBar.show(context, message: 'Navigated to $componentName');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Nix Design System'),
        actions: [
          NixIconButton.tonal(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Dialog',
            onPressed: () {
              showNixDialog(
                context: context,
                builder: (ctx) => NixDialog(
                  icon: const Icon(Icons.celebration_rounded),
                  title: const Text('Nix Design System'),
                  content: const Text(
                    'Pure pill-styled design system for Flutter.\n\n'
                    'Floating Navigation Tip:\n'
                    'When using NixBottomBar, add "extendBody: true" to your Scaffold so that your body content extends and scrolls smoothly underneath the floating pill navigation bar.',
                  ),
                  actions: [
                    NixButton.text(
                      label: const Text('Close'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    NixButton.filled(
                      label: const Text('Confirm'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          NixPopupMenu<String>(
            maxWidth: 200,
            onSelected: (val) {
              setState(() => _selectedPopupItem = val);
              debugPrint('AppBar popup selected: $val');
            },
            items: const [
              NixPopupMenuItem(
                value: 'profile',
                label: Text('Profile'),
                icon: Icon(Icons.person_outline),
              ),
              NixPopupMenuItem(
                value: 'settings',
                label: Text('Settings'),
                icon: Icon(Icons.settings_outlined),
                trailing: Text('⌘,'),
              ),
              NixPopupMenuItem(
                value: 'docs',
                label: Text('Documentation'),
                icon: Icon(Icons.menu_book_outlined),
              ),
              NixPopupMenuItem.destructive(
                value: 'sign_out',
                label: Text('Sign Out'),
                icon: Icon(Icons.logout_rounded),
              ),
            ],
            child: const NixIconButton.tonal(
              icon: Icon(Icons.more_vert_rounded),
              tooltip: 'Menu (Tap or Hold & Drag)',
              onPressed: null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: NixBottomBar(
        scrollController: _scrollController,
        currentIndex: _navIndex,
        maxWidth: 420,
        onTap: (index) => setState(() => _navIndex = index),
        onLongPress: (index) {
          final titles = ['Home', 'Widgets', 'Lists', 'Feedback'];
          final name = index < titles.length ? titles[index] : 'Item $index';
          showNixDialog<void>(
            context: context,
            builder: (ctx) => NixDialog(
              title: Text("Long press $name"),
              content: Text("Long press $name"),
              actions: [
                NixButton.text(
                  label: const Text('Close'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                NixButton.filled(
                  label: const Text('Confirm'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          );
        },
        hideOnScroll: false,
        items: const [
          NixBottomBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NixBottomBarItem(
            icon: Icon(Icons.widgets_outlined),
            activeIcon: Icon(Icons.widgets_rounded),
            label: 'Widgets',
          ),
          NixBottomBarItem(
            icon: Icon(Icons.view_agenda_outlined),
            activeIcon: Icon(Icons.view_agenda_rounded),
            label: 'Lists',
          ),
          NixBottomBarItem(
            icon: Icon(Icons.layers_outlined),
            activeIcon: Icon(Icons.layers_rounded),
            label: 'Feedback',
          ),
        ],
        action: NixIconButton.tonal(
          size: NixSize.large,
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search components',
          onPressed: _openSearchSheet,
        ),
        actionPosition: NixBarActionPosition.right,
      ),
      body: _buildCurrentTab(),
    );
  }

  Widget _buildCurrentTab() {
    switch (_navIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildWidgetsTab();
      case 2:
        return _buildListsTab();
      case 3:
        return _buildFeedbackTab();
      default:
        return _buildHomeTab();
    }
  }

  // ---------------------------------------------------------------------------
  // TAB 0: HOME
  // ---------------------------------------------------------------------------
  Widget _buildHomeTab() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 110.0),
      children: [
        NixCard.pill(
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pure pill-styled widgets following native Flutter ergonomics.',
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NixButton.text(
                    size: NixSize.small,
                    label: const Text('Top'),
                    onPressed: () {
                      NixSnackBar.show(
                        context,
                        position: NixSnackBarPosition.top,
                        icon: const Icon(Icons.notifications_active_rounded),
                        message: 'Top floating pill (slide down/up)',
                        actionLabel: 'OK',
                        onAction: () {},
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  NixButton.text(
                    size: NixSize.small,
                    label: const Text('Bottom'),
                    onPressed: () {
                      NixSnackBar.show(
                        context,
                        position: NixSnackBarPosition.bottom,
                        icon: const Icon(Icons.check_circle_rounded),
                        message: 'Bottom floating pill (slide up/down)',
                        actionLabel: 'OK',
                        onAction: () {},
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Category Navigation Cards
        Text(
          'Component Categories',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                icon: Icons.widgets_rounded,
                title: 'Controls',
                subtitle: 'Buttons, Inputs',
                tabIndex: 1,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCategoryCard(
                icon: Icons.view_agenda_rounded,
                title: 'List View',
                subtitle: 'Squish Physics',
                tabIndex: 2,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCategoryCard(
                icon: Icons.layers_rounded,
                title: 'Feedback',
                subtitle: 'Popups, Overlays',
                tabIndex: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Featured Interactive Controls
        NixSegmentedControl<int>(
          value: _segmentedValue,
          onChanged: (val) => setState(() => _segmentedValue = val),
          items: const [
            NixSegment(value: 0, label: 'First'),
            NixSegment(value: 1, label: 'Second'),
            NixSegment(value: 2, label: 'Third'),
          ],
        ),
        const SizedBox(height: 16),

        // Quick switch & chip row
        NixCard(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 10.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Dark Pill Styling'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NixFilterChip(
                    label: const Text('Stadium'),
                    selected: _filterSelected,
                    onSelected: (val) => setState(() => _filterSelected = val),
                  ),
                  const SizedBox(width: 8),
                  NixSwitch(
                    value: _switchValue,
                    onChanged: (val) => setState(() => _switchValue = val),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Popup Menu Showcase Card
        _buildPopupMenuCard(),
      ],
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int tabIndex,
  }) {
    return NixCard(
      onTap: () => setState(() => _navIndex = tabIndex),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildWidgetsTab() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 110.0),
      children: [
        Text(
          'Inputs & Buttons',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Stadium/pill aesthetics with smooth shape morphing on press and hover.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Buttons Section
        NixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NixButton Variants & Morphing',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  NixButton.filled(
                    label: const Text('Filled'),
                    icon: const Icon(Icons.check_rounded),
                    onPressed: () {},
                  ),
                  NixButton.tonal(
                    label: const Text('Tonal'),
                    icon: const Icon(Icons.star_rounded),
                    onPressed: () {},
                  ),
                  NixButton.outlined(
                    label: const Text('Outlined'),
                    onPressed: () {},
                  ),
                  NixButton.text(label: const Text('Text'), onPressed: () {}),
                  NixButton.ghost(label: const Text('Ghost'), onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Icon Buttons & Switches
        NixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Icon Buttons & Switch Controls',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8.0,
                    children: [
                      NixIconButton.filled(
                        icon: const Icon(Icons.favorite_rounded),
                        tooltip: 'Favorite',
                        onPressed: () {},
                      ),
                      NixIconButton.tonal(
                        icon: const Icon(Icons.bookmark_rounded),
                        tooltip: 'Bookmark',
                        onPressed: () {},
                      ),
                      NixIconButton.outlined(
                        icon: const Icon(Icons.share_rounded),
                        tooltip: 'Share',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Animated Switch: '),
                      const SizedBox(width: 4),
                      NixSwitch(
                        value: _switchValue,
                        onChanged: (val) => setState(() => _switchValue = val),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chips & Segmented Controls
        NixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Segmented Controls & Filter Chips',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              NixSegmentedControl<int>(
                value: _segmentedValue,
                onChanged: (val) => setState(() => _segmentedValue = val),
                items: const [
                  NixSegment(value: 0, label: 'First'),
                  NixSegment(value: 1, label: 'Second'),
                  NixSegment(value: 2, label: 'Third'),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  NixFilterChip(
                    label: const Text('Flutter 3.41'),
                    selected: true,
                    onSelected: (val) {},
                  ),
                  NixFilterChip(
                    label: const Text('Material 3'),
                    selected: _filterSelected,
                    onSelected: (val) => setState(() => _filterSelected = val),
                  ),
                  NixChip(
                    label: const Text('Deletable Chip'),
                    onDeleted: () {
                      NixSnackBar.show(context, message: 'Deleted chip');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: LISTS & SQUISH PHYSICS
  // ---------------------------------------------------------------------------
  Widget _buildListsTab() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 110.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NixListView & Physics',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Segmented corners, squish physics & gestures',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            NixIconButton.tonal(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reset Playlist',
              onPressed: () {
                setState(() {
                  _resetPlaylist();
                  _selectedTrackIndices.clear();
                  _playingTrackIndex = null;
                });
                NixSnackBar.show(context, message: 'Playlist reset');
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        NixCard.pill(
          child: const Text(
            '• Segmented Radii: 16px container, 12px outer, 6px inner.\n'
            '• Dynamic Sealing: Playing/selected cards morph to 14px isolated pills; neighbors dynamically adapt corners!\n'
            '• Neighbour Squish Physics: Dragging compresses & stretches adjacent cards with volume preservation.\n'
            '• Independent Swipe: Swipe right to favorite, swipe left to delete.',
            style: TextStyle(fontSize: 12.5, height: 1.45),
          ),
        ),
        const SizedBox(height: 14),

        // Action Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NixFilterChip(
              label: Text(_isSelectionMode ? 'Exit Selection' : 'Select Mode'),
              avatar: Icon(
                _isSelectionMode
                    ? Icons.checklist_rtl_rounded
                    : Icons.checklist_rounded,
                size: 16,
              ),
              selected: _isSelectionMode,
              onSelected: (val) {
                setState(() {
                  _isSelectionMode = val;
                  if (!val) _selectedTrackIndices.clear();
                });
              },
            ),
            if (_isSelectionMode && _selectedTrackIndices.isNotEmpty)
              NixButton.tonal(
                size: NixSize.small,
                label: Text('Delete (${_selectedTrackIndices.length})'),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                onPressed: () {
                  setState(() {
                    final sorted = _selectedTrackIndices.toList()
                      ..sort((a, b) => b.compareTo(a));
                    for (final idx in sorted) {
                      if (idx < _playlistTracks.length) {
                        _playlistTracks.removeAt(idx);
                      }
                    }
                    _selectedTrackIndices.clear();
                    _playingTrackIndex = null;
                  });
                  NixSnackBar.show(context, message: 'Deleted selected tracks');
                },
              ),
          ],
        ),
        const SizedBox(height: 12),

        // The NixListView
        NixListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          reorderable: true,
          canReorderOnLongPress: true,
          selectionMode: _isSelectionMode
              ? NixSelectionMode.multi
              : NixSelectionMode.none,
          selectedIndices: _selectedTrackIndices,
          onSelectionChanged: (indices) {
            setState(() => _selectedTrackIndices = indices);
          },
          playingIndex: _playingTrackIndex,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final item = _playlistTracks.removeAt(oldIndex);
              _playlistTracks.insert(newIndex, item);
              if (_playingTrackIndex == oldIndex) {
                _playingTrackIndex = newIndex;
              } else if (_playingTrackIndex != null) {
                if (oldIndex < _playingTrackIndex! &&
                    newIndex >= _playingTrackIndex!) {
                  _playingTrackIndex = _playingTrackIndex! - 1;
                } else if (oldIndex > _playingTrackIndex! &&
                    newIndex <= _playingTrackIndex!) {
                  _playingTrackIndex = _playingTrackIndex! + 1;
                }
              }
            });
            NixSnackBar.show(context, message: 'Moved to slot #$newIndex');
          },
          emptyPlaceholder: NixCard.pill(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.playlist_remove_rounded,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All tracks dismissed',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap Reset to reload the demo tracks',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    NixButton.tonal(
                      size: NixSize.small,
                      label: const Text('Reset Playlist'),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      onPressed: () {
                        setState(() {
                          _resetPlaylist();
                          _selectedTrackIndices.clear();
                          _playingTrackIndex = null;
                        });
                        NixSnackBar.show(context, message: 'Playlist restored');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          children: List.generate(_playlistTracks.length, (index) {
            final track = _playlistTracks[index];
            final isPlayingThis = _playingTrackIndex == index;

            return NixListItem(
              key: ValueKey(track['title']!),
              leading: Icon(
                isPlayingThis
                    ? Icons.music_note_rounded
                    : Icons.graphic_eq_rounded,
                color: isPlayingThis
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(track['title']!),
              subtitle: Text('${track['artist']} • ${track['duration']}'),
              reorderHandle: const NixReorderHandle(),
              leftAction: NixSwipeAction(
                icon: const Icon(Icons.favorite_rounded),
                label: const Text('Favorite'),
                actionType: NixSwipeActionType.action,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                onTriggered: () {
                  NixSnackBar.show(
                    context,
                    message: 'Favorited "${track['title']}"',
                  );
                },
              ),
              rightAction: NixSwipeAction(
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
                actionType: NixSwipeActionType.dismiss,
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                onTriggered: () {
                  setState(() {
                    _playlistTracks.removeAt(index);
                    if (_playingTrackIndex == index) {
                      _playingTrackIndex = null;
                    } else if (_playingTrackIndex != null &&
                        _playingTrackIndex! > index) {
                      _playingTrackIndex = _playingTrackIndex! - 1;
                    }
                  });
                  NixSnackBar.show(
                    context,
                    message: 'Deleted "${track['title']}"',
                  );
                },
              ),
              onTap: () {
                if (!_isSelectionMode) {
                  setState(() {
                    _playingTrackIndex = isPlayingThis ? null : index;
                  });
                }
              },
            );
          }),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: FEEDBACK & OVERLAYS
  // ---------------------------------------------------------------------------
  Widget _buildFeedbackTab() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 110.0),
      children: [
        Text(
          'Feedback & Overlays',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Origin-aware animated popups, floating pill snackbars, and responsive dialogs.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        _buildPopupMenuCard(),
        const SizedBox(height: 16),

        NixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Floating Pill Snackbars',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  NixButton.filled(
                    label: const Text('Top Pill Snackbar'),
                    icon: const Icon(Icons.arrow_downward_rounded),
                    onPressed: () {
                      NixSnackBar.show(
                        context,
                        position: NixSnackBarPosition.top,
                        icon: const Icon(Icons.notifications_active_rounded),
                        message: 'Top floating pill (slide down entrance)',
                        actionLabel: 'Dismiss',
                        onAction: () {},
                      );
                    },
                  ),
                  NixButton.tonal(
                    label: const Text('Bottom Pill Snackbar'),
                    icon: const Icon(Icons.arrow_upward_rounded),
                    onPressed: () {
                      NixSnackBar.show(
                        context,
                        position: NixSnackBarPosition.bottom,
                        icon: const Icon(Icons.check_circle_rounded),
                        message: 'Bottom floating pill (slide up entrance)',
                        actionLabel: 'OK',
                        onAction: () {},
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        NixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dialogs',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              NixButton.outlined(
                label: const Text('Open Responsive Dialog'),
                icon: const Icon(Icons.open_in_browser_rounded),
                onPressed: () {
                  showNixDialog<void>(
                    context: context,
                    builder: (ctx) => NixDialog(
                      icon: const Icon(Icons.layers_rounded),
                      title: const Text('NixDialog'),
                      content: const Text(
                        'Automatically scrolls long content without RenderFlex bottom overflow.',
                      ),
                      actions: [
                        NixButton.text(
                          label: const Text('Close'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenuCard() {
    return NixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.menu_open_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Popup Menu (Dual Gesture & Dynamic Corners)',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dual gesture: Tap to open or hold-drag-release',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Dynamic segmented corners: 16px container (4px pad, 2px gap), top 12px / bottom 6px on first item, 6px inner, and top 6px / bottom 12px on last item.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              NixPopupMenu<String>(
                onSelected: (val) {
                  setState(() => _selectedPopupItem = val);
                },
                items: const [
                  NixPopupMenuItem(
                    value: 'edit',
                    label: Text('Edit Document'),
                    icon: Icon(Icons.edit_outlined),
                  ),
                  NixPopupMenuItem(
                    value: 'share',
                    label: Text('Share Link'),
                    icon: Icon(Icons.share_outlined),
                    trailing: Text('⌘S'),
                  ),
                  NixPopupMenuItem(
                    value: 'duplicate',
                    label: Text('Duplicate'),
                    icon: Icon(Icons.copy_rounded),
                  ),
                  NixPopupMenuItem.destructive(
                    value: 'delete',
                    label: Text('Delete Item'),
                    icon: Icon(Icons.delete_outline_rounded),
                  ),
                ],
                child: const NixButton.filled(
                  label: Text('Hold, Drag & Release Menu'),
                  icon: Icon(Icons.menu_rounded),
                  onPressed: null,
                ),
              ),
              NixPopupMenu<String>(
                onSelected: (val) {
                  setState(() => _selectedPopupItem = val);
                },
                items: const [
                  NixPopupMenuItem(
                    value: 'adaptive',
                    label: Text('Export project to another workspace'),
                    icon: Icon(Icons.drive_file_move_outlined),
                  ),
                  NixPopupMenuItem(
                    value: 'ellipsis',
                    label: Text(
                      'Long item clamped with ellipsis',
                      overflow: TextOverflow.ellipsis,
                    ),
                    icon: Icon(Icons.more_horiz_rounded),
                  ),
                ],
                child: const NixButton.tonal(
                  label: Text('Adaptive Width Menu'),
                  onPressed: null,
                ),
              ),
            ],
          ),
          if (_selectedPopupItem != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last selected: $_selectedPopupItem',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SEARCH BOTTOM SHEET
// -----------------------------------------------------------------------------
class _NixSearchSheet extends StatefulWidget {
  const _NixSearchSheet({required this.onSelectComponent});

  final void Function(int tabIndex, String componentName) onSelectComponent;

  @override
  State<_NixSearchSheet> createState() => _NixSearchSheetState();
}

class _NixSearchSheetState extends State<_NixSearchSheet> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  final List<
    ({String name, String category, int tabIndex, IconData icon, String desc})
  >
  _catalog = const [
    (
      name: 'NixButton',
      category: 'Widgets',
      tabIndex: 1,
      icon: Icons.smart_button_rounded,
      desc: 'Filled, tonal, text, outlined, elevated pill buttons',
    ),
    (
      name: 'NixIconButton',
      category: 'Widgets',
      tabIndex: 1,
      icon: Icons.radio_button_checked_rounded,
      desc: 'Stadium/circle icon buttons with press morphing',
    ),
    (
      name: 'NixSwitch',
      category: 'Widgets',
      tabIndex: 1,
      icon: Icons.toggle_on_rounded,
      desc: 'Animated track & thumb colors, 48x48 tap target',
    ),
    (
      name: 'NixSegmentedControl',
      category: 'Widgets',
      tabIndex: 1,
      icon: Icons.view_week_rounded,
      desc: 'Sliding pill segmented indicator',
    ),
    (
      name: 'NixChip & NixFilterChip',
      category: 'Widgets',
      tabIndex: 1,
      icon: Icons.label_rounded,
      desc: 'Filter chips with checkmark and delete actions',
    ),
    (
      name: 'NixListView',
      category: 'Lists',
      tabIndex: 2,
      icon: Icons.view_agenda_rounded,
      desc: 'Segmented 16/12/6px container with drag-to-reorder',
    ),
    (
      name: 'NixListItem',
      category: 'Lists',
      tabIndex: 2,
      icon: Icons.format_list_bulleted_rounded,
      desc: 'Dynamic corner morphing, swipe actions & selection',
    ),
    (
      name: 'Neighbour Squish Physics',
      category: 'Lists',
      tabIndex: 2,
      icon: Icons.compress_rounded,
      desc: 'Spring displacement & volume-preserving squash & stretch',
    ),
    (
      name: 'NixMusicEqualizer',
      category: 'Lists',
      tabIndex: 2,
      icon: Icons.graphic_eq_rounded,
      desc: 'Animated oscillating pill bars for active media items',
    ),
    (
      name: 'NixPopupMenu',
      category: 'Feedback',
      tabIndex: 3,
      icon: Icons.menu_open_rounded,
      desc: 'Dual gesture hold-drag-release & tap popup menu',
    ),
    (
      name: 'NixDialog',
      category: 'Feedback',
      tabIndex: 3,
      icon: Icons.chat_bubble_outline_rounded,
      desc: 'Responsive scrollable dialog with actions Wrap',
    ),
    (
      name: 'NixSnackBar',
      category: 'Feedback',
      tabIndex: 3,
      icon: Icons.notifications_active_rounded,
      desc: 'Top & bottom floating pill snackbar with slide curves',
    ),
    (
      name: 'NixBottomBar',
      category: 'Home',
      tabIndex: 0,
      icon: Icons.space_dashboard_rounded,
      desc: 'Floating pill navigation bar with equal-width items',
    ),
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final filtered = _catalog.where((item) {
      final q = _query.toLowerCase().trim();
      if (q.isEmpty) return true;
      return item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.desc.toLowerCase().contains(q);
    }).toList();

    return Material(
      color: colors.surfaceContainer,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
            child: Column(
              children: [
                // Drag handle pill
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Search Field
                TextField(
                  controller: _queryController,
                  autofocus: false,
                  onChanged: (val) => setState(() => _query = val),
                  decoration: InputDecoration(
                    hintText: 'Search components (e.g. list, button, popup)...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _queryController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Results list
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No matching components found for "$_query"',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: colors.primaryContainer
                                    .withValues(alpha: 0.6),
                                child: Icon(
                                  item.icon,
                                  color: colors.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                item.desc,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                              onTap: () => widget.onSelectComponent(
                                item.tabIndex,
                                item.name,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
