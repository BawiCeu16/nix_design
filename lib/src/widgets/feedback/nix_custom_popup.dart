/// Custom Popup Menu for the Nix Design System.
///
/// Exports [NixPopupMenu] and [NixPopupMenuItem] with support for dual gestures
/// (tap and hold-drag-release) and dynamic segmented corner radii.
library;

export 'nix_popup_menu.dart';

import 'nix_popup_menu.dart';

/// Type alias for [NixPopupMenu] for custom popup usage.
typedef NixCustomPopup<T> = NixPopupMenu<T>;

/// Type alias for [NixPopupMenuItem] for custom popup usage.
typedef NixCustomPopupItem<T> = NixPopupMenuItem<T>;

