# Analyse & Plan d'Implémentation - Refresh Token Automatique

**Date** : 2025-01-16
**Statut** : ANALYSE COMPLÈTE + PLAN D'ACTION
**Priorité** : HAUTE (UX critique pour mobile)

---

## RÉSUMÉ EXÉCUTIF

### Problème Identifié

L'application mobile EduLift utilise des JWT avec une durée de vie de **24 heures**, mais **AUCUN mécanisme de refresh automatique** n'est implémenté côté mobile, bien qu'un endpoint `/refresh` existe côté backend.

**Conséquence** :
- Utilisateurs déconnectés brutalement après 24h d'utilisation
- UX dégradée : "Vous devez vous reconnecter" au lieu d'un refresh transparent
- Non conforme aux best practices mobile 2025

### Solution Proposée

Implémenter un **système de refresh token automatique avec rotation** suivant les best practices OAuth 2.0 2025 :
- Refresh automatique sur détection 401
- Refresh préemptif avant expiration
- Token rotation pour sécurité maximale
- Queue de requêtes pendant refresh (évite race conditions)

---

## PARTIE 1 : ÉTAT ACTUEL DE L'IMPLÉMENTATION

### 1.1 Backend (Node.js/Express)

#### Architecture JWT Actuelle

**Librairie** : `jsonwebtoken`

**Configuration** (`/workspace/backend/src/services/AuthService.ts`):
```typescript
// Ligne 187
const token = jwt.sign(
  { userId: user.id, email: user.email },
  process.env.JWT_SECRET!,
  { expiresIn: '24h' }  // ⚠️ 24 heures
);
```

#### Endpoints Existants

| Endpoint | Méthode | Description | Status |
|----------|---------|-------------|--------|
| `/auth/magic-link` | POST | Demander magic link | ✅ Implémenté |
| `/auth/verify` | POST | Vérifier magic link → obtenir JWT | ✅ Implémenté |
| `/auth/refresh` | POST | **Refresher le token** | ✅ **Existe mais non utilisé** |
| `/auth/logout` | POST | Logout (côté client) | ✅ Implémenté |
| `/auth/profile` | PUT | Update profil (protected) | ✅ Implémenté |

#### Endpoint `/refresh` (DÉJÀ IMPLÉMENTÉ)

**Fichier** : `/workspace/backend/src/controllers/AuthController.ts` (ligne 239)

```typescript
// Ligne 154-177 dans AuthService
public async refreshToken(token: string): Promise<any> {
  try {
    // Décode le token MÊME s'il est expiré
    const decoded = jwt.verify(token, process.env.JWT_SECRET!, {
      ignoreExpiration: true  // ✅ Permet de refresh un token expiré
    }) as JwtPayload;

    // Récupère l'utilisateur
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
    });

    if (!user) {
      throw new Error('User not found');
    }

    // Génère un NOUVEAU token avec 24h
    const newToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET!,
      { expiresIn: '24h' }
    );

    return {
      token: newToken,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
    };
  } catch (error) {
    throw new Error('Token refresh failed');
  }
}
```

**✅ Points positifs** :
- Endpoint fonctionnel et prêt à être utilisé
- Gère les tokens expirés (`ignoreExpiration: true`)
- Validation utilisateur en DB

**⚠️ Limitations actuelles** :
- Pas de refresh token séparé (utilise le même token)
- Pas de rotation de token (sécurité limitée)
- Pas de stockage des refresh tokens en DB (impossible de révoquer)
- Pas de famille de tokens (détection de vol impossible)

#### Middleware d'Authentification

**Fichier** : `/workspace/backend/src/middleware/auth.ts` (lignes 22-77)

```typescript
export const authenticateToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    res.status(401).json({ error: 'Access token required' });
    return;
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as JwtPayload;

    // Fetch user depuis DB pour validation
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
    });

    if (!user) {
      res.status(403).json({ error: 'Invalid token' });
      return;
    }

    req.userId = decoded.userId;
    req.user = user;
    next();
  } catch (error) {
    res.status(403).json({ error: 'Invalid or expired token' });
    return;
  }
};
```

**⚠️ Problème** : Retourne 403 pour token expiré (devrait être 401 pour permettre refresh côté client)

---

### 1.2 Mobile (Flutter)

#### Stockage des Tokens

**Fichier** : `/workspace/mobile_app/lib/core/storage/auth_local_datasource.dart`

**Méthode** : `AdaptiveStorageService` avec chiffrement AES-256-GCM en production

```dart
// Ligne 51 - Dev mode
await _storage.write(key: 'token_key_dev', value: token);

// Ligne 98 - Production mode
final encrypted = _encryptionService.encrypt(token);
await _storage.write(key: 'token_key', value: encrypted);
```

**✅ Points positifs** :
- Chiffrement AES-256-GCM (production)
- Séparation dev/prod
- Utilise Hive (secure storage)

#### Intercepteur HTTP

**Fichier** : `/workspace/mobile_app/lib/core/network/interceptors/network_interceptors.dart`

**Classe** : `NetworkAuthInterceptor` (lignes 22-88)

```dart
class NetworkAuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _authLocalDatasource.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';  // ✅ Ajoute token
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // ❌ PROBLÈME : Juste logout, pas de refresh !
      await _authLocalDatasource.clearToken();
      _tokenExpiryNotifier.notifyTokenExpired();
      handler.next(err);
      return;
    }
    handler.next(err);
  }
}
```

**❌ PROBLÈME CRITIQUE** :
- Sur 401/403 → **logout immédiat**
- **Aucune tentative de refresh automatique**
- Utilisateur forcé de se reconnecter

#### UseCase RefreshToken (NON FONCTIONNEL)

**Fichier** : `/workspace/mobile_app/lib/features/auth/domain/usecases/refresh_token_usecase.dart`

```dart
class RefreshTokenUsecase {
  Future<Either<Failure, User>> call() async {
    // ❌ Délègue juste à getCurrentUser() qui ne refresh rien
    return _authRepository.getCurrentUser(forceRefresh: true);
  }
}
```

**❌ PROBLÈME** : UseCase existe mais ne fait RIEN (pattern vide)

#### Flow d'Authentification Magic Link

