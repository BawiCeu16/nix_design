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
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set extendBody: true when using NixBottomBar so scrollable body
      // content flows smoothly underneath the floating pill navigation bar.
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
                    'When using NixBottomBar, add "extendBody: true" to your Scaffold so that your body content extends and scrolls smoothly underneath the floating pill navigation bar (using a Stack is not recommended).',
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
        ],
      ),
      bottomNavigationBar: NixBottomBar(
        scrollController: _scrollController,
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
        onLongPress: (index) {
          final titles = ['Home', 'Widgets', 'Docs', 'Notifications'];
          final name = index < titles.length ? titles[index] : 'Item $index';
          showNixDialog<void>(
            context: context,
            builder: (ctx) => NixDialog(
              icon: const Icon(Icons.touch_app_rounded),
              title: Text('$name Options'),
              content: Text(
                'Long-pressed the "$name" item! All navigation items share dynamic equal width and support onLongPress for dialogs or popups.',
              ),
              actions: [
                NixButton.filled(
                  label: const Text('Dismiss'),
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
          NixBottomBarItem(label: 'Docs'),
          NixBottomBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications_rounded),
          ),
        ],
        action: NixIconButton.filled(
          size: NixSize.large,
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search',
          onPressed: () {
            NixSnackBar.show(
              context,
              message: 'Floating bar search action pressed!',
            );
          },
        ),
        actionPosition: NixBarActionPosition.right,
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        children: [
          // NixCard Showcase
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
          const SizedBox(height: 20),

          // NixSegmentedControl
          NixSegmentedControl<int>(
            value: _segmentedValue,
            onChanged: (val) => setState(() => _segmentedValue = val),
            items: const [
              NixSegment(value: 0, label: 'First'),
              NixSegment(value: 1, label: 'Second'),
              NixSegment(value: 2, label: 'Third'),
            ],
          ),
          const SizedBox(height: 20),

          // NixButtons
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
                icon: const Icon(Icons.star_outline_rounded),
                onPressed: () {},
              ),
              NixButton.outlined(
                label: const Text('Outlined'),
                onPressed: () {},
              ),
              NixButton.text(label: const Text('Text'), onPressed: () {}),
              NixButton.ghost(label: const Text('Ghost'), onPressed: () {}),
              NixButton(
                size: NixSize.small,
                label: const Text('Small'),
                onPressed: () {},
              ),
              NixButton(
                size: NixSize.large,
                label: const Text('Large'),
                onPressed: () {},
              ),
              const NixButton(label: Text('Disabled'), onPressed: null),
            ],
          ),
          const SizedBox(height: 20),

          // NixIconButton & NixButtonGroup
          Row(
            children: [
              NixIconButton.filled(
                icon: const Icon(Icons.thumb_up_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              NixIconButton.tonal(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              NixIconButton.outlined(
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              NixButtonGroup(
                children: [
                  NixButton.ghost(
                    size: NixSize.small,
                    label: const Text('Left'),
                    onPressed: () {},
                  ),
                  NixButton.filled(
                    size: NixSize.small,
                    label: const Text('Center'),
                    onPressed: () {},
                  ),
                  NixButton.ghost(
                    size: NixSize.small,
                    label: const Text('Right'),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // NixSwitch
          Row(
            children: [
              NixSwitch(
                value: _switchValue,
                onChanged: (val) => setState(() => _switchValue = val),
              ),
              const SizedBox(width: 12),
              Text(_switchValue ? 'Switch Enabled' : 'Switch Disabled'),
            ],
          ),
          const SizedBox(height: 20),

          // Chips
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NixFilterChip(
                label: const Text('Filter Option'),
                selected: _filterSelected,
                onSelected: (val) => setState(() => _filterSelected = val),
              ),
              NixChip(
                avatar: const Icon(Icons.person, size: 14),
                label: const Text('Nix Chip'),
                onDeleted: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),

          // NixCard
          NixCard.pill(
            onTap: () {},
            child: const Row(
              children: [
                Icon(Icons.star_rounded),
                SizedBox(width: 12),
                Expanded(child: Text('NixCard.pill')),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NixCard(
            variant: NixCardVariant.outlined,
            onTap: () {},
            child: const Text('NixCard outlined variant'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
