import 'dart:async';

import 'suggestion.dart';
import 'suggestion_request.dart';

/// Source of completion candidates for a CodeController.
///
/// Implementations are free to combine in-buffer words, language keywords,
/// LSP responses, schema-driven field catalogs, or any other origin. The
/// controller queries the provider on every autocompletion cycle and passes
/// the resulting [Suggestion]s to the popup without re-sorting - the
/// provider is the source of truth for ordering.
abstract class SuggestionProvider {
  /// Returns suggestions matching the current editor state.
  ///
  /// Both synchronous and asynchronous returns are supported via
  /// [FutureOr]; synchronous providers should avoid allocating a [Future]
  /// so that fast paths stay off the microtask queue.
  FutureOr<List<Suggestion>> suggestionsFor(SuggestionRequest request);
}
