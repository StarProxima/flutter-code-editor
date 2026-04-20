import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/autocomplete/suggestion.dart';
import 'package:flutter_code_editor/src/autocomplete/suggestion_provider.dart';
import 'package:flutter_code_editor/src/autocomplete/suggestion_request.dart';
import 'package:flutter_code_editor/src/code_field/code_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test double that records every request it received and returns a fixed
/// list of suggestions for inspection.
class _RecordingProvider implements SuggestionProvider {
  final List<Suggestion> toReturn;
  final List<SuggestionRequest> received = [];

  _RecordingProvider(this.toReturn);

  @override
  Future<List<Suggestion>> suggestionsFor(SuggestionRequest request) async {
    received.add(request);
    return toReturn;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CodeController.suggestionProvider', () {
    test(
      'defaults to wrapping the built-in Autocompleter - popup shows '
      'custom words added via setCustomWords',
      () async {
        final controller = CodeController(text: '');
        controller.autocompleter.setCustomWords(['apple', 'apricot']);

        // Simulate user typing a prefix and invoking suggestions.
        controller.value = const TextEditingValue(
          text: 'a',
          selection: TextSelection.collapsed(offset: 1),
        );
        await controller.generateSuggestions();

        expect(controller.popupController.suggestions,
            containsAll(['apple', 'apricot']),);
      },
    );

    test('custom provider replaces the default source', () async {
      const custom = [
        Suggestion(
          label: 'title',
          detail: 'String',
          type: SuggestionType.field,
        ),
        Suggestion(
          label: 'platform_is',
          type: SuggestionType.field,
          priority: 5,
        ),
      ];
      final provider = _RecordingProvider(custom);
      final controller = CodeController(
        text: '',
        suggestionProvider: provider,
      );

      controller.value = const TextEditingValue(
        text: 'p',
        selection: TextSelection.collapsed(offset: 1),
      );
      await controller.generateSuggestions();

      expect(controller.popupController.items, custom);
      expect(controller.popupController.suggestions,
          ['title', 'platform_is'],);
      // The controller may also fire generateSuggestions via its change
      // listener, so we assert the request was made at least once with the
      // expected editor state rather than pinning down a specific count.
      expect(provider.received, isNotEmpty);
      final last = provider.received.last;
      expect(last.prefix, 'p');
      expect(last.offset, 1);
      expect(last.text, 'p');
    });

    test('provider is replaceable via the public setter', () async {
      final controller = CodeController(text: '');
      final replacement = _RecordingProvider(const [
        Suggestion(label: 'zzz', type: SuggestionType.custom),
      ]);

      controller.suggestionProvider = replacement;
      controller.value = const TextEditingValue(
        text: 'z',
        selection: TextSelection.collapsed(offset: 1),
      );
      await controller.generateSuggestions();

      expect(controller.popupController.items.single.label, 'zzz');
      expect(controller.popupController.items.single.type,
          SuggestionType.custom,);
      expect(replacement.received, isNotEmpty);
    });

    test('empty suggestion list hides the popup', () async {
      final provider = _RecordingProvider(const <Suggestion>[]);
      final controller = CodeController(
        text: '',
        suggestionProvider: provider,
      );

      controller.value = const TextEditingValue(
        text: 'q',
        selection: TextSelection.collapsed(offset: 1),
      );
      await controller.generateSuggestions();

      expect(controller.popupController.shouldShow, isFalse);
    });
  });
}
