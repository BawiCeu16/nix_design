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
      themeMode: ThemeMode.system,
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

  // NixBottomBar playground state
  NixBottomBarStyle _bottomBarStyle = NixBottomBarStyle.standard;
  bool _enableNavBarShrink = true;
  int _navBarItemCount = 4;
  NixBarActionPosition _barActionPosition = NixBarActionPosition.right;
  String _navBarContentType =
      'icon_text'; // 'icon_text', 'icon_only', 'text_only'

  List<NixBottomBarItem> get _navBarItems {
    final allItems = [
      NixBottomBarItem(
        icon: _navBarContentType != 'text_only'
            ? const Icon(Icons.home_outlined)
            : null,
        activeIcon: _navBarContentType != 'text_only'
            ? const Icon(Icons.home_rounded)
            : null,
        label: _navBarContentType != 'icon_only' ? 'Home' : null,
      ),
      NixBottomBarItem(
        icon: _navBarContentType != 'text_only'
            ? const Icon(Icons.widgets_outlined)
            : null,
        activeIcon: _navBarContentType != 'text_only'
            ? const Icon(Icons.widgets_rounded)
            : null,
        label: _navBarContentType != 'icon_only' ? 'Widgets' : null,
      ),
      NixBottomBarItem(
        icon: _navBarContentType != 'text_only'
            ? const Icon(Icons.view_agenda_outlined)
            : null,
        activeIcon: _navBarContentType != 'text_only'
            ? const Icon(Icons.view_agenda_rounded)
            : null,
        label: _navBarContentType != 'icon_only' ? 'Lists' : null,
      ),
      NixBottomBarItem(
        icon: _navBarContentType != 'text_only'
            ? const Icon(Icons.layers_outlined)
            : null,
        activeIcon: _navBarContentType != 'text_only'
            ? const Icon(Icons.layers_rounded)
            : null,
        label: _navBarContentType != 'icon_only' ? 'Feedback' : null,
      ),
    ];
    return allItems.take(_navBarItemCount).toList();
  }

  // NixSwitchTile state
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = true;
  bool _airplaneMode = false;
  bool _notificationsEnabled = true;
  bool _standaloneSwitch = true;

  // NixExpandable & App Update state
  bool _autoUpdateEnabled = true;
  bool _isUpdatingApp = false;
  double? _updateProgress;
  bool _vpnExpandedTile = false;

  // NixWaveSlider state
  double _musicPlaybackSeconds = 84.0;
  final double _musicTotalSeconds = 225.0;
  bool _isMusicPlaying = false;

  // NixListView state
  bool _isSelectionMode = false;
  Set<int> _selectedTrackIndices = {};
  int? _playingTrackIndex;
  late List<Map<String, String>> _playlistTracks;
  NixSwipeMode _swipeMode = NixSwipeMode.actions;
  NixSwipeDirection _swipeDirection = NixSwipeDirection.both;
  NixReorderTrigger _reorderTrigger = NixReorderTrigger.both;

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

  void _openVersionHistorySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _NixVersionHistorySheet(),
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
        style: _bottomBarStyle,
        scrollController: _scrollController,
        enableShrink: _enableNavBarShrink,
        shrinkOnScroll: _enableNavBarShrink,
        currentIndex: _navIndex >= _navBarItems.length ? 0 : _navIndex,
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
        items: _navBarItems,
        action: NixIconButton.filled(
          size: NixSize.large,
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search components',
          onPressed: _openSearchSheet,
        ),
        actionPosition: _barActionPosition,
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
                subtitle: 'Corner Morphs',
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
        const SizedBox(height: 16),

        // Navigation Bar Style Playground Card
        _buildBottomBarConfigCard(),
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

        // Squiggly Wave Slider for Music (NixWaveSlider)
        NixCard(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Icon(
                      Icons.graphic_eq_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Squiggly Wave Slider (Music Player)',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Active squiggly wave • Sleek pill thumb • Rounded ends',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  NixIconButton.filled(
                    size: NixSize.medium,
                    icon: Icon(
                      _isMusicPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    tooltip: _isMusicPlaying ? 'Pause' : 'Play',
                    onPressed: () =>
                        setState(() => _isMusicPlaying = !_isMusicPlaying),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              NixWaveSlider.music(
                value: _musicPlaybackSeconds,
                max: _musicTotalSeconds,
                isPlaying: _isMusicPlaying,
                onChanged: (val) => setState(() => _musicPlaybackSeconds = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Segmented Switch Tiles (NixSwitchList & NixSwitchTile)
        Text(
          'Segmented Switch Tiles',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        NixSwitchList(
          padding: EdgeInsets.zero,
          children: [
            NixSwitchTile(
              leading: const Icon(Icons.wifi_rounded),
              title: const Text('Wi-Fi Network'),
              subtitle: const Text('Connected to NixDesign-5G'),
              value: _wifiEnabled,
              onChanged: (val) => setState(() => _wifiEnabled = val),
            ),
            NixSwitchTile(
              leading: const Icon(Icons.bluetooth_rounded),
              title: const Text('Bluetooth'),
              subtitle: const Text('2 paired devices active'),
              value: _bluetoothEnabled,
              onChanged: (val) => setState(() => _bluetoothEnabled = val),
            ),
            NixSwitchTile(
              leading: const Icon(Icons.airplanemode_active_rounded),
              title: const Text('Airplane Mode'),
              subtitle: const Text('Disable all radio signals'),
              value: _airplaneMode,
              onChanged: (val) => setState(() => _airplaneMode = val),
            ),
            NixSwitchTile(
              leading: const Icon(Icons.notifications_active_rounded),
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive alerts and activity updates'),
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Single Switch Tile with Pilled Corners
        Text(
          'Single Switch Tile (Pilled Corner Radius)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        NixSwitchTile(
          leading: const Icon(Icons.bolt_rounded),
          title: const Text('Fast Charging'),
          value: _standaloneSwitch,
          onChanged: (val) => setState(() => _standaloneSwitch = val),
        ),
        const SizedBox(height: 16),

        // App Update Expandable (NixExpandable.update)
        Text(
          'App Update Expandable (NixExpandable.update)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        NixExpandable.update(
          version: '2.5.0',
          currentVersion: '2.4.2',
          buildNumber: '148',
          releaseDate: 'Nov 11, 2026',
          fileSize: '42.5 MB',
          badgeText: 'RECOMMENDED',
          fixes: const [
            'NixSwitchTile: Segmented switch tiles with pilled corner radius when single',
            'NixExpandable: Expandable switch tiles with smooth height disclosure',
            'NixExpandable.update(): App update card with version, fixes & custom widgets',
            'Dynamic navigation bar child-adaptive width and bottom-right action button',
          ],
          autoUpdate: _autoUpdateEnabled,
          onAutoUpdateChanged: (val) =>
              setState(() => _autoUpdateEnabled = val),
          isUpdating: _isUpdatingApp,
          progress: _updateProgress,
          onUpdate: () async {
            setState(() {
              _isUpdatingApp = true;
              _updateProgress = 0.0;
            });
            for (int i = 1; i <= 10; i++) {
              await Future.delayed(const Duration(milliseconds: 150));
              if (mounted) {
                setState(() => _updateProgress = i / 10);
              }
            }
            if (mounted) {
              setState(() {
                _isUpdatingApp = false;
                _updateProgress = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App updated to v2.5.0 successfully!'),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Arbitrary custom widget: Package integrity verified with SHA-256 cryptographic signature.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              NixButton.outlined(
                onPressed: _openVersionHistorySheet,
                label: const Text('View All Releases (v1 to v9 Sheet)'),
                icon: const Icon(Icons.history_rounded, size: 16),
                size: NixSize.small,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Native Bottom Sheet Showcase (Versions 1 to 9 with Single/Multi Expand)
        NixCard(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_edu_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Native Sheet: Releases v1 to v9',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Flutter native sheet with NixExpandable & Single/Multi toggles',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              NixButton.tonal(
                onPressed: _openVersionHistorySheet,
                label: const Text('Open Native Sheet (Versions 1 to 9)'),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                isExpanded: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Expandable Switch Tile (NixExpandable.switchTile)
        Text(
          'Expandable Switch Tile (NixExpandable.switchTile)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        NixExpandable.switchTile(
          leading: const Icon(Icons.vpn_lock_rounded),
          title: const Text('Nix Secure VPN'),
          subtitle: const Text('Turn on to reveal encrypted tunnel details'),
          switchValue: _vpnExpandedTile,
          expandOnSwitch: true,
          onSwitchChanged: (val) => setState(() => _vpnExpandedTile = val),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected Server: Frankfurt 04 (Ultra-Low Latency)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  'Protocol: WireGuard • Port: 51820 • Cipher: ChaCha20-Poly1305',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
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

        // Swipe Mode & Direction Controls
        NixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mode:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  NixFilterChip(
                    label: const Text('Action Buttons'),
                    selected: _swipeMode == NixSwipeMode.actions,
                    avatar: const Icon(Icons.touch_app_rounded, size: 14),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _swipeMode = NixSwipeMode.actions);
                      }
                    },
                  ),
                  NixFilterChip(
                    label: const Text('Gmail Preset'),
                    selected: _swipeMode == NixSwipeMode.dismiss,
                    avatar: const Icon(Icons.swipe_rounded, size: 14),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _swipeMode = NixSwipeMode.dismiss);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Direction:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Wrap(
                spacing: 6,
                children:
                    [
                      NixSwipeDirection.both,
                      NixSwipeDirection.rightOnly,
                      NixSwipeDirection.leftOnly,
                      NixSwipeDirection.disabled,
                    ].map((dir) {
                      final label = switch (dir) {
                        NixSwipeDirection.both => 'Both',
                        NixSwipeDirection.rightOnly => 'RightOnly',
                        NixSwipeDirection.leftOnly => 'LeftOnly',
                        NixSwipeDirection.disabled => 'Disabled',
                      };
                      return NixFilterChip(
                        label: Text(label),
                        selected: _swipeDirection == dir,
                        onSelected: (val) {
                          if (val) setState(() => _swipeDirection = dir);
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 6),
              Text(
                'Reorder Trigger:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Wrap(
                spacing: 6,
                children:
                    [
                      NixReorderTrigger.both,
                      NixReorderTrigger.handleOnly,
                      NixReorderTrigger.wholeItem,
                      NixReorderTrigger.disabled,
                    ].map((trig) {
                      final label = switch (trig) {
                        NixReorderTrigger.both => 'Both',
                        NixReorderTrigger.handleOnly => 'HandleOnly',
                        NixReorderTrigger.wholeItem => 'WholeItem',
                        NixReorderTrigger.disabled => 'Disabled',
                      };
                      return NixFilterChip(
                        label: Text(label),
                        selected: _reorderTrigger == trig,
                        onSelected: (val) {
                          if (val) setState(() => _reorderTrigger = trig);
                        },
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

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
          swipeMode: _swipeMode,
          swipeDirection: _swipeDirection,
          selectionMode: _isSelectionMode
              ? NixSelectionMode.multi
              : NixSelectionMode.none,
          selectedIndices: _selectedTrackIndices,
          reorderTrigger: _reorderTrigger,
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

            if (_swipeMode == NixSwipeMode.actions) {
              return NixListItem(
                key: ValueKey(track['title']!),
                isPlaying: isPlayingThis,
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
                swipeMode: NixSwipeMode.actions,
                primaryActions: [
                  NixSwipeAction.share(
                    onTriggered: () {
                      NixSnackBar.show(
                        context,
                        message: 'Shared "${track['title']}"',
                      );
                    },
                  ),
                  NixSwipeAction.archive(
                    onTriggered: () {
                      NixSnackBar.show(
                        context,
                        message: 'Archived "${track['title']}"',
                      );
                    },
                  ),
                ],
                secondaryActions: [
                  NixSwipeAction.collaborator(
                    onTriggered: () {
                      NixSnackBar.show(
                        context,
                        message: 'Added collaborator to "${track['title']}"',
                      );
                    },
                  ),
                  NixSwipeAction.edit(
                    onTriggered: () {
                      NixSnackBar.show(
                        context,
                        message: 'Editing "${track['title']}"',
                      );
                    },
                  ),
                ],
                onTap: () {
                  if (!_isSelectionMode) {
                    setState(() {
                      _playingTrackIndex = isPlayingThis ? null : index;
                    });
                  }
                },
              );
            }

            // Gmail Style UI Preset (Full Swipe-to-Dismiss)
            return NixListItem.gmailStyle(
              key: ValueKey(track['title']!),
              isPlaying: isPlayingThis,
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
              onSwipeRight: () {
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
                  message: 'Archived "${track['title']}"',
                );
              },
              onSwipeLeft: () {
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

  Widget _buildBottomBarConfigCard() {
    final theme = Theme.of(context);
    return NixCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.dock_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NixBottomBar Playground',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toggle standard vs separated style with dynamic items',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Bar Layout Style:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          NixSegmentedControl<NixBottomBarStyle>(
            value: _bottomBarStyle,
            onChanged: (val) => setState(() => _bottomBarStyle = val),
            items: const [
              NixSegment(value: NixBottomBarStyle.standard, label: 'Standard'),
              NixSegment(
                value: NixBottomBarStyle.separated,
                label: 'Separated',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Item Content Type (Dynamic Width):',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              NixFilterChip(
                label: const Text('Icon & Text'),
                selected: _navBarContentType == 'icon_text',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _navBarContentType = 'icon_text');
                  }
                },
              ),
              const SizedBox(width: 8),
              NixFilterChip(
                label: const Text('Icon Only'),
                selected: _navBarContentType == 'icon_only',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _navBarContentType = 'icon_only');
                  }
                },
              ),
              const SizedBox(width: 8),
              NixFilterChip(
                label: const Text('Text Only'),
                selected: _navBarContentType == 'text_only',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _navBarContentType = 'text_only');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Navigation Items Count (Dynamic Width):',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final count in [2, 3, 4])
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: NixFilterChip(
                    label: Text('$count Items'),
                    selected: _navBarItemCount == count,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _navBarItemCount = count;
                          if (_navIndex >= count) _navIndex = 0;
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Action Button Position:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              NixFilterChip(
                label: const Text('Bottom Right'),
                selected: _barActionPosition == NixBarActionPosition.right,
                onSelected: (selected) {
                  if (selected) {
                    setState(
                      () => _barActionPosition = NixBarActionPosition.right,
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              NixFilterChip(
                label: const Text('Bottom Left'),
                selected: _barActionPosition == NixBarActionPosition.left,
                onSelected: (selected) {
                  if (selected) {
                    setState(
                      () => _barActionPosition = NixBarActionPosition.left,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          NixSwitchTile(
            title: const Text('Shrink Bar on Scroll'),
            subtitle: const Text(
              'Smoothly compress scale & margins when scrolling down (can be disabled)',
            ),
            value: _enableNavBarShrink,
            onChanged: (val) => setState(() => _enableNavBarShrink = val),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _bottomBarStyle == NixBottomBarStyle.separated
                        ? 'Separated style active: Bar width dynamically adapts to its child items (icon/text, icon only, text only) at BottomLeft with generous touch targets, while the action button floats at BottomRight.'
                        : 'Standard style active: Bar width dynamically adapts to its child items (icon/text, icon only, text only) as default, clustered in the center with the action button.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      name: 'NixSwitchTile',
      category: 'Widgets',
      tabIndex: 1,
      icon: Icons.splitscreen_rounded,
      desc: 'Segmented switch list tiles with 16px container and native ink splash',
    ),
    (
      name: 'NixWaveSlider',
      category: 'Widgets',
      tabIndex: 1,
      icon: Icons.graphic_eq_rounded,
      desc: 'Squiggly wave music scrubber, active wave, sleek pill thumb & rounded ends',
    ),
    (
      name: 'NixExpandable',
      category: 'Widgets',
      tabIndex: 1,
      icon: Icons.unfold_more_rounded,
      desc: 'Expandable surfaces, app update cards, and single/multi expand',
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
      name: 'Dynamic Corner Morphs',
      category: 'Lists',
      tabIndex: 2,
      icon: Icons.rounded_corner_rounded,
      desc: 'Dynamic segmented corner morphing & neighbor sealing',
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

// -----------------------------------------------------------------------------
// VERSION HISTORY BOTTOM SHEET (VERSIONS 1 TO 9)
// -----------------------------------------------------------------------------
class _NixVersionHistorySheet extends StatefulWidget {
  const _NixVersionHistorySheet();

  @override
  State<_NixVersionHistorySheet> createState() =>
      _NixVersionHistorySheetState();
}

class _NixVersionHistorySheetState extends State<_NixVersionHistorySheet> {
  bool _multiExpand = false;
  Set<int> _expandedIndices = {0}; // Version 9 open initially

  final List<
    ({
      String version,
      String title,
      String? badge,
      String releaseDate,
      String buildNumber,
      String fileSize,
      List<String> fixes,
    })
  >
  _versions = const [
    (
      version: '9.0.0',
      title: 'Nix Design System 9.0',
      badge: 'LATEST',
      releaseDate: 'Nov 11, 2026',
      buildNumber: '940',
      fileSize: '48.2 MB',
      fixes: [
        'NixExpandable: Native expandable surfaces with zero shape distortion',
        'NixSwitchTile: Segmented switch tiles with pilled corner radius when single',
        'Dual expansion modes: Single accordion and multi-expand disclosure',
      ],
    ),
    (
      version: '8.0.0',
      title: 'Navigation Architecture',
      badge: 'STABLE',
      releaseDate: 'Oct 28, 2026',
      buildNumber: '812',
      fileSize: '45.1 MB',
      fixes: [
        'NixBottomBar: Separated floating action button with dynamic alignment',
        'Adaptive child sizing for icon-only, text-only, and combined layouts',
        'Interactive bottom bar playground configuration panel',
      ],
    ),
    (
      version: '7.0.0',
      title: 'List Physics & Gestures',
      badge: null,
      releaseDate: 'Oct 14, 2026',
      buildNumber: '730',
      fileSize: '41.8 MB',
      fixes: [
        'Gmail-style full-swipe action gestures with responsive icon springs',
        'Dual trigger modes: action buttons and dismiss thresholds',
        'Native InkWell ripple splash support across all list items',
      ],
    ),
    (
      version: '6.0.0',
      title: 'Segmented Corner Morphs',
      badge: 'LTS',
      releaseDate: 'Sep 29, 2026',
      buildNumber: '625',
      fileSize: '38.4 MB',
      fixes: [
        'Dynamic segmented corner morphing for multi-item selection groups',
        'Neighbor item sealing when playing audio tracks',
        'Custom drag handles and whole-item long-press reorder triggers',
      ],
    ),
    (
      version: '5.0.0',
      title: 'Popup Menu System',
      badge: null,
      releaseDate: 'Sep 12, 2026',
      buildNumber: '518',
      fileSize: '35.0 MB',
      fixes: [
        'Dual-gesture popup menu with hold-drag-release & tap trigger modes',
        'Universal item support: icons, chips, and custom widgets',
        'Imperative showNixPopupMenu API with future return values',
      ],
    ),
    (
      version: '4.0.0',
      title: 'Feedback & Snackbars',
      badge: null,
      releaseDate: 'Aug 24, 2026',
      buildNumber: '410',
      fileSize: '32.6 MB',
      fixes: [
        'Top and bottom floating pill snackbars with slide transitions',
        'Automatic queue management and dismiss-on-swipe gestures',
        'Safe area padding adaptation above bottom navigation bars',
      ],
    ),
    (
      version: '3.0.0',
      title: 'Buttons & Shape Morphing',
      badge: null,
      releaseDate: 'Aug 05, 2026',
      buildNumber: '315',
      fileSize: '29.2 MB',
      fixes: [
        'NixButton Material 3 Expressive shape morphing on press and hover',
        'Expanded button layout support with unconstrained width safety',
        'Pill-squircle dynamic interpolation for tactile feedback',
      ],
    ),
    (
      version: '2.0.0',
      title: 'Inputs & Form Controls',
      badge: null,
      releaseDate: 'Jul 18, 2026',
      buildNumber: '208',
      fileSize: '26.5 MB',
      fixes: [
        'Segmented control with animated sliding pill thumb indicator',
        'Stadium filter chips with checkmark toggle transitions',
        'Accessible 48x48 tap target NixSwitch with animated track',
      ],
    ),
    (
      version: '1.0.0',
      title: 'Initial System Foundation',
      badge: 'INITIAL',
      releaseDate: 'Jun 30, 2026',
      buildNumber: '100',
      fileSize: '22.0 MB',
      fixes: [
        'Initial public release of the Nix Design System',
        'Theme-reactive architecture adhering to host app ColorScheme',
        'Signature pill geometry tokens (NixGeometry and NixSize)',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainer,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              // Drag handle pill
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: colors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Version History',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Releases 1 to 9 • Software Changelog',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    NixIconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.5),

              // Single vs Multi Expand Toggle Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _multiExpand
                                ? Icons.view_stream_rounded
                                : Icons.unfold_more_rounded,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _multiExpand ? 'Multi Expand' : 'Single Expand',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: NixSegmentedControl<bool>(
                        value: _multiExpand,
                        onChanged: (val) {
                          setState(() {
                            _multiExpand = val;
                            if (!_multiExpand && _expandedIndices.length > 1) {
                              final first = _expandedIndices.first;
                              _expandedIndices = {first};
                            }
                          });
                        },
                        items: const [
                          NixSegment(value: false, label: 'Single'),
                          NixSegment(value: true, label: 'Multi'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Helper actions in Multi Expand mode
              if (_multiExpand)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      NixButton.ghost(
                        size: NixSize.small,
                        label: const Text('Expand All'),
                        onPressed: () {
                          setState(() {
                            _expandedIndices = Set.from(
                              List.generate(_versions.length, (i) => i),
                            );
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      NixButton.ghost(
                        size: NixSize.small,
                        label: const Text('Collapse All'),
                        onPressed: () {
                          setState(() {
                            _expandedIndices = {};
                          });
                        },
                      ),
                    ],
                  ),
                ),

              // Expandable Versions List (Version 1 to 9)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
                  itemCount: _versions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _versions[index];
                    final isExpanded = _expandedIndices.contains(index);

                    return NixExpandable.update(
                      key: ValueKey('version_${item.version}'),
                      version: item.version,
                      titleText: item.title,
                      subtitleText:
                          '${item.releaseDate} • Build ${item.buildNumber} • ${item.fileSize}',
                      badgeText: item.badge,
                      fixes: item.fixes,
                      expanded: isExpanded,
                      onExpansionChanged: (nextState) {
                        setState(() {
                          if (_multiExpand) {
                            if (nextState) {
                              _expandedIndices.add(index);
                            } else {
                              _expandedIndices.remove(index);
                            }
                          } else {
                            if (nextState) {
                              _expandedIndices = {index};
                            } else {
                              _expandedIndices.remove(index);
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
