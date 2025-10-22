# CORRECTION 403 APPLIQUÉE

## Résumé

Correction de la logique des codes HTTP 401/403 dans le mobile et backend pour respecter les standards REST :
- **401 Unauthorized** : Problèmes d'authentification (token expiré, invalide, user supprimé) → triggers automatic refresh
- **403 Forbidden** : User authentifié mais pas les droits pour une ressource → affiche erreur UI, ne logout PAS

---

## ✅ Mobile - network_interceptors.dart

**Fichier** : `/workspace/mobile_app/lib/core/network/interceptors/network_interceptors.dart`

### Modifications appliquées

1. **Suppression du bloc 403** (lignes 171-204)
   - ❌ Avant : Sur 403 → logout + clearTokens
   - ✅ Après : Sur 403 → DO NOTHING (error propagate to UI)

2. **Commentaire explicatif ajouté**
   ```dart
   // ✅ 403 = Forbidden (user lacks permissions for this specific resource)
   // This is NOT an authentication issue - the user is authenticated but not authorized
   // DO NOT logout, DO NOT refresh, DO NOT clear tokens
   // Just let the error propagate to the UI to display "Access Denied" message
   // Example: Regular user tries to access /admin/users → 403 → Show error, keep user logged in

   // On 403 → DO NOTHING, let error propagate to UI
   ```

### Comportement actuel

| Status | Action Mobile |
|--------|---------------|
| **401** | Refresh automatique du token (si possible), sinon logout |
| **403** | **RIEN** - erreur remonte à l'UI pour affichage |

---

## ✅ Backend - middleware/auth.ts

**Fichier** : `/workspace/backend/src/middleware/auth.ts`

### Modifications appliquées

1. **Commentaire global ajouté** (lignes 22-25)
   ```typescript
   // HTTP Status Codes for Authentication Middleware:
   // - 401 Unauthorized: Token expired, invalid, or user deleted → triggers refresh on client
   // - 403 Forbidden: User authenticated but lacks permissions → used by ROUTE handlers, NOT this middleware
   // This middleware only returns 401 (auth issues), never 403 (permissions are checked in route handlers)
   ```

2. **User not found : 403 → 401** (ligne 67)
   - ❌ Avant : `res.status(403)` pour user not found
   - ✅ Après : `res.status(401)` - c'est un problème d'auth (user deleted)
   - Commentaire ajouté :
     ```typescript
     // ✅ User not found = token is invalid (user was deleted)
     // This is an authentication issue, not a permissions issue
     // Return 401 to trigger automatic refresh on client
     // (refresh will fail because user is deleted, then client will logout)
     ```

3. **Generic token error : 403 → 401** (ligne 127)
   - ❌ Avant : `res.status(403)` pour erreurs JWT
   - ✅ Après : `res.status(401)` - malformed token, wrong signature, etc.
   - Commentaire ajouté :
     ```typescript
     // ✅ 401 = Invalid token (any other JWT verification error)
     // Could be malformed, wrong signature, etc. - all auth issues, not permissions
     ```

### Comportement actuel

Le middleware `authenticateToken` retourne **uniquement 401** (jamais 403) :
- Token manquant → 401
- Token expiré → 401
- User not found (deleted) → 401
- Token invalide (signature, format) → 401

Le **403** est réservé aux **route handlers** pour les vérifications de permissions :
```typescript
// Exemple dans requireGroupAdmin (ligne 241)
if (!hasAdminPermissions) {
  res.status(403).json({ error: 'Admin privileges required' });  // ✅ Correct
}
```

---

## ✅ Compilation

### Mobile
```bash
$ dart analyze lib/core/network/interceptors/network_interceptors.dart
Analyzing network_interceptors.dart...
No issues found!
```

### Backend
```bash
$ npm run build
> tsc
# ✅ Build successful (0 errors)
```

---

## 📋 Logique correcte (rappel)

| Status | Signification | Mobile Action | Backend Middleware | Backend Route Handler |
|--------|---------------|---------------|--------------------|-----------------------|
| **401** | Token expiré/invalide/user supprimé | **Refresh automatique** | ✅ Toujours | ❌ Jamais |
| **403** | User authentifié mais pas les droits | **RIEN** (afficher erreur UI) | ❌ Jamais | ✅ Permissions check |

### Exemples de 403 (route handlers uniquement)

```typescript
// ✅ Exemple 1 : Admin access required
router.delete('/admin/users/:id', authenticateToken, async (req, res) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  // ... delete user
});

// ✅ Exemple 2 : Resource ownership
router.patch('/families/:id', authenticateToken, async (req, res) => {
  const family = await prisma.family.findUnique({ where: { id: req.params.id } });
  if (family.ownerId !== req.userId) {
    return res.status(403).json({ error: 'Not authorized to modify this family' });
  }
  // ... update family
});
```

---

## 🔍 Impact

### Mobile
- **Avant** : 403 → logout (user perdu sa session même s'il est authentifié)
- **Après** : 403 → affiche erreur "Access Denied" (user reste connecté)

### Backend
- **Avant** : User deleted → 403 → mobile ne refresh PAS → user reste en état zombie
- **Après** : User deleted → 401 → mobile refresh → refresh fail → logout clean

---

## ✅ Validation

- [x] Mobile : Bloc `if (403)` supprimé
- [x] Mobile : Commentaire explicatif ajouté
- [x] Mobile : 403 ne fait RIEN (error propagate to UI)
- [x] Backend : User not found → 403 → 401
- [x] Backend : Generic token error → 403 → 401
- [x] Backend : Commentaire global ajouté (401 vs 403)
- [x] Mobile : 0 erreurs de compilation
- [x] Backend : 0 erreurs de compilation

**STATUS : ✅ CORRECTION 403 COMPLÈTE ET VALIDÉE**
