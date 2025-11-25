# Railway Deployment Guide

## Prerequisites

1. Railway account (https://railway.app/)
2. PostgreSQL database provisioned in Railway
3. This repository pushed to GitHub/GitLab/Bitbucket

## Required Environment Variables

Set these variables in your Railway project settings:

### 1. RAILS_MASTER_KEY
```
284ccc6bcd5c0701b992ec7e02606ec6
```
**IMPORTANT**: Keep this secure! This decrypts your production credentials file (config/credentials/production.yml.enc).

### 2. RAILS_ENV
```
production
```

### 3. SECRET_KEY_BASE (Optional - already in credentials)
If you need an additional secret key:
```
ea2b9585c13e98aff902b904898bd854d16fa81628e21442d4d8e174af9d10466591e4b547d3b8274d81f1d0c831d887d33ea42e437efa79539ec535c06d07e6
```

### 4. DATABASE_URL
Railway will automatically provide this when you provision a PostgreSQL database.
Format: `postgresql://user:password@host:port/database`

## Deployment Steps

### 1. Create New Railway Project

```bash
# Install Railway CLI (optional)
npm install -g @railway/cli

# Login
railway login

# Create new project
railway init
```

### 2. Add PostgreSQL Database

1. Go to your Railway project dashboard
2. Click "New" → "Database" → "Add PostgreSQL"
3. Railway will automatically set the `DATABASE_URL` environment variable

### 3. Set Environment Variables

In Railway dashboard:
1. Go to your service
2. Click "Variables" tab
3. Add the variables listed above

### 4. Deploy

Railway will automatically deploy when you push to your connected repository.

Or manually:
```bash
railway up
```

### 5. Run Database Migrations

Migrations run automatically via the `release` command in Procfile.
If needed manually:
```bash
railway run rails db:migrate
```

### 6. Create Admin User (First Time Setup)

```bash
railway run rails admin:create_user
```

Follow the prompts to create your first admin user.

## Files Modified for Railway

- `Gemfile` - Added `pg` gem for production
- `config/database.yml` - PostgreSQL configuration for production
- `Procfile` - Defines web and release commands
- `config/master.key` - Generated (keep secure, not in git)
- `config/credentials.yml.enc` - Regenerated

## Verification

After deployment:
1. Check Railway logs for any errors
2. Visit your app URL
3. Try logging in with your admin user
4. Check database connectivity

## Troubleshooting

### Assets not loading
Make sure `RAILS_ENV=production` is set.

### Database connection errors
Verify `DATABASE_URL` is set correctly in Railway.

### Secret key errors
Ensure `RAILS_MASTER_KEY` matches the content of your `config/master.key` file.

## Additional Configuration

### Custom Domain
1. Go to Railway project settings
2. Add your custom domain
3. Update DNS records as instructed

### Scaling
Railway auto-scales based on traffic. Configure in project settings.

## Security Notes

- Never commit `config/master.key` to version control
- Keep `RAILS_MASTER_KEY` secure in Railway environment variables
- Use strong passwords for admin users
- Enable 2FA on Railway account

