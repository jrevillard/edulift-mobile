// EduLift - Test Data Factory
// Generates realistic international test data with special characters

import 'dart:math';

/// Factory for generating realistic test data
class TestDataFactory {
  // Fixed seed for deterministic test data generation
  static final Random _random = Random(42);

  // Realistic international first names with special characters
  static const _firstNames = [
    // French names
    'Jean-Pierre',
    'Marie-Louise',
    'François',
    'Élise',
    'André',
    'Céline',
    'Jérôme',
    'Anaïs',
    'Benoît',
    'Zoé',
    // Spanish names
    'José',
    'María',
    'Ángel',
    'Sofía',
    'Ramón',
    'Inés',
    'Raúl',
    'Cristóbal',
    // Chinese names
    '李明',
    '王芳',
    'Zhang Wei',
    'Liu Yang',
    '陈静',
    'Wu Lei',
    // Arabic names
    'Mohammed',
    'Fatima',
    'Ahmed',
    'Aisha',
    'Hassan',
    'Layla',
    // Irish/Celtic names
    'O\'Brien',
    'Siobhán',
    'Séamus',
    'Aoife',
    'Ciarán',
    // German names
    'Müller',
    'Jürgen',
    'Björn',
    'Günther',
    // Polish names
    'Łukasz',
    'Krzysztof',
    'Zofia',
    'Józef',
    // Turkish names
    'Özdemir',
    'Çağlar',
    'Şükrü',
    // Nordic names
    'Åsa',
    'Øyvind',
    'Søren',
    // Portuguese names
    'João',
    'Gonçalo',
    'Tomás',
    // Czech names
    'Václav',
    'Jiří',
    'Božena',
  ];

  // Realistic international last names
  static const _lastNames = [
    // French names
    'Dupont-Martin',
    'De la Fontaine',
    'Saint-Germain',
    'Beaumont',
    'Lefèvre',
    // Spanish names
    'García-López',
    'Fernández',
    'Rodríguez',
    'Martínez',
    // Irish names
    'O\'Sullivan',
    'O\'Connor',
    'Mc\'Donald',
    // German names
    'Müller-Schmidt',
    'von Berg',
    'Schröder',
    // Dutch names
    'van der Berg',
    'van den Heuvel',
    // Polish names
    'Kowalski',
    'Wiśniewski',
    // Nordic names
    'Sørensen',
    'Jørgensen',
    'Ødegård',
    // Turkish names
    'Öztürk',
    'Yılmaz',
    // Chinese romanized
    'Wang',
    'Li',
    'Zhang',
    'Chen',
    // Arabic romanized
    'Al-Rashid',
    'Al-Hassan',
    'El-Amin',
  ];

  // Email domains
  static const _emailDomains = [
    'gmail.com',
    'hotmail.fr',
    'yahoo.com',
    'outlook.com',
    'icloud.com',
    'orange.fr',
    'free.fr',
    'laposte.net',
    'wanadoo.fr',
    'sfr.fr',
    'mail.com',
    'protonmail.com',
  ];

  // Street names with special characters
  static const _streetNames = [
    'Rue de la Paix',
    'Avenue des Champs-Élysées',
    'Boulevard Saint-Germain',
    'Calle de José Ortega y Gasset',
    'Straße der Märzrevolution',
    'Via dell\'Indipendenza',
    'O\'Connell Street',
    'Rúa do Paseo',
    'Plateia Syntagmatos',
  ];

  // City names with special characters
  static const _cityNames = [
    'Paris',
    'Montréal',
    'Zürich',
    'São Paulo',
    'Málaga',
    'København',
    'Kraków',
    'İstanbul',
    'Łódź',
    'Göteborg',
    'Bruxelles',
    'München',
    'Köln',
  ];

  /// Generate random first name with international characters
  static String randomFirstName() {
    return _firstNames[_random.nextInt(_firstNames.length)];
  }

  /// Generate random last name with international characters
  static String randomLastName() {
    return _lastNames[_random.nextInt(_lastNames.length)];
  }

  /// Generate random full name
  static String randomName() {
    return '${randomFirstName()} ${randomLastName()}';
  }

  /// Generate random email with realistic domain
  static String randomEmail({String? baseName}) {
    final name = baseName ?? randomName();
    final normalizedName = _normalizeForEmail(name);
    final domain = _emailDomains[_random.nextInt(_emailDomains.length)];
    final randomNumber = _random.nextInt(999);

    return '$normalizedName${randomNumber > 500 ? randomNumber : ''}@$domain';
  }

  /// Generate random phone number (French format)
  static String randomPhoneNumber() {
    final prefix = _random.nextBool() ? '06' : '07'; // Mobile prefixes
    final parts = List.generate(
      4,
      (_) => _random.nextInt(100).toString().padLeft(2, '0'),
    );
    return '$prefix ${parts.join(' ')}';
  }