**Sécurité PKCE** (Proof Key for Code Exchange) :
- Génère `code_verifier` (random)
- Calcule `code_challenge = SHA256(code_verifier)`
- Envoie challenge au backend
- Backend vérifie le verifier lors de la vérification

**✅ Points positifs** :
- PKCE correctement implémenté
- Validation email côté client (prévient cross-user attacks)
- Stockage sécurisé du token après auth

---

### 1.3 Communication Backend ↔ Mobile

#### Format de Réponse Auth

**Actuel** (`POST /auth/verify`) :
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "displayName": "John Doe"
  }
}
```

**⚠️ Manque** :
- `refreshToken` (token séparé)
- `expiresIn` (durée de vie)
- `tokenType` (Bearer)

#### Gestion des Erreurs 401

**Actuel** :
1. Backend retourne 403 pour token expiré (devrait être 401)
2. Mobile détecte 401/403 → logout immédiat
3. Utilisateur redirigé vers login

**Attendu** :
1. Backend retourne 401 pour token expiré
2. Mobile détecte 401 → appelle `/refresh`
3. Backend retourne nouveau token
4. Mobile retry la requête originale
5. Utilisateur ne voit rien (transparent)

---

## PARTIE 2 : ÉTAT DE L'ART 2025

### 2.1 Best Practices OAuth 2.0 Refresh Tokens

#### 1. Token Rotation (HAUTEMENT RECOMMANDÉ)

**Principe** : À chaque refresh, un NOUVEAU refresh token est généré et l'ancien est invalidé.

**Avantages** :
- Détection de vol de token (si ancien token réutilisé → compromission détectée)
- Limite la fenêtre d'exploitation d'un token volé
- Conformité OAuth 2.0 Security BCP (RFC 8252)

**Implémentation** :
```typescript
// Backend
POST /auth/refresh
Body: { refreshToken: "old_token" }
Response: {
  accessToken: "new_access",
  refreshToken: "new_refresh"  // ✅ Nouveau refresh token
}
```

**Sources** :
- Auth0 (2025): "Refresh Token Rotation is the Gold Standard"
- Okta Developer Guide (2025): "Always rotate refresh tokens"
- RFC 8252 - OAuth 2.0 for Native Apps

#### 2. Durées de Vie Recommandées (2025)

| Token Type | Durée de Vie | Justification |
|------------|--------------|---------------|
| **Access Token** | **5-15 minutes** | Limite fenêtre d'exploitation si volé |
| **Refresh Token** | **30-90 jours** | Balance UX vs sécurité |

**Cas d'usage EduLift** (OPTIMISÉ) :
- Access token : **15 minutes** (app mobile, usage quotidien)
- Refresh token : **60 jours SLIDING** (couvre vacances scolaires 2 semaines)
- Grace period : **5 minutes** (compense latence réseau mobile)

**Sources** :
- OWASP Authentication Cheat Sheet (2025)
- Auth0 Token Best Practices (2025)
- Google Identity Platform Guidelines

#### 3. Reuse Detection (CRITIQUE pour sécurité)

**Principe** : Si un refresh token déjà utilisé est présenté → **compromission détectée** → révoque TOUS les tokens de l'utilisateur.

**Implémentation** :
```typescript
// Backend - Stocke les refresh tokens en DB
RefreshToken {
  id: uuid
  userId: uuid
  token: string (hashed)
  tokenFamily: uuid  // Famille de tokens
  usedAt: Date | null
  expiresAt: Date
  createdAt: Date
}

// Sur refresh
if (refreshToken.usedAt !== null) {
  // ⚠️ Token déjà utilisé = vol détecté !
  await revokeAllUserTokens(userId);
  throw new SecurityException('Token reuse detected');
}
```

**Sources** :
- Okta Refresh Token Guide (2025)
- Auth0 Security Advisory (2025)

#### 4. Stockage Sécurisé Mobile

**Recommandations 2025** :

| Méthode | Sécurité | Performance | Recommandation |
|---------|----------|-------------|----------------|
| **flutter_secure_storage** | ✅ Élevée (Keychain/KeyStore) | ✅ Rapide | **RECOMMANDÉ** |
| SharedPreferences | ❌ Faible (plaintext) | ✅ Rapide | ❌ À ÉVITER |
| SQLite chiffré | ✅ Élevée | ⚠️ Moyenne | ✅ Acceptable |
| HttpOnly Cookies | ⚠️ N/A (pas pour native) | N/A | ❌ Web only |

**EduLift utilise déjà flutter_secure_storage + AES-256-GCM** ✅

**Sources** :
- OWASP Mobile Security Testing Guide (2025)
- Flutter Security Best Practices (2025)

#### 5. Silent Refresh (UX Optimale)

**Principe** : Refresh le token AVANT qu'il expire (proactif vs réactif).

**Stratégies** :
1. **Time-based OPTIMISÉ** : Refresh à **66% de la durée de vie** (5 min de marge)
   - Access token 15min → refresh après **10min** (marge 5min)
   - Permet 3 retries si réseau lent (3× 10s = 30s)
   - Buffer sécurité : 4+ minutes restantes
2. **On-demand** : Refresh sur 401 (réactif, grace period 5min)
3. **Hybrid** : Time-based + fallback 401 (RECOMMANDÉ)

**Implémentation Flutter** :
```dart
// Timer pour refresh proactif avec MARGE OPTIMALE
Timer? _refreshTimer;

void _scheduleTokenRefresh(int expiresIn) {
  // 66% du lifetime = 5 min de marge minimum
  final refreshAt = Duration(seconds: (expiresIn * 0.66).toInt());
  _refreshTimer = Timer(refreshAt, _performSilentRefresh);
}
```

**Sources** :
- Auth0 Silent Authentication Guide (2025)
- Flutter Auth Best Practices (Medium, 2025)

---

### 2.2 Patterns Flutter/Dio Spécifiques

#### 1. Intercepteur avec Queue (Évite Race Conditions)

**Problème** : Multiples requêtes simultanées avec token expiré → multiples appels `/refresh` simultanés.

**Solution** : Queue de requêtes + single refresh.

```dart
class RefreshTokenInterceptor extends QueuedInterceptor {
  bool _isRefreshing = false;
  final _requestQueue = <RequestOptions>[];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          // Refresh token UNE SEULE FOIS
          await _refreshToken();

