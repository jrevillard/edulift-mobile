# 🔧 Ajouter votre certificat autosigné

## ÉTAPE 1: Obtenir le fingerprint de votre certificat

```bash
# Obtenir le certificat de votre API
openssl s_client -connect your-api-domain.com:443 -showcerts </dev/null 2>/dev/null | openssl x509 -outform DER > api_cert.der

# Calculer le SHA-256 fingerprint
openssl dgst -sha256 -binary api_cert.der | base64

# OU plus simple:
echo | openssl s_client -connect your-api-domain.com:443 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
```

## ÉTAPE 2: Ajouter le fingerprint au code

Dans `lib/core/security/certificate_pinning.dart`, ajoutez votre fingerprint:

```dart
static const List<String> allowedFingerprints = [
  // ⚠️ AJOUTER VOTRE CERTIFICAT AUTOSSIGNÉ ICI
  'sha256/VOTRE_FINGERPRINT_ICI',

  // Garder les existants pour la prod future
  'sha256/YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=',
  'sha256/Vjs8r4z+80wjNcr1YKepWQboSIRi63WsWXhIMN+eWys=',

  // Development certificate fingerprint (debug only)
  if (kDebugMode) 'sha256/++MBgDH5WGvL9Bcn5Be30cRcL0f5O+NyoXuWtQdX1aI=',
];
```

## ÉTAPE 3: Réactiver le certificate pinning

```dart
static bool get isCertificatePinningEnabled => !kDebugMode; // Remettre true
```

## ÉTAPE 4: Tester

```bash
flutter test
flutter run
```

## ATTENTION

- ⚠️ **NE PAS METTRE de certificats de développement en production**
- 🔒 Utilisez des certificats valides signés par une CA reconnue en production
- 🧪 Testez thoroughly avant de déployer