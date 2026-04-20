import 'package:flutter_code_editor/src/autocomplete/suggestion_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/dart.dart';

void main() {
  group('SuggestionRequest', () {
    test('stores text, offset, prefix, language', () {
      final request = SuggestionRequest(
        text: 'int foo = 0;',
        offset: 5,
        prefix: 'f',
        language: dart,
      );

      expect(request.text, 'int foo = 0;');
      expect(request.offset, 5);
      expect(request.prefix, 'f');
      expect(request.language, dart);
    });

    test('language defaults to null', () {
      const request = SuggestionRequest(
        text: 'abc',
        offset: 1,
        prefix: 'a',
      );

      expect(request.language, isNull);
    });

    test('equality is by value', () {
      const a = SuggestionRequest(text: 'x', offset: 1, prefix: 'x');
      const b = SuggestionRequest(text: 'x', offset: 1, prefix: 'x');
      const c = SuggestionRequest(text: 'x', offset: 2, prefix: 'x');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });
}
