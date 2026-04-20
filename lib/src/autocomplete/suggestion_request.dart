import 'package:flutter/foundation.dart';
import 'package:highlight/highlight_core.dart';

/// A snapshot of the editor state used to ask a [SuggestionProvider]
/// for completion candidates.
///
/// Instances are cheap to create: they carry only references to strings
/// owned by the caller and a numeric offset. Providers should treat a
/// request as immutable.
@immutable
class SuggestionRequest {
  /// The full text of the document at the moment the request was made.
  final String text;

  /// Caret offset inside [text], measured in UTF-16 code units.
  final int offset;

  /// The word fragment immediately before the caret.
  ///
  /// This is what the user has typed so far and what a provider is expected
  /// to match against when filtering candidates.
  final String prefix;

  /// The language [Mode] configured for the editor, if any.
  final Mode? language;

  const SuggestionRequest({
    required this.text,
    required this.offset,
    required this.prefix,
    this.language,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuggestionRequest &&
        other.text == text &&
        other.offset == offset &&
        other.prefix == prefix &&
        other.language == language;
  }

  @override
  int get hashCode => Object.hash(text, offset, prefix, language);
}