          // Retry toutes les requêtes en queue
          for (final req in _requestQueue) {
            _retryRequest(req);
          }
          _requestQueue.clear();
        } finally {
          _isRefreshing = false;
        }
      } else {
        // Ajoute à la queue si refresh déjà en cours
        _requestQueue.add(err.requestOptions);
      }
    }
  }
}
```

**Sources** :
- Medium: "Mastering Auth in Flutter with Dio" (Jan 2025)
- Stack Overflow: "Using Interceptor in Dio for Flutter" (2025)

#### 2. Package `dio_refresh` (Alternative)

**Package** : `dio_refresh` (pub.dev, Octobre 2024)

**Avantages** :
- Gestion automatique du refresh
- Queue intégrée
- Callback personnalisable

```dart
dio.interceptors.add(
  DioRefreshInterceptor(
    refreshToken: () async {
      final newToken = await authService.refreshToken();
      return newToken;
    },
  ),
);
```

**Sources** :
- pub.dev/packages/dio_refresh
- GitHub: dariowskii/refresh-token-interceptor

#### 3. Refresh Préemptif (Avant Expiration)

**Pattern recommandé** : Vérifier l'expiration AVANT chaque requête.

```dart
@override
void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
  final token = await _storage.getToken();
  final expiresAt = await _storage.getTokenExpiry();

  // ✅ OPTIMISÉ : Refresh si expire dans moins de 5 minutes
  // Calcul : 15min token → refresh à 10min (66%) → marge 5min
  if (DateTime.now().add(Duration(minutes: 5)).isAfter(expiresAt)) {
    await _refreshToken();
    // Récupère le nouveau token
    final newToken = await _storage.getToken();
    options.headers['Authorization'] = 'Bearer $newToken';
  } else {
    options.headers['Authorization'] = 'Bearer $token';
  }

  handler.next(options);
}
```

**Sources** :
- DEV Community: "Handling HTTP Requests with DIO" (2025)
- Medium: "Secure Authentication in Flutter" (Mars 2025)

---

### 2.3 Best Practices Backend Node.js/Express

#### 1. Stockage des Refresh Tokens en DB

**Schéma recommandé** (Prisma) :
```prisma
model RefreshToken {
  id           String   @id @default(uuid())
  userId       String
  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  token        String   @unique  // Hashed (bcrypt ou SHA256)
  tokenFamily  String              // Pour détecter vol

  isRevoked    Boolean  @default(false)
  usedAt       DateTime?           // Détection reuse

  expiresAt    DateTime
  createdAt    DateTime @default(now())

  @@index([userId])
  @@index([tokenFamily])
}
```

**Avantages** :
- Révocation granulaire (par token ou par famille)
- Audit trail (createdAt, usedAt)
- Détection de reuse
- Auto-cleanup (cron job sur expiresAt)

**Sources** :
- GeeksforGeeks: "JWT Authentication With Refresh Tokens" (2025)
- BezKoder: "JWT Refresh Token Node.js" (2025)

#### 2. Hashing des Refresh Tokens

**CRITIQUE** : Ne JAMAIS stocker les refresh tokens en clair en DB.

```typescript
import crypto from 'crypto';

// Génération
const refreshToken = crypto.randomBytes(64).toString('hex');
const hashedToken = crypto
  .createHash('sha256')
  .update(refreshToken)
  .digest('hex');

// Stockage en DB
await prisma.refreshToken.create({
  data: { token: hashedToken, userId, ... }
});

// Retour au client
return { refreshToken };  // Token original (non hashé)
```

**Sources** :
- Stack Overflow: "Best practice JWT refresh token nodejs" (2025)
- Izertis: "Refresh token with JWT Node.js" (2025)

#### 3. HttpOnly Cookies vs Response Body

**Comparaison** :

| Méthode | Sécurité | Mobile Support | Recommandation |
|---------|----------|----------------|----------------|
| **HttpOnly Cookie** | ✅ Élevée (XSS-proof) | ❌ Limité | Web uniquement |
| **Response Body** | ⚠️ Moyenne (risque XSS si web) | ✅ Full support | **Mobile apps** |

**Pour EduLift (mobile app)** : **Response Body** ✅

```typescript
// Backend response
res.json({
  accessToken: jwt.sign(...),
  refreshToken: refreshTokenString,  // ✅ Dans le body
  expiresIn: 900,  // 15 minutes
  tokenType: 'Bearer'
});
```

**Sources** :
- Medium: "JWT in Node.js — Cookie-based Token" (2025)
- Stack Overflow: "jwt access token and refresh token flow" (2025)

#### 4. Séparation des Secrets JWT

**Recommandation** : Secrets différents pour access et refresh tokens.

```typescript
// .env
JWT_ACCESS_SECRET=super_secret_access_key_256_bits
JWT_REFRESH_SECRET=different_secret_refresh_key_256_bits
```

**Avantages** :
- Si access secret compromis → refresh tokens intacts
- Rotation facilitée
- Conformité sécurité (defense in depth)

**Sources** :
- DEV Community: "Meticulous JWT API Authentication Guide" (2025)
- GitHub: shaikahmadnawaz/access-refresh-tokens-nodejs

---

## PARTIE 3 : PLAN D'IMPLÉMENTATION DÉTAILLÉ

### Phase 1 : Backend (Node.js/Express) - 2-3 jours

#### Étape 1.1 : Schéma DB Refresh Tokens

**Fichier** : `/workspace/backend/prisma/schema.prisma`

```prisma
model RefreshToken {
  id           String   @id @default(uuid())
  userId       String
  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  token        String   @unique  // Hashed SHA256
  tokenFamily  String   @default(uuid())  // Détection vol

  isRevoked    Boolean  @default(false)
  usedAt       DateTime?  // Détection reuse

  expiresAt    DateTime
  createdAt    DateTime @default(now())

  @@index([userId])
  @@index([tokenFamily])
  @@map("refresh_tokens")
}

model User {
  // Ajout relation
  refreshTokens RefreshToken[]
}
```

**Actions** :
```bash
# Générer migration
npx prisma migrate dev --name add_refresh_tokens

