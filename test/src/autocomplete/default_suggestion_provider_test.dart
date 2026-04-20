import 'package:flutter_code_editor/src/autocomplete/autocompleter.dart';
import 'package:flutter_code_editor/src/autocomplete/default_suggestion_provider.dart';
import 'package:flutter_code_editor/src/autocomplete/suggestion.dart';
import 'package:flutter_code_editor/src/autocomplete/suggestion_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultSuggestionProvider', () {
    test('wraps Autocompleter.getSuggestions as text-typed Suggestions',
        () async {
      final ac = Autocompleter()..setCustomWords(['bar', 'baz', 'foo']);
      final provider = DefaultSuggestionProvider(ac);

      const request =
          SuggestionRequest(text: 'b', offset: 1, prefix: 'b');
      final result = await provider.suggestionsFor(request);

      expect(result.map((e) => e.label).toList(), ['bar', 'baz']);
      expect(
        result.every((e) => e.type == SuggestionType.text),
        isTrue,
      );
      expect(
        result.every((e) => e.insertText == e.label),
        isTrue,
      );
    });

    test('empty results for a prefix with no matches', () async {
      final ac = Autocompleter()..setCustomWords(['bar']);
      final provider = DefaultSuggestionProvider(ac);

      const request =
          SuggestionRequest(text: 'z', offset: 1, prefix: 'z');
      final result = await provider.suggestionsFor(request);

      expect(result, isEmpty);
    });

    test('exposes the wrapped autocompleter', () {
      final ac = Autocompleter();
      final provider = DefaultSuggestionProvider(ac);

      expect(provider.autocompleter, same(ac));
    });

    test('respects Autocompleter.blacklist', () async {
      final ac = Autocompleter()
        ..setCustomWords(['foo', 'foobar'])
        ..blacklist = ['foo'];
      final provider = DefaultSuggestionProvider(ac);

      const request = SuggestionRequest(text: 'f', offset: 1, prefix: 'f');
      final result = await provider.suggestionsFor(request);

      expect(result.map((e) => e.label), ['foobar']);
    });
  });
}
