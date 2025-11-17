import 'package:flutter/material.dart';

/// Widget pour afficher du texte avec coloration familiale (tertiary)
///
/// Extrait et amélioré depuis TodayTransportCard (dashboard)
/// Partagé entre Dashboard et Schedule
///
/// Les membres de la famille sont affichés en colorScheme.tertiary avec fontWeight.w600
/// Les non-membres utilisent colorScheme.onSurfaceVariant avec fontWeight.normal
///
/// Correspond exactement au style des mockups validés !
///
/// Usage:
/// ```dart
/// // Simple text
/// FamilyColoredText(
///   text: 'Alice Dubois',
///   isFamilyMember: true,
/// )
///
/// // Avec bullet
/// FamilyColoredText(
///   text: 'Thomas Dubois',
///   isFamilyMember: true,
///   showBullet: true,
/// )
///
/// // Avec badge étoile
/// FamilyColoredText(
///   text: 'Maxime Dubois',
///   isFamilyMember: true,
///   showStarBadge: true,
/// )
///
/// // Liste d'enfants (mockup style)
/// Wrap(
///   children: children.map((child) => FamilyColoredText(
///     text: child.name,
///     isFamilyMember: child.isFamilyChild,
///     showBullet: true,
///   )).toList(),
/// )
/// ```
class FamilyColoredText extends StatelessWidget {
  /// Texte à afficher
  final String text;

  /// Est-ce un membre de la famille ?
  final bool isFamilyMember;

  /// Style de base (sera enrichi avec les couleurs familiales)
  final TextStyle? baseStyle;

  /// Afficher bullet "•" avant le texte
  final bool showBullet;

  /// Afficher badge étoile après le texte (style mockup)
  final bool showStarBadge;

  const FamilyColoredText({
    Key? key,
    required this.text,
    required this.isFamilyMember,
    this.baseStyle,
    this.showBullet = false,
    this.showStarBadge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = _getEffectiveStyle(context);

    // Simple text sans bullet ni badge
    if (!showBullet && !showStarBadge) {
      return Text(text, style: effectiveStyle);
    }

    // RichText avec bullet et/ou badge
    return RichText(
      text: TextSpan(
        children: [
          if (showBullet)
            TextSpan(
              text: '• ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          TextSpan(text: text, style: effectiveStyle),
          if (showStarBadge && isFamilyMember)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.star,
                  size: 10,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  TextStyle _getEffectiveStyle(BuildContext context) {
    return (baseStyle ?? Theme.of(context).textTheme.bodySmall)!.copyWith(
      color: isFamilyMember
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: isFamilyMember ? FontWeight.w600 : FontWeight.normal,
    );
  }
}

/// Widget pour afficher une liste d'enfants avec coloration familiale dans des chips
/// Style mockup: petites cards avec background tertiaryContainer pour famille
class FamilyChildrenChips extends StatelessWidget {
  /// Liste des noms d'enfants
  final List<String> childrenNames;

  /// Liste des flags isFamilyChild (même taille que childrenNames)
  final List<bool> isFamilyFlags;

  /// Mode compact pour mobile
  final bool compact;

  const FamilyChildrenChips({
    Key? key,
    required this.childrenNames,
    required this.isFamilyFlags,
    this.compact = false,
  }) : assert(childrenNames.length == isFamilyFlags.length),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 6 : 8,
      runSpacing: compact ? 4 : 6,
      children: List.generate(childrenNames.length, (index) {
        final name = childrenNames[index];
        final isFamilyChild = isFamilyFlags[index];

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 4 : 6,
            vertical: compact ? 2 : 3,
          ),
          decoration: BoxDecoration(
            color: isFamilyChild
                ? Theme.of(context).colorScheme.tertiaryContainer
                : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(compact ? 6 : 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isFamilyChild
                      ? Theme.of(context).colorScheme.onTertiaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: compact ? 10 : 11,
                  fontWeight: isFamilyChild
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              if (isFamilyChild) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.star,
                  size: compact ? 8 : 10,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

/// Extension pour créer facilement des TextSpan avec coloration familiale
/// Utilisé pour RichText complexes dans le dashboard
extension FamilyTextSpanExtension on String {
  TextSpan toFamilyTextSpan(
    BuildContext context, {
    required bool isFamilyMember,
    TextStyle? baseStyle,
  }) {
    return TextSpan(
      text: this,
      style: (baseStyle ?? Theme.of(context).textTheme.bodySmall)?.copyWith(
        color: isFamilyMember
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isFamilyMember ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