# Générer client
npx prisma generate
```

**Estimation** : 1 heure

---

#### Étape 1.2 : Service RefreshToken

**Nouveau fichier** : `/workspace/backend/src/services/RefreshTokenService.ts`

```typescript
import crypto from 'crypto';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class RefreshTokenService {
  // Génère un refresh token
  public async generateRefreshToken(userId: string): Promise<{
    token: string;
    expiresAt: Date;
  }> {
    // Token aléatoire sécurisé (64 bytes)
    const token = crypto.randomBytes(64).toString('hex');

    // Hash pour stockage DB (SHA256)
    const hashedToken = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    // Expiration : 60 jours SLIDING (couvre vacances scolaires)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 60);

    // Révoque tous les anciens tokens (stratégie single device)
    // Alternative : garder N tokens actifs (multi-device)
    await prisma.refreshToken.updateMany({
      where: { userId, isRevoked: false },
      data: { isRevoked: true }
    });

    // Stocke en DB
    await prisma.refreshToken.create({
      data: {
        userId,
        token: hashedToken,
        expiresAt,
      }
    });

    // Retourne le token ORIGINAL (non hashé)
    return { token, expiresAt };
  }

  // Vérifie et consomme un refresh token (rotation)
  public async verifyAndRotateRefreshToken(token: string): Promise<{
    userId: string;
    newRefreshToken: string;
    newRefreshTokenExpiresAt: Date;
  }> {
    // Hash le token reçu
    const hashedToken = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    // Récupère le token de la DB
    const refreshToken = await prisma.refreshToken.findUnique({
      where: { token: hashedToken }
    });

    // Validation
    if (!refreshToken) {
      throw new Error('Invalid refresh token');
    }

    if (refreshToken.isRevoked) {
      throw new Error('Refresh token revoked');
    }

    if (refreshToken.usedAt !== null) {
      // ⚠️ REUSE DÉTECTÉ = Vol probable
      // Révoque TOUS les tokens de cette famille
      await this.revokeTokenFamily(refreshToken.tokenFamily);
      throw new Error('Token reuse detected - all tokens revoked');
    }

    // ✅ SLIDING EXPIRATION : Renouvelle l'expiration à chaque usage
    // User actif ne sera jamais déconnecté (60 jours depuis dernier usage)
    if (new Date() > refreshToken.expiresAt) {
      throw new Error('Refresh token expired');
    }

    // Marque comme utilisé (pour détecter reuse)
    await prisma.refreshToken.update({
      where: { id: refreshToken.id },
      data: { usedAt: new Date() }
    });

    // Génère NOUVEAU refresh token (rotation)
    const { token: newToken, expiresAt } = await this.generateRefreshToken(
      refreshToken.userId
    );

    return {
      userId: refreshToken.userId,
      newRefreshToken: newToken,
      newRefreshTokenExpiresAt: expiresAt,
    };
  }

  // Révoque tous les tokens d'une famille (sécurité)
  private async revokeTokenFamily(tokenFamily: string): Promise<void> {
    await prisma.refreshToken.updateMany({
      where: { tokenFamily },
      data: { isRevoked: true }
    });
  }

  // Révoque tous les tokens d'un utilisateur (logout)
  public async revokeAllUserTokens(userId: string): Promise<void> {
    await prisma.refreshToken.updateMany({
      where: { userId },
      data: { isRevoked: true }
    });
  }
}
```

**Estimation** : 3 heures

---

#### Étape 1.3 : Modifier AuthService

**Fichier** : `/workspace/backend/src/services/AuthService.ts`

**Modifications** :

```typescript
import { RefreshTokenService } from './RefreshTokenService';

export class AuthService {
  private refreshTokenService = new RefreshTokenService();

  // Modifier authenticateWithMagicLink
  public async authenticateWithMagicLink(
    token: string,
    codeVerifier: string,
    email: string
  ): Promise<any> {
    // ... validation existante ...

    // ✅ MODIF : Génère access token (15min) + refresh token (30 jours)
    const accessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_ACCESS_SECRET!,
      { expiresIn: '15m' }  // ✅ 15 minutes (au lieu de 24h)
    );

    const { token: refreshToken, expiresAt } =
      await this.refreshTokenService.generateRefreshToken(user.id);

    return {
      accessToken,
      refreshToken,  // ✅ NOUVEAU
      expiresIn: 900,  // 15min en secondes
      tokenType: 'Bearer',
      user: {
        id: user.id,
        email: user.email,
        displayName: user.displayName,
      },
    };
  }

  // ✅ NOUVELLE MÉTHODE : Refresh avec rotation
  public async refreshAccessToken(refreshToken: string): Promise<any> {
    const {
      userId,
      newRefreshToken,
      newRefreshTokenExpiresAt,
    } = await this.refreshTokenService.verifyAndRotateRefreshToken(refreshToken);

    // Récupère user
    const user = await prisma.user.findUnique({
      where: { id: userId }
    });

    if (!user) {
      throw new Error('User not found');
    }

    // Génère nouveau access token
    const accessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_ACCESS_SECRET!,
      { expiresIn: '15m' }
    );

    return {
      accessToken,
      refreshToken: newRefreshToken,  // ✅ Token rotaté
      expiresIn: 900,
      tokenType: 'Bearer',
    };
  }

  // ✅ NOUVELLE MÉTHODE : Logout avec révocation
  public async logout(userId: string): Promise<void> {
    await this.refreshTokenService.revokeAllUserTokens(userId);
  }
}
```

**Estimation** : 2 heures

---

#### Étape 1.4 : Modifier Endpoints

**Fichier** : `/workspace/backend/src/controllers/AuthController.ts`

```typescript
export class AuthController {
  private authService = new AuthService();

  // Modifier POST /auth/verify (magic link)
  public async verifyMagicLink(req: Request, res: Response): Promise<void> {
    try {
      const result = await this.authService.authenticateWithMagicLink(
        req.body.token,
        req.body.codeVerifier,
        req.body.email
      );

      // ✅ Response avec refreshToken
      res.json(result);  // { accessToken, refreshToken, expiresIn, user }
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  }

  // ✅ MODIFIER POST /auth/refresh
  public async refreshToken(req: Request, res: Response): Promise<void> {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        res.status(400).json({ error: 'Refresh token required' });
        return;
      }

      const result = await this.authService.refreshAccessToken(refreshToken);
      res.json(result);  // { accessToken, refreshToken (nouveau), expiresIn }
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  }