  /// Generate random address
  static String randomAddress() {
    final number = _random.nextInt(200) + 1;
    final street = _streetNames[_random.nextInt(_streetNames.length)];
    final postalCode = _random.nextInt(90000) + 10000;
    final city = _cityNames[_random.nextInt(_cityNames.length)];

    return '$number $street, $postalCode $city';
  }

  /// Generate random past date
  static DateTime randomPastDate({int maxDaysAgo = 365}) {
    final daysAgo = _random.nextInt(maxDaysAgo);
    return DateTime.now().subtract(Duration(days: daysAgo));
  }

  /// Generate random future date
  static DateTime randomFutureDate({int maxDaysAhead = 365}) {
    final daysAhead = _random.nextInt(maxDaysAhead);
    return DateTime.now().add(Duration(days: daysAhead));
  }

  /// Generate random date of birth (realistic age range)
  static DateTime randomDateOfBirth({int minAge = 5, int maxAge = 18}) {
    final age = minAge + _random.nextInt(maxAge - minAge);
    final now = DateTime.now();
    return DateTime(
      now.year - age,
      _random.nextInt(12) + 1,
      _random.nextInt(28) + 1,
    );
  }

  /// Generate random time
  static String randomTime() {
    final hour = _random.nextInt(24).toString().padLeft(2, '0');
    final minute = (_random.nextInt(12) * 5).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Generate random vehicle license plate (French format)
  static String randomLicensePlate() {
    final letters1 = String.fromCharCodes(
      List.generate(2, (_) => _random.nextInt(26) + 65),
    );
    final numbers = _random.nextInt(900) + 100;
    final letters2 = String.fromCharCodes(
      List.generate(2, (_) => _random.nextInt(26) + 65),
    );
    return '$letters1-$numbers-$letters2';
  }

  /// Generate random vehicle brand
  static String randomVehicleBrand() {
    const brands = [
      'Renault',
      'Peugeot',
      'Citroën',
      'Volkswagen',
      'Mercedes-Benz',
      'BMW',
      'Audi',
      'Toyota',
      'Honda',
      'Ford',
      'Seat',
      'Škoda',
    ];
    return brands[_random.nextInt(brands.length)];
  }

  /// Generate random vehicle model
  static String randomVehicleModel() {
    const models = [
      'Clio',
      '208',
      'C3',
      'Golf',
      'A-Class',
      '3 Series',
      'A4',
      'Corolla',
      'Civic',
      'Focus',
      'Leon',
      'Octavia',
    ];
    return models[_random.nextInt(models.length)];
  }

  /// Generate random color
  static String randomColor() {
    const colors = [
      'Blanc',
      'Noir',
      'Gris',
      'Bleu',
      'Rouge',
      'Vert',
      'Jaune',
      'Orange',
      'Argenté',
      'Bordeaux',
    ];
    return colors[_random.nextInt(colors.length)];
  }

  /// Generate random number of seats (realistic car capacity)
  static int randomSeats() {
    const seatOptions = [4, 5, 7, 9];
    return seatOptions[_random.nextInt(seatOptions.length)];
  }

  /// Generate random integer in range
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Generate random boolean
  static bool randomBool() {
    return _random.nextBool();
  }

  /// Generate random element from list
  static T randomElement<T>(List<T> list) {
    return list[_random.nextInt(list.length)];
  }

  /// Reset random seed (for test isolation if needed)
  static void resetSeed([int seed = 42]) {
    // Note: Dart Random uses a fixed seed at initialization
    // This method is provided for API consistency but doesn't change the seed
    // The seed is set to 42 in the _random initialization above
  }

  /// Normalize string for email (remove accents, special chars)
  static String _normalizeForEmail(String input) {
    return input
        .toLowerCase()
        .replaceAll(' ', '.')
        .replaceAll('-', '.')
        .replaceAll('\'', '')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('á', 'a')
        .replaceAll('ø', 'o')
        .replaceAll('å', 'a')
        .replaceAll('æ', 'ae')
        .replaceAll('œ', 'oe')
        .replaceAll(RegExp(r'[^a-z0-9.]'), '');
  }

  /// Generate very long name for edge case testing
  static String veryLongName() {
    return 'Jean-Pierre-François-André-Marie-Louis-Alexandre-Antoine-Bernard-Charles-David '
        'De la Fontaine-Dupont-Martin-Lefèvre-Bernard-Rousseau-Moreau-Laurent';
  }

  /// Generate name with maximum special characters
  static String nameWithMaxSpecialChars() {
    return 'Søren Åsa O\'Brien-Müller d\'Øyvind';
  }

  /// Generate complex email
  static String complexEmail() {
    return 'jean-pierre.de.la.fontaine+test123@sub-domain.example-mail.co.uk';
  }
}
