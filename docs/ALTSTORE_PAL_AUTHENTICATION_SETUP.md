# AltStore PAL GitHub Authentication Setup

This document explains how to configure GitHub authentication for the AltStore PAL CI/CD workflow in Codemagic.

## 🎯 Overview

The AltStore PAL workflow needs to:
1. **Clone** the `jrevillard/my-altstore` repository
2. **Update** JSON source files with new build information
3. **Commit and push** changes back to GitHub

This requires proper GitHub authentication to work reliably.

## 🔐 Required Authentication

The workflow uses **GitHub Personal Access Token (PAT)** authentication.

### Why PAT Authentication?
- ✅ **Simple setup**: Easy to create and configure
- ✅ **Secure**: Token-based authentication with specific permissions
- ✅ **Flexible**: Works with both public and private repositories
- ✅ **Minimal permissions**: Only requires `repo` scope
- ✅ **Revoke anytime**: Can be disabled if compromised

## 🛠️ Setup Instructions

### 1. Create GitHub Personal Access Token

1. Go to GitHub Settings: https://github.com/settings/tokens
2. Click **"Generate new token (classic)"**
3. Configure the token:
   - **Note**: `Codemagic AltStore PAL CI`
   - **Expiration**: Choose appropriate period (90 days recommended)
   - **Scopes**: Check ✅ **`repo`** (Full control of private repositories)
4. Click **"Generate token"**
5. **Copy the token immediately** - you won't see it again!

### 2. Configure Codemagic Environment Variables

In your Codemagic project settings:

1. Go to **Environment variables** tab
2. Add new environment variable:
   - **Variable name**: `GITHUB_TOKEN`
   - **Variable value**: Paste the copied token
   - **Secure**: ✅ Check this box to hide the value
   - **Group**: Leave as default or create `github` group

### 3. Verify Repository Access

Ensure the token has access to:
- **Repository**: `jrevillard/my-altstore`
- **Permissions**: Read + Write access

## 🔧 How It Works

### Clone Operation
```bash
if [[ -n "$GITHUB_TOKEN" ]]; then
  echo "🔑 Using GitHub token for authentication"
  git clone https://$GITHUB_TOKEN@github.com/$ALTSTORE_REPO.git .
else
  echo "⚠️  GITHUB_TOKEN not set, using public clone (may fail for private repos)"
  git clone https://github.com/$ALTSTORE_REPO.git .
fi
```

### Push Operation
```bash
# Configure push URL with token for authentication
if [[ -n "$GITHUB_TOKEN" ]]; then
  git remote set-url origin https://$GITHUB_TOKEN@github.com/$ALTSTORE_REPO.git
fi

git push origin $ALTSTORE_BRANCH
```

## 🚨 Security Best Practices

### Token Security
- ✅ **Store in environment variables** - Never hardcode in code
- ✅ **Use secure variables** - Check "Secure" in Codemagic
- ✅ **Minimal permissions** - Only request `repo` scope
- ✅ **Regular rotation** - Regenerate tokens every 90 days
- ✅ **Revoke when unused** - Delete old tokens

### Access Control
- ✅ **Least privilege** - Token only accesses needed repositories
- ✅ **Monitor usage** - Check GitHub access logs regularly
- ✅ **Repository permissions** - Ensure token has appropriate access level

## 🔍 Troubleshooting

### Common Issues

#### 1. Authentication Failed
```
remote: Invalid username or password.
fatal: Authentication failed for 'https://github.com/jrevillard/my-altstore.git/'
```
**Solution**: Check that `GITHUB_TOKEN` is correctly set and has `repo` permissions.

#### 2. Repository Not Found
```
ERROR: Repository not found.
fatal: Could not read from remote repository.
```
**Solution**:
- Verify repository name: `jrevillard/my-altstore`
- Check token has access to this repository
- Ensure repository exists and is accessible

#### 3. Permission Denied
```
remote: Permission to jrevillard/my-altstore denied to user.
fatal: unable to access 'https://github.com/jrevillard/my-altstore.git/': The requested URL returned error: 403
```
**Solution**:
- Token doesn't have write access to repository
- Repository owner needs to grant access or add token as collaborator

### Debug Steps

1. **Check Environment Variable**:
   ```bash
   echo "Token exists: $([[ -n "$GITHUB_TOKEN" ]] && echo "YES" || echo "NO")"
   ```

2. **Test Token Access**:
   ```bash
   curl -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/repos/jrevillard/my-altstore
   ```

3. **Verify Git Configuration**:
   ```bash
   git remote -v
   git config --list | grep user
   ```

## 🔄 Alternative Authentication Methods

### SSH Deploy Keys (More Complex)
For enhanced security, you can use SSH deploy keys instead of PAT:

1. **Generate SSH Key** in workflow
2. **Add as Deploy Key** in repository settings
3. **Modify git clone URL** to use SSH

**Pros**: More secure, specific to single repository
**Cons**: More complex setup, requires SSH key management

### GitHub Apps (Enterprise)
For large-scale operations:

1. **Create GitHub App** with specific permissions
2. **Install App** on repository/organization
3. **Use App authentication** in workflow

**Pros**: Most secure, fine-grained permissions, audit logging
**Cons**: Overkill for this use case, complex setup

## 📋 Pre-Flight Checklist

Before running the AltStore PAL workflow:

- [ ] **GitHub Token Created**: ✅
- [ ] **Token has `repo` permissions**: ✅
- [ ] **Token added to Codemagic variables**: ✅
- [ ] **Variable marked as secure**: ✅
- [ ] **Repository accessible**: ✅
- [ ] **Write permissions verified**: ✅

## 🎉 Success Indicators

When properly configured, you'll see these logs:
```
🔑 Using GitHub token for authentication
✅ AltStore PAL source files updated
✅ AltStore PAL source updates pushed to GitHub
```

The commit will appear in GitHub with author: `Codemagic CI <ci@codemagic.io>`.

## 📚 Additional Resources

- [GitHub Personal Access Tokens Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Codemagic Environment Variables](https://docs.codemagic.io/environment-variables/)
- [Git Authentication with Tokens](https://git-scm.com/book/en/v2/Git-on-the_Server-Generating-Your-SSH-Public-Key)

---

**Note**: This authentication setup is specifically designed for the EduLift AltStore PAL workflow. Adjust repository names and permissions as needed for different use cases.