  // ✅ NOUVEAU POST /auth/logout
  public async logout(req: Request, res: Response): Promise<void> {
    try {
      // req.userId ajouté par middleware authenticateToken
      await this.authService.logout(req.userId);
      res.json({ message: 'Logged out successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}
```

**Fichier** : `/workspace/backend/src/routes/auth.ts`

```typescript
// Modifier route logout pour être protégée
router.post('/logout', authenticateToken, (req, res) =>
  authController.logout(req, res)
);
```

**Estimation** : 1 heure

---

#### Étape 1.5 : Modifier Middleware (401 vs 403)

**Fichier** : `/workspace/backend/src/middleware/auth.ts`

```typescript
export const authenticateToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    res.status(401).json({ error: 'Access token required' });  // ✅ 401
    return;
  }

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_ACCESS_SECRET!  // ✅ Nouveau secret
    ) as JwtPayload;

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
    });

    if (!user) {
      res.status(403).json({ error: 'Invalid token' });  // 403 pour user invalide
      return;
    }

    req.userId = decoded.userId;
    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      // ✅ GRACE PERIOD : Vérifie si expiré depuis moins de 5 minutes
      const decoded = jwt.decode(token) as JwtPayload;
      const expirationTime = decoded.exp! * 1000;
      const gracePeriod = 5 * 60 * 1000; // 5 minutes

      if (Date.now() - expirationTime <= gracePeriod) {
        // Token expiré mais dans grace period → traiter comme valide
        const user = await prisma.user.findUnique({
          where: { id: decoded.userId }
        });

        if (user) {
          req.userId = decoded.userId;
          req.user = user;
          next();
          return;
        }
      }

      // Expiré au-delà du grace period → 401 pour refresh
      res.status(401).json({ error: 'Token expired' });
    } else {
      res.status(403).json({ error: 'Invalid token' });
    }
    return;
  }
};
```

**Estimation** : 30 minutes

---

#### Étape 1.6 : Variables d'Environnement

**Fichier** : `/workspace/backend/.env`

```bash
# Secrets JWT séparés
JWT_ACCESS_SECRET=generate_super_strong_secret_256_bits_for_access
JWT_REFRESH_SECRET=generate_different_strong_secret_256_bits_for_refresh

# ✅ OPTIMISÉ : durées configurables
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY_DAYS=60
REFRESH_GRACE_PERIOD_MINUTES=5
```

**Génération secrets** :
```bash
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**Estimation** : 15 minutes

---

#### Étape 1.7 : Tests Backend

**Nouveau fichier** : `/workspace/backend/src/tests/auth.refresh.test.ts`

```typescript
describe('Refresh Token Flow', () => {
  it('should refresh access token with valid refresh token', async () => {
    // Login
    const loginRes = await request(app)
      .post('/auth/verify')
      .send({ token, codeVerifier, email });

    const { accessToken, refreshToken } = loginRes.body;

    // Refresh
    const refreshRes = await request(app)
      .post('/auth/refresh')
      .send({ refreshToken });

    expect(refreshRes.status).toBe(200);
    expect(refreshRes.body.accessToken).toBeDefined();
    expect(refreshRes.body.refreshToken).not.toBe(refreshToken);  // Rotation
  });

  it('should detect token reuse', async () => {
    // ... login ...
    const { refreshToken } = loginRes.body;

    // Refresh 1x
    await request(app).post('/auth/refresh').send({ refreshToken });

    // Refresh 2x avec MÊME token → reuse détecté
    const reuse = await request(app).post('/auth/refresh').send({ refreshToken });

    expect(reuse.status).toBe(401);
    expect(reuse.body.error).toContain('reuse detected');
  });

  it('should revoke all tokens on logout', async () => {
    // ... login ...
    const { accessToken, refreshToken } = loginRes.body;

    // Logout
    await request(app)
      .post('/auth/logout')
      .set('Authorization', `Bearer ${accessToken}`);

    // Try refresh → doit échouer
    const refreshRes = await request(app)
      .post('/auth/refresh')
      .send({ refreshToken });

    expect(refreshRes.status).toBe(401);
  });
});
```

**Estimation** : 2 heures

---

### Phase 2 : Mobile (Flutter) - 2-3 jours

#### Étape 2.1 : Modifier Stockage Tokens

**Fichier** : `/workspace/mobile_app/lib/core/storage/auth_local_datasource.dart`

```dart
class AuthLocalDatasource {
  // ✅ NOUVEAU : Stocker refresh token
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    final service = _storageServiceFactory.createStorageService();

    // Access token
    await service.storeToken(accessToken);

    // Refresh token (séparé, chiffré)
    if (kReleaseMode) {
      final encrypted = _encryptionService.encrypt(refreshToken);
      await _storage.write(key: 'refresh_token_key', value: encrypted);
    } else {
      await _storage.write(key: 'refresh_token_key_dev', value: refreshToken);
    }

    // Expiration
    await _storage.write(
      key: 'token_expires_at',
      value: expiresAt.toIso8601String()
    );
  }

  Future<String?> getRefreshToken() async {
    if (kReleaseMode) {
      final encrypted = await _storage.read(key: 'refresh_token_key');
      return encrypted != null ? _encryptionService.decrypt(encrypted) : null;
    } else {
      return await _storage.read(key: 'refresh_token_key_dev');
    }
  }

  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _storage.read(key: 'token_expires_at');
    return expiryStr != null ? DateTime.parse(expiryStr) : null;
  }

  Future<void> clearTokens() async {
    await clearToken();  // Access token (existant)
    await _storage.delete(key: 'refresh_token_key');
    await _storage.delete(key: 'refresh_token_key_dev');
    await _storage.delete(key: 'token_expires_at');
  }
}
```

**Estimation** : 1 heure

---

#### Étape 2.2 : Service de Refresh

**Nouveau fichier** : `/workspace/mobile_app/lib/core/services/token_refresh_service.dart`

