import 'package:flutter_code_editor/src/autocomplete/suggestion.dart';
import 'package:flutter_code_editor/src/wip/autocomplete/popup_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PopupController', () {
    late PopupController controller;

    setUp(() {
      controller = PopupController(onCompletionSelected: () {});
    });

    group('showItems (rich API)', () {
      test('populates items and turns shouldShow on', () {
        const items = <Suggestion>[
          Suggestion(label: 'apple', type: SuggestionType.field),
          Suggestion(label: 'banana', type: SuggestionType.enumValue),
        ];

        controller.showItems(items);

        expect(controller.items, items);
        expect(controller.shouldShow, isTrue);
        expect(controller.selectedIndex, 0);
      });

      test('derives suggestions getter from items labels', () {
        controller.showItems(const [
          Suggestion(label: 'apple'),
          Suggestion(label: 'banana'),
        ]);

        expect(controller.suggestions, ['apple', 'banana']);
      });

      test('getSelectedItem returns the Suggestion at selectedIndex', () {
        const items = <Suggestion>[
          Suggestion(label: 'a'),
          Suggestion(label: 'b', detail: 'extra'),
        ];
        controller.showItems(items);
        controller.selectedIndex = 1;

        expect(controller.getSelectedItem(), items[1]);
        expect(controller.getSelectedWord(), 'b');
      });

      test('is a no-op while disabled', () {
        controller.enabled = false;

        controller.showItems(const [Suggestion(label: 'a')]);

        expect(controller.shouldShow, isFalse);
      });

      test(
        'a second showItems resets selectedIndex and replaces the list',
        () {
          controller.showItems(const [
            Suggestion(label: 'a'),
            Suggestion(label: 'b'),
            Suggestion(label: 'c'),
          ]);
          controller.selectedIndex = 2;

          controller.showItems(const [Suggestion(label: 'x')]);

          expect(controller.items.single, const Suggestion(label: 'x'));
          expect(controller.selectedIndex, 0);
          expect(controller.shouldShow, isTrue);
        },
      );
    });

    group('show(List<String>) backward compatibility', () {
      test(
        'wraps plain strings into text-typed Suggestion items',
        () {
          controller.show(['foo', 'bar']);

          expect(controller.items.length, 2);
          expect(controller.items.first, const Suggestion(label: 'foo'));
          expect(
            controller.items.every((e) => e.type == SuggestionType.text),
            isTrue,
          );
          expect(controller.suggestions, ['foo', 'bar']);
          expect(controller.shouldShow, isTrue);
        },
      );

      test('empty list is accepted (controller still shows)', () {
        controller.show(<String>[]);

        expect(controller.items, isEmpty);
        expect(controller.shouldShow, isTrue);
      });
    });

    group('hide', () {
      test('turns shouldShow off', () {
        controller.showItems(const [Suggestion(label: 'x')]);
        controller.hide();

        expect(controller.shouldShow, isFalse);
      });
    });

    // Note: scrollByArrow exercises ItemScrollController.jumpTo which relies
    // on an attached ScrollablePositionedList. Covering it meaningfully
    // requires a widget test with a real popup rendered; out of scope here.
    // The guard added below (items.isEmpty early return) is still worth
    // a minimal check.
    group('scrollByArrow', () {
      test('is a no-op on an empty popup', () {
        controller.scrollByArrow(ScrollDirection.up);
        controller.scrollByArrow(ScrollDirection.down);

        expect(controller.items, isEmpty);
        expect(controller.selectedIndex, 0);
      });
    });
  });
}
