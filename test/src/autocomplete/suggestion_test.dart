import 'package:flutter_code_editor/src/autocomplete/suggestion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Suggestion', () {
    test('defaults: insertText == label, type text, priority 0', () {
      const suggestion = Suggestion(label: 'foo');

      expect(suggestion.label, 'foo');
      expect(suggestion.insertText, 'foo');
      expect(suggestion.detail, isNull);
      expect(suggestion.documentation, isNull);
      expect(suggestion.type, SuggestionType.text);
      expect(suggestion.priority, 0);
    });

    test('insertText overrides label for the inserted value', () {
      const suggestion = Suggestion(label: '=>', insertText: ' => ');

      expect(suggestion.label, '=>');
      expect(suggestion.insertText, ' => ');
    });

    test('carries optional detail and documentation verbatim', () {
      const suggestion = Suggestion(
        label: 'title',
        detail: 'String',
        documentation: 'Headline shown to the user.',
        type: SuggestionType.field,
        priority: 10,
      );

      expect(suggestion.detail, 'String');
      expect(suggestion.documentation, 'Headline shown to the user.');
      expect(suggestion.type, SuggestionType.field);
      expect(suggestion.priority, 10);
    });

    test('equality considers all fields', () {
      const a = Suggestion(label: 'foo');
      const b = Suggestion(label: 'foo');
      const c = Suggestion(label: 'foo', detail: 'bar');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('equality distinguishes different types and priorities', () {
      const base = Suggestion(label: 'foo');
      const withType = Suggestion(label: 'foo', type: SuggestionType.keyword);
      const withPriority = Suggestion(label: 'foo', priority: 1);

      expect(base, isNot(equals(withType)));
      expect(base, isNot(equals(withPriority)));
      expect(withType, isNot(equals(withPriority)));
    });

    test('SuggestionType exposes expected variants', () {
      expect(
        SuggestionType.values,
        containsAll(<SuggestionType>[
          SuggestionType.text,
          SuggestionType.keyword,
          SuggestionType.field,
          SuggestionType.enumValue,
          SuggestionType.snippet,
          SuggestionType.custom,
        ]),
      );
    });
  });
}