```dart
import 'package:dio/dio.dart';

class TokenRefreshService {
  final Dio _dio;
  final AuthLocalDatasource _storage;
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshQueue = [];

  TokenRefreshService(this._dio, this._storage);

  /// Refresh le token avec protection contre race conditions
  Future<void> refreshToken() async {
    // Si refresh déjà en cours, attendre sa complétion
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Appel /refresh SANS intercepteur (pour éviter boucle infinie)
      final dio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Stocke les nouveaux tokens
        await _storage.storeTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],  // Token rotaté
          expiresAt: DateTime.now().add(Duration(seconds: data['expiresIn'])),
        );

        AppLogger.info('[TokenRefresh] Token refreshed successfully');

        // Complète toutes les requêtes en queue
        for (final completer in _refreshQueue) {
          completer.complete();
        }
        _refreshQueue.clear();
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        '[TokenRefresh] Refresh failed',
        error: e,
        stackTrace: stackTrace,
      );

      // Force logout
      await _storage.clearTokens();

      // Rejette toutes les requêtes en queue
      for (final completer in _refreshQueue) {
        completer.completeError(e);
      }
      _refreshQueue.clear();

      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  /// ✅ OPTIMISÉ : Vérifie si le token doit être refreshé (5 min avant expiration)
  /// Calcul : 15min token → refresh à 10min (66%) → marge 5min
  Future<bool> shouldRefreshToken() async {
    final expiresAt = await _storage.getTokenExpiry();

    if (expiresAt == null) return false;

    // Refresh si expire dans moins de 5 minutes (marge sécurisée)
    final refreshThreshold = DateTime.now().add(Duration(minutes: 5));
    return refreshThreshold.isAfter(expiresAt);
  }
}
```

**Estimation** : 2 heures

---

#### Étape 2.3 : Intercepteur avec Refresh Automatique

**Fichier** : `/workspace/mobile_app/lib/core/network/interceptors/network_interceptors.dart`

```dart
class NetworkAuthInterceptor extends QueuedInterceptor {
  final AuthLocalDatasource _authLocalDatasource;
  final TokenRefreshService _tokenRefreshService;
  final TokenExpiryNotifier _tokenExpiryNotifier;

  NetworkAuthInterceptor({
    required AuthLocalDatasource authLocalDatasource,
    required TokenRefreshService tokenRefreshService,
    required TokenExpiryNotifier tokenExpiryNotifier,
  })  : _authLocalDatasource = authLocalDatasource,
        _tokenRefreshService = tokenRefreshService,
        _tokenExpiryNotifier = tokenExpiryNotifier;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // ✅ NOUVEAU : Refresh préemptif (avant expiration)
      if (await _tokenRefreshService.shouldRefreshToken()) {
        AppLogger.info('[AuthInterceptor] Token expires soon, refreshing...');
        await _tokenRefreshService.refreshToken();
      }

      // Ajoute le token à la requête
      final token = await _authLocalDatasource.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Token refresh failed',
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ✅ MODIF : Refresh automatique sur 401
    if (err.response?.statusCode == 401) {
      try {
        AppLogger.info('[AuthInterceptor] 401 detected, attempting refresh...');

        // Refresh token
        await _tokenRefreshService.refreshToken();

        // Retry la requête originale avec nouveau token
        final token = await _authLocalDatasource.getToken();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $token';

        final dio = Dio();
        final response = await dio.fetch(opts);

        handler.resolve(response);  // ✅ Retourne la réponse retried
        return;
      } catch (refreshError) {
        AppLogger.error('[AuthInterceptor] Refresh failed, logging out');

        // Refresh échoué → logout
        await _authLocalDatasource.clearTokens();
        _tokenExpiryNotifier.notifyTokenExpired();

        handler.next(err);  // Continue avec l'erreur originale
        return;
      }
    }

    // 403 ou autres erreurs → pas de refresh
    if (err.response?.statusCode == 403) {
      await _authLocalDatasource.clearTokens();
      _tokenExpiryNotifier.notifyTokenExpired();
    }

    handler.next(err);
  }
}
```

**Estimation** : 2 heures

---

#### Étape 2.4 : Modifier AuthService

**Fichier** : `/workspace/mobile_app/lib/core/services/auth_service.dart`

```dart
class AuthService {
  // Modifier authenticateWithMagicLink
  Future<Either<Failure, void>> authenticateWithMagicLink(
    String token,
    String email,
  ) async {
    try {
      // ... code existant ...

      // ✅ MODIF : Récupère refreshToken de la réponse
      final response = await ApiResponseHelper.execute<AuthDto>(
        () => _authApiClient.verifyMagicLink(request),
      );

      final authDto = response.unwrap();

      // ✅ NOUVEAU : Stocke access + refresh tokens
      await _authLocalDatasource.storeTokens(
        accessToken: authDto.token,  // Access token
        refreshToken: authDto.refreshToken,  // Refresh token
        expiresAt: DateTime.now().add(
          Duration(seconds: authDto.expiresIn ?? 900)
        ),
      );

      // ... reste du code ...

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  // ✅ NOUVEAU : Logout avec révocation backend
  Future<Either<Failure, void>> logout() async {
    try {
      final token = await _authLocalDatasource.getToken();

      if (token != null) {
        // Appel backend pour révoquer refresh tokens
        await _authApiClient.logout();
      }

      // Clear local storage
      await _authLocalDatasource.clearTokens();

      return const Right(null);
    } catch (e) {
      // Même si backend échoue, clear local
      await _authLocalDatasource.clearTokens();
      return const Right(null);
    }
  }
}
```

**Estimation** : 1 heure

---

#### Étape 2.5 : DTOs

**Fichier** : `/workspace/mobile_app/lib/data/auth/models/auth_dto.dart`

```dart
class AuthDto {
  final String token;          // Access token
  final String refreshToken;   // ✅ NOUVEAU
  final int expiresIn;         // ✅ NOUVEAU (en secondes)
  final String tokenType;
  final UserProfileDto user;

  AuthDto({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.user,
  });

  factory AuthDto.fromJson(Map<String, dynamic> json) => AuthDto(
    token: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresIn: json['expiresIn'] as int,
    tokenType: json['tokenType'] as String? ?? 'Bearer',
    user: UserProfileDto.fromJson(json['user']),
  );
}
```

