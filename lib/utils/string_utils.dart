/// Normalise un texte en supprimant les accents et en le convertissant en minuscules.
/// Utile pour les recherches insensibles aux accents.
String normalizeText(String text) {
  if (text == null) return '';
  var normalized = text.toLowerCase();

  const mapping = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ÿ': 'y', 'ñ': 'n', 'ç': 'c',
  };

  mapping.forEach((accent, nonAccent) {
    normalized = normalized.replaceAll(accent, nonAccent);
  });

  return normalized;
}
