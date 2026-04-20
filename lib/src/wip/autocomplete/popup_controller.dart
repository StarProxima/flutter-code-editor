import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../autocomplete/suggestion.dart';

class PopupController extends ChangeNotifier {
  List<Suggestion> _items = const [];
  int _selectedIndex = 0;
  bool shouldShow = false;
  bool enabled = true;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  /// Should be called when an active list item is selected to be inserted into the text
  late final void Function() onCompletionSelected;

  PopupController({required this.onCompletionSelected}) : super();

  /// Currently shown rich suggestions.
  List<Suggestion> get items => _items;

  /// Convenience view returning just the labels of [items].
  ///
  /// Retained for backward compatibility with popup widgets that were built
  /// against the original `List<String>` contract. New code should render
  /// directly from [items] to have access to detail, documentation, and
  /// type metadata.
  List<String> get suggestions =>
      _items.map((e) => e.label).toList(growable: false);

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  int get selectedIndex => _selectedIndex;

  /// Displays rich [Suggestion]s in the popup.
  ///
  /// Resets the selected index and scrolls the list to the top.
  void showItems(List<Suggestion> items) {
    if (!enabled) {
      return;
    }

    _items = items;
    _selectedIndex = 0;
    shouldShow = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (itemScrollController.isAttached) {
        itemScrollController.jumpTo(index: 0);
      }
    });
    notifyListeners();
  }

  /// Displays plain string suggestions. Each string becomes a text-typed
  /// [Suggestion]. Preserved for backward compatibility; prefer [showItems].
  void show(List<String> suggestions) {
    showItems(
      suggestions
          .map((w) => Suggestion(label: w, type: SuggestionType.text))
          .toList(growable: false),
    );
  }

  void hide() {
    shouldShow = false;
    notifyListeners();
  }

  /// Changes the selected item and scrolls through the list of completions on keyboard arrows pressed
  void scrollByArrow(ScrollDirection direction) {
    if (_items.isEmpty) {
      return;
    }
    final previousSelectedIndex = selectedIndex;
    if (direction == ScrollDirection.up) {
      selectedIndex = (selectedIndex - 1 + _items.length) % _items.length;
    } else {
      selectedIndex = (selectedIndex + 1) % _items.length;
    }
    final visiblePositions = itemPositionsListener.itemPositions.value
        .where((item) {
          final bool isTopVisible = item.itemLeadingEdge >= 0;
          final bool isBottomVisible = item.itemTrailingEdge <= 1;
          return isTopVisible && isBottomVisible;
        })
        .map((e) => e.index)
        .toList();

    // List offset will be changed only if new selected item is not visible
    if (!visiblePositions.contains(selectedIndex)) {
      // If previously selected item was at the bottom of the visible part of the list,
      // on 'down' arrow the new one will appear at the bottom as well
      final isStepDown = selectedIndex - previousSelectedIndex == 1;
      if (isStepDown && selectedIndex < _items.length - 1) {
        itemScrollController.jumpTo(index: selectedIndex + 1, alignment: 1);
      } else {
        itemScrollController.jumpTo(index: selectedIndex);
      }
    }
    notifyListeners();
  }

  /// Label of the currently selected suggestion. Retained for callers that
  /// worked with the original string-only API.
  String getSelectedWord() => _items[_selectedIndex].label;

  /// The currently selected rich suggestion. Callers can use [Suggestion.insertText]
  /// to honor the intended insertion payload (which may differ from the label).
  Suggestion getSelectedItem() => _items[_selectedIndex];
}

/// Possible directions of completions list navigation
enum ScrollDirection {
  up,
  down,
}