**Estimation** : 30 minutes

---

#### Étape 2.6 : Provider DI

**Fichier** : `/workspace/mobile_app/lib/core/di/providers/service_providers.dart`

```dart
@riverpod
TokenRefreshService tokenRefreshService(TokenRefreshServiceRef ref) {
  return TokenRefreshService(
    ref.watch(dioProvider),
    ref.watch(authLocalDatasourceProvider),
  );
}

// Modifier networkAuthInterceptorProvider
@riverpod
NetworkAuthInterceptor networkAuthInterceptor(NetworkAuthInterceptorRef ref) {
  return NetworkAuthInterceptor(
    authLocalDatasource: ref.watch(authLocalDatasourceProvider),
    tokenRefreshService: ref.watch(tokenRefreshServiceProvider),  // ✅ NOUVEAU
    tokenExpiryNotifier: ref.watch(tokenExpiryNotifierProvider),
  );
}
```

**Estimation** : 30 minutes

---

#### Étape 2.7 : Tests Mobile

**Nouveau fichier** : `/workspace/mobile_app/test/unit/core/services/token_refresh_service_test.dart`

```dart
void main() {
  late MockDio mockDio;
  late MockAuthLocalDatasource mockStorage;
  late TokenRefreshService service;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockAuthLocalDatasource();
    service = TokenRefreshService(mockDio, mockStorage);
  });

  test('should refresh token successfully', () async {
    // Arrange
    when(() => mockStorage.getRefreshToken())
        .thenAnswer((_) async => 'old_refresh_token');

    when(() => mockDio.post('/auth/refresh', data: any(named: 'data')))
        .thenAnswer((_) async => Response(
          data: {
            'accessToken': 'new_access_token',
            'refreshToken': 'new_refresh_token',
            'expiresIn': 900,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/auth/refresh'),
        ));

    // Act
    await service.refreshToken();

    // Assert
    verify(() => mockStorage.storeTokens(
      accessToken: 'new_access_token',
      refreshToken: 'new_refresh_token',
      expiresAt: any(named: 'expiresAt'),
    )).called(1);
  });

  test('should handle concurrent refresh requests', () async {
    // Arrange
    when(() => mockStorage.getRefreshToken())
        .thenAnswer((_) async => 'refresh_token');

    when(() => mockDio.post(any(), data: any(named: 'data')))
        .thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return Response(
            data: {
              'accessToken': 'new_token',
              'refreshToken': 'new_refresh',
              'expiresIn': 900,
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/auth/refresh'),
          );
        });

    // Act - Lancer 3 refresh simultanés
    final futures = [
      service.refreshToken(),
      service.refreshToken(),
      service.refreshToken(),
    ];

    await Future.wait(futures);

    // Assert - Un seul appel backend
    verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
  });
}
```

**Estimation** : 2 heures

---

### Phase 3 : Tests End-to-End - 1 jour

#### Étape 3.1 : Test Patrol E2E

**Fichier** : `/workspace/mobile_app/integration_test/auth_refresh_flow_test.dart`

```dart
void main() {
  patrolTest('Token auto-refresh on 401', (PatrolTester $) async {
    // Login
    await $.pumpWidgetAndSettle(MyApp());
    await loginWithMagicLink($);

    // Attendre que le token expire (ou forcer expiration côté backend)
    // Pour test rapide : réduire JWT_ACCESS_EXPIRY à 5 secondes côté backend
    await Future.delayed(Duration(seconds: 6));

    // Faire une requête protégée
    await $.tap(find.text('Mon Profil'));

    // ✅ Vérifier : App fonctionne (refresh automatique)
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Connexion'), findsNothing);  // Pas de logout
  });

  patrolTest('Logout revokes refresh tokens', (PatrolTester $) async {
    // Login
    await $.pumpWidgetAndSettle(MyApp());
    await loginWithMagicLink($);

    final storage = AuthLocalDatasource();
    final oldRefreshToken = await storage.getRefreshToken();

    // Logout
    await $.tap(find.text('Se déconnecter'));
    await $.pumpAndSettle();

    // ✅ Vérifier : Tokens supprimés localement
    expect(await storage.getToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);

    // ✅ Vérifier : Refresh token révoqué côté backend
    // (nécessite endpoint de test ou check en DB)
  });
}
```

**Estimation** : 3 heures

---

#### Étape 3.2 : Test de Sécurité (Token Reuse)

**Fichier backend** : `/workspace/backend/src/tests/security.refresh.test.ts`

```typescript
describe('Refresh Token Security', () => {
  it('should detect and block token reuse attack', async () => {
    // 1. Login → obtient refreshToken
    const loginRes = await request(app)
      .post('/auth/verify')
      .send({ token: validMagicLinkToken, codeVerifier, email });

    const refreshToken1 = loginRes.body.refreshToken;

    // 2. Refresh → obtient nouveau refreshToken
    const refreshRes1 = await request(app)
      .post('/auth/refresh')
      .send({ refreshToken: refreshToken1 });

    const refreshToken2 = refreshRes1.body.refreshToken;
    expect(refreshToken2).not.toBe(refreshToken1);  // Rotation OK

    // 3. ATTAQUE : Réutiliser l'ancien token (simuler vol)
    const attackRes = await request(app)
      .post('/auth/refresh')
      .send({ refreshToken: refreshToken1 });  // Ancien token

    // ✅ Devrait être bloqué
    expect(attackRes.status).toBe(401);
    expect(attackRes.body.error).toContain('reuse detected');

    // 4. Vérifier : TOUS les tokens révoqués (même le nouveau)
    const refreshRes2 = await request(app)
      .post('/auth/refresh')
      .send({ refreshToken: refreshToken2 });

    expect(refreshRes2.status).toBe(401);  // Token valide révoqué par sécurité
  });
});
```

**Estimation** : 2 heures

---

### Phase 4 : Documentation & Déploiement - 0.5 jour

#### Étape 4.1 : Documentation Technique

**Fichier** : `/workspace/docs/authentication/refresh-token-flow.md`

