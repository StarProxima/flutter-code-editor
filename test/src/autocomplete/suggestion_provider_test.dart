import 'package:flutter_code_editor/src/autocomplete/suggestion.dart';
import 'package:flutter_code_editor/src/autocomplete/suggestion_provider.dart';
import 'package:flutter_code_editor/src/autocomplete/suggestion_request.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal fixed provider used to lock down the contract.
class _FixedProvider implements SuggestionProvider {
  final List<Suggestion> _items;
  _FixedProvider(this._items);

  @override
  List<Suggestion> suggestionsFor(SuggestionRequest request) => _items;
}

class _AsyncProvider implements SuggestionProvider {
  final List<Suggestion> _items;
  _AsyncProvider(this._items);

  @override
  Future<List<Suggestion>> suggestionsFor(SuggestionRequest request) async =>
      _items;
}

void main() {
  group('SuggestionProvider contract', () {
    const request = SuggestionRequest(text: '', offset: 0, prefix: '');

    test('sync provider returns the same list it was built with', () async {
      const items = <Suggestion>[
        Suggestion(label: 'a', type: SuggestionType.field, priority: 2),
        Suggestion(label: 'b', type: SuggestionType.enumValue),
      ];
      final provider = _FixedProvider(items);

      final result = provider.suggestionsFor(request);

      expect(result, items);
    });

    test('async provider is awaited transparently', () async {
      const items = <Suggestion>[
        Suggestion(label: 'only'),
      ];
      final provider = _AsyncProvider(items);

      final result = await provider.suggestionsFor(request);

      expect(result, items);
    });

    test(
        'provider is the source of truth for ordering '
        '(caller is not expected to re-sort)', () async {
      const unsorted = <Suggestion>[
        Suggestion(label: 'beta'),
        Suggestion(label: 'alpha'),
        Suggestion(label: 'gamma'),
      ];
      final provider = _FixedProvider(unsorted);

      final result = provider.suggestionsFor(request);

      expect(result.map((e) => e.label).toList(), <String>[
        'beta',
        'alpha',
        'gamma',
      ]);
    });
  });
}
