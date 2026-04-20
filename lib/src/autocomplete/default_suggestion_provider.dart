import 'autocompleter.dart';
import 'suggestion.dart';
import 'suggestion_provider.dart';
import 'suggestion_request.dart';

/// [SuggestionProvider] backed by the existing [Autocompleter] implementation.
///
/// Preserves the out-of-the-box behavior: keywords from the language mode,
/// words extracted from the buffer, and custom words set via
/// [Autocompleter.setCustomWords] are merged into a single flat list of
/// [SuggestionType.text] items. Callers that need richer, context-aware
/// completion should implement [SuggestionProvider] directly.
class DefaultSuggestionProvider implements SuggestionProvider {
  /// The autocompleter whose output is being wrapped.
  final Autocompleter autocompleter;

  DefaultSuggestionProvider(this.autocompleter);

  @override
  Future<List<Suggestion>> suggestionsFor(SuggestionRequest request) async {
    final words = await autocompleter.getSuggestions(request.prefix);
    return words
        .map((w) => Suggestion(label: w))
        .toList(growable: false);
  }
}