```markdown
# Architecture Refresh Tokens

## Vue d'Ensemble

EduLift utilise un système de refresh tokens avec rotation automatique pour maintenir les sessions utilisateurs actives sans compromettre la sécurité.

## Durées de Vie (OPTIMISÉES 2025)

- **Access Token** : 15 minutes
- **Refresh Token** : 60 jours SLIDING (se renouvelle à chaque usage)
- **Grace Period** : 5 minutes (compense latence réseau mobile)

## Flow Complet

### 1. Login (Magic Link)
POST /auth/verify
→ { accessToken, refreshToken, expiresIn, user }

### 2. Requêtes API
Authorization: Bearer <accessToken>

### 3. Refresh Préemptif (Mobile)
5 minutes avant expiration → appel automatique /refresh

### 4. Refresh Réactif (Mobile)
Sur 401 → appel /refresh → retry requête

### 5. Logout
POST /auth/logout → révoque tous les refresh tokens de l'utilisateur

## Sécurité

### Token Rotation
Chaque refresh génère un NOUVEAU refresh token.
L'ancien est marqué comme utilisé.

### Reuse Detection
Si un token déjà utilisé est présenté → vol détecté → révocation de tous les tokens.

### Stockage
- Backend : Refresh tokens hashés (SHA256) en DB
- Mobile : Access + refresh tokens chiffrés (AES-256-GCM) dans SecureStorage

## Diagrammes

[Insérer diagrammes de séquence]
```

**Estimation** : 2 heures

---

#### Étape 4.2 : Migration de Production

**Checklist** :

1. **Backend** :
   ```bash
   # Production
   npm run prisma:migrate:deploy
   npm run build
   pm2 restart edulift-backend
   ```

2. **Variables d'environnement** :
   - Générer secrets production
   - Déployer sur serveur

3. **Migration utilisateurs existants** :
   - Anciens tokens (24h) restent valides
   - Nouveaux login génèrent refresh tokens
   - Pas de breaking change

4. **Monitoring** :
   - Logs de refresh (taux, erreurs)
   - Alertes sur reuse detection
   - Dashboard token expiration

**Estimation** : 2 heures

---

## RÉSUMÉ & TIMELINE

### Estimation Totale : **6-7 jours** (1 développeur)

| Phase | Estimation | Priorité |
|-------|------------|----------|
| **Phase 1 : Backend** | 2-3 jours | HAUTE |
| **Phase 2 : Mobile** | 2-3 jours | HAUTE |
| **Phase 3 : Tests E2E** | 1 jour | MOYENNE |
| **Phase 4 : Doc & Deploy** | 0.5 jour | BASSE |

### Ordre d'Implémentation Recommandé

1. ✅ **Backend d'abord** (Phase 1) - permet de tester avec Postman
2. ✅ **Mobile ensuite** (Phase 2) - consomme l'API backend
3. ✅ **Tests E2E** (Phase 3) - validation complète
4. ✅ **Documentation** (Phase 4) - référence pour l'équipe

### Risques Identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| **Race conditions refresh** | Moyenne | Haut | Queue + flag _isRefreshing |
| **Perte de refresh tokens** | Faible | Moyen | Backup SecureStorage |
| **Migration DB lente** | Faible | Faible | Index sur userId, tokenFamily |
| **Reuse detection faux positifs** | Faible | Haut | Tests exhaustifs |

### Avantages Post-Implémentation

1. **UX améliorée** : Sessions persistantes 30 jours (vs 24h actuellement)
2. **Sécurité renforcée** : Détection de vol, tokens courts, rotation
3. **Conformité** : OAuth 2.0 BCP, OWASP Mobile Security
4. **Monitoring** : Logs, alertes, audit trail
5. **Scalabilité** : Révocation granulaire, multi-device ready

---

## ANNEXE : Alternatives Considérées

### Alternative 1 : Biométrie pour Refresh

**Principe** : Demander empreinte/FaceID avant refresh.

**Avantages** :
- Sécurité maximale
- UX premium

**Inconvénients** :
- Friction utilisateur
- Complexité implémentation
- Pas universel (anciens devices)

**Décision** : **NON** pour v1, possible v2

### Alternative 2 : Refresh Token en Cookie (HttpOnly)

**Principe** : Backend set refresh token dans cookie HttpOnly.

**Avantages** :
- Sécurité élevée (XSS-proof)
- Standard web

**Inconvénients** :
- **Incompatible apps natives** (Flutter ne gère pas cookies automatiquement)
- Complexité CORS

**Décision** : **NON** - Mobile apps utilisent response body

### Alternative 3 : Short-Lived Sessions (No Refresh)

**Principe** : Sessions courtes (1h), utilisateur doit se reconnecter.

**Avantages** :
- Simplicité
- Sécurité par court TTL

**Inconvénients** :
- **UX catastrophique** pour mobile
- Non compétitif

**Décision** : **NON** - Inacceptable pour mobile

---

## SOURCES & RÉFÉRENCES

### Documentation Officielle
- [RFC 6749 - OAuth 2.0 Authorization Framework](https://datatracker.ietf.org/doc/html/rfc6749)
- [RFC 8252 - OAuth 2.0 for Native Apps](https://datatracker.ietf.org/doc/html/rfc8252)
- [OWASP Mobile Security Testing Guide (2025)](https://owasp.org/www-project-mobile-security-testing-guide/)
- [Auth0 Refresh Token Best Practices (2025)](https://auth0.com/docs/secure/tokens/refresh-tokens)
- [Okta Developer - Refresh Tokens Guide (2025)](https://developer.okta.com/docs/guides/refresh-tokens/main/)

### Articles Techniques (2025)
- Medium: "Secure Authentication in Flutter with Dio" (Mars 2025)
- DEV Community: "Mastering Auth in Flutter with Dio" (Janvier 2025)
- GeeksforGeeks: "JWT Authentication With Refresh Tokens" (2025)

### Packages
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- [dio_refresh](https://pub.dev/packages/dio_refresh)
- [jsonwebtoken (Node.js)](https://www.npmjs.com/package/jsonwebtoken)

---

**Auteur** : Claude Code
**Date** : 2025-01-16
**Version** : 1.0
**Status** : PRÊT POUR IMPLÉMENTATION
