import 'package:flutter/foundation.dart';

import 'suggestion_provider.dart';

/// A single completion candidate returned by a [SuggestionProvider].
///
/// The class decouples the user-facing label from the text that is actually
/// inserted into the editor, and carries additional metadata that UI layers
/// can use to render icons, group items, show documentation on hover, or
/// order candidates by priority.
@immutable
class Suggestion {
  /// Text displayed to the user in the completion popup.
  final String label;

  /// Text that will be inserted into the editor when the suggestion is
  /// accepted. Defaults to [label] if not provided.
  final String insertText;

  /// Short secondary text shown next to [label], typically a type or origin
  /// hint (e.g. `String`, `enum`, `keyword`).
  final String? detail;

  /// Extended description of the suggestion. Intended for markdown rendering
  /// in a side panel or hover tooltip.
  final String? documentation;

  /// High-level classification used for grouping and iconography.
  final SuggestionType type;

  /// Higher values are surfaced earlier in the list. Ties are broken by the
  /// order in which the provider returned the suggestions.
  final int priority;

  const Suggestion({
    required this.label,
    String? insertText,
    this.detail,
    this.documentation,
    this.type = SuggestionType.text,
    this.priority = 0,
  }) : insertText = insertText ?? label;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Suggestion &&
        other.label == label &&
        other.insertText == insertText &&
        other.detail == detail &&
        other.documentation == documentation &&
        other.type == type &&
        other.priority == priority;
  }

  @override
  int get hashCode =>
      Object.hash(label, insertText, detail, documentation, type, priority);

  @override
  String toString() =>
      'Suggestion(label: $label, type: $type, priority: $priority)';
}

/// High-level category of a [Suggestion].
///
/// Implementers are free to ignore the type or assign a custom meaning to
/// [SuggestionType.custom]; UI layers use it as a hint for grouping and
/// default icons.
enum SuggestionType {
  /// A plain word pulled from the buffer or an otherwise unclassified source.
  text,

  /// A keyword of the current language mode.
  keyword,

  /// A field of a class, an object key, or a configuration property.
  field,

  /// A value of an enumeration.
  enumValue,

  /// A predefined code fragment, typically with tabstops.
  snippet,

  /// A client-specific category without built-in semantics.
  custom,
}